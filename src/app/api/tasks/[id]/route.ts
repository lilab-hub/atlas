import { NextRequest, NextResponse } from 'next/server'
import { prisma } from '@/lib/prisma'
import { verifyProjectAccess, verifyProjectEditAccess } from '@/lib/project-access'
import { getServerSession } from 'next-auth'
import { authOptions } from '@/lib/auth'
import { auditTaskChanges } from '@/lib/audit'
import { notifyTaskAssigned, notifyTaskCompleted } from '@/lib/notifications'

// PATCH /api/tasks/[id] - Update a task
export async function PATCH(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const resolvedParams = await params
    const taskId = parseInt(resolvedParams.id)

    if (isNaN(taskId)) {
      return NextResponse.json(
        { error: 'Invalid task ID' },
        { status: 400 }
      )
    }

    // Get session for audit log
    const session = await getServerSession(authOptions)
    if (!session?.user) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      )
    }

    // Get existing task with all fields for audit comparison (including assignees)
    const existingTask = await prisma.task.findUnique({
      where: { id: taskId },
      include: {
        assignees: {
          select: {
            userId: true
          }
        }
      }
    })

    if (!existingTask || existingTask.deletedAt) {
      return NextResponse.json(
        { error: 'Task not found' },
        { status: 404 }
      )
    }

    // Verify user can edit (not a VIEWER)
    const accessCheck = await verifyProjectEditAccess(existingTask.projectId)
    if (accessCheck.error) {
      return accessCheck.error
    }

    // Get current user ID for notifications (not for permission checking)
    const currentUserId = parseInt(session.user.id)

    const body = await request.json()
    const { title, description, status, priority, dueDate, assigneeId, assigneeIds, epicId, sprintId } = body

    // Validate title if provided
    if (title !== undefined && (!title || !title.trim())) {
      return NextResponse.json(
        { error: 'Task title cannot be empty' },
        { status: 400 }
      )
    }

    // Handle assignee updates
    // Support both legacy assigneeId (single) and new assigneeIds (multiple)
    let assigneeIdsToUse: number[] | undefined
    if (assigneeIds !== undefined) {
      assigneeIdsToUse = assigneeIds
        .map((id: string | number) => parseInt(String(id)))
        .filter((id: number) => !isNaN(id))
    } else if (assigneeId !== undefined) {
      assigneeIdsToUse = assigneeId ? [parseInt(assigneeId)] : []
    }

    // Use transaction to update task and assignees atomically
    const updatedTask = await prisma.$transaction(async (tx) => {
      // If assignees are being updated, delete old ones and create new ones
      if (assigneeIdsToUse !== undefined) {
        await tx.taskAssignee.deleteMany({
          where: { taskId }
        })

        if (assigneeIdsToUse.length > 0) {
          await tx.taskAssignee.createMany({
            data: assigneeIdsToUse.map(aId => ({
              taskId,
              userId: aId
            }))
          })
        }
      }

      return tx.task.update({
        where: { id: taskId },
        data: {
          ...(title !== undefined && { title: title.trim() }),
          ...(description !== undefined && { description: description?.trim() || null }),
          ...(status !== undefined && { status }),
          ...(priority !== undefined && { priority }),
          ...(dueDate !== undefined && { dueDate: dueDate ? new Date(dueDate) : null }),
          // Legacy field - set to first assignee for backwards compatibility
          ...(assigneeIdsToUse !== undefined && {
            assigneeId: assigneeIdsToUse.length > 0 ? assigneeIdsToUse[0] : null
          }),
          ...(epicId !== undefined && { epicId: epicId ? parseInt(epicId) : null }),
          ...(sprintId !== undefined && { sprintId: sprintId ? parseInt(sprintId) : null })
        },
        include: {
          assignee: {
            select: {
              id: true,
              name: true,
              email: true
            }
          },
          assignees: {
            select: {
              id: true,
              userId: true,
              createdAt: true,
              user: {
                select: {
                  id: true,
                  name: true,
                  email: true
                }
              }
            }
          },
          createdBy: {
            select: {
              id: true,
              name: true,
              email: true
            }
          },
          epic: {
            select: {
              id: true,
              name: true,
              color: true,
              status: true
            }
          },
          sprint: {
            select: {
              id: true,
              name: true,
              status: true,
              startDate: true,
              endDate: true
            }
          }
        }
      })
    })

    // Create audit logs for changes
    await auditTaskChanges({
      oldTask: existingTask,
      newTask: updatedTask,
      userId: session.user.id
    })

    // Send notifications for task assignment changes
    // Notify new assignees (users who weren't assigned before)
    if (assigneeIdsToUse !== undefined) {
      const oldAssigneeIds = new Set(existingTask.assignees.map(a => a.userId))
      const newAssignees = updatedTask.assignees.filter(
        a => !oldAssigneeIds.has(a.userId) && a.userId !== currentUserId
      )

      for (const assignee of newAssignees) {
        await notifyTaskAssigned(
          updatedTask.id.toString(),
          assignee.userId.toString(),
          updatedTask.title,
          updatedTask.projectId.toString()
        ).catch(err => console.error('Failed to send notification:', err))
      }
    }

    // Send notifications when task is completed
    // Notify all assignees and creator (excluding the person who completed it)
    if (status !== undefined &&
        existingTask.status !== 'COMPLETED' &&
        updatedTask.status === 'COMPLETED') {
      const usersToNotify = new Set<number>()

      // Add all assignees (except current user)
      for (const assignee of updatedTask.assignees) {
        if (assignee.userId !== currentUserId) {
          usersToNotify.add(assignee.userId)
        }
      }

      // Add creator (if different from current user)
      if (updatedTask.createdById !== currentUserId) {
        usersToNotify.add(updatedTask.createdById)
      }

      for (const userId of usersToNotify) {
        await notifyTaskCompleted(
          userId.toString(),
          updatedTask.id.toString(),
          updatedTask.title,
          session.user.name || session.user.email,
          updatedTask.projectId.toString()
        ).catch(err => console.error('Failed to send task completion notification:', err))
      }
    }

    return NextResponse.json(updatedTask)
  } catch (error) {
    console.error('Error updating task:', error)
    return NextResponse.json(
      { error: 'Failed to update task' },
      { status: 500 }
    )
  }
}

// GET /api/tasks/[id] - Get a single task
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const session = await getServerSession(authOptions)

    if (!session?.user) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      )
    }

    const resolvedParams = await params
    const taskId = parseInt(resolvedParams.id)

    if (isNaN(taskId)) {
      return NextResponse.json(
        { error: 'Invalid task ID' },
        { status: 400 }
      )
    }

    const task = await prisma.task.findUnique({
      where: { id: taskId },
      include: {
        assignee: {
          select: {
            id: true,
            name: true,
            email: true
          }
        },
        assignees: {
          select: {
            id: true,
            userId: true,
            createdAt: true,
            user: {
              select: {
                id: true,
                name: true,
                email: true
              }
            }
          }
        },
        createdBy: {
          select: {
            id: true,
            name: true,
            email: true
          }
        },
        epic: {
          select: {
            id: true,
            name: true,
            color: true,
            status: true
          }
        },
        sprint: {
          select: {
            id: true,
            name: true,
            status: true,
            startDate: true,
            endDate: true
          }
        },
        project: {
          select: {
            id: true,
            name: true,
            organizationId: true
          }
        },
        comments: {
          include: {
            user: {
              select: {
                id: true,
                name: true,
                email: true
              }
            }
          },
          orderBy: {
            createdAt: 'desc'
          }
        },
        attachments: {
          orderBy: {
            createdAt: 'desc'
          }
        }
      }
    })

    if (!task || task.deletedAt) {
      return NextResponse.json(
        { error: 'Task not found' },
        { status: 404 }
      )
    }

    // Verify user belongs to the same organization
    if (task.project.organizationId !== session.user.organizationId) {
      return NextResponse.json(
        { error: 'Forbidden' },
        { status: 403 }
      )
    }

    return NextResponse.json(task)
  } catch (error) {
    console.error('Error fetching task:', error)
    return NextResponse.json(
      { error: 'Failed to fetch task' },
      { status: 500 }
    )
  }
}

// DELETE /api/tasks/[id] - Delete a task
export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    // Get session to check if user is the creator
    const session = await getServerSession(authOptions)
    if (!session?.user) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      )
    }

    const resolvedParams = await params
    const taskId = parseInt(resolvedParams.id)

    if (isNaN(taskId)) {
      return NextResponse.json(
        { error: 'Invalid task ID' },
        { status: 400 }
      )
    }

    // Check if task exists and get project ID and creator
    const task = await prisma.task.findUnique({
      where: { id: taskId },
      select: {
        id: true,
        projectId: true,
        createdById: true,
        deletedAt: true
      }
    })

    if (!task || task.deletedAt) {
      return NextResponse.json(
        { error: 'Task not found' },
        { status: 404 }
      )
    }

    // Verify user can edit (not a VIEWER)
    const accessCheck = await verifyProjectEditAccess(task.projectId)
    if (accessCheck.error) {
      return accessCheck.error
    }

    // Only the creator or project owner can delete the task
    const currentUserId = parseInt(session.user.id)
    const isCreator = task.createdById === currentUserId

    // Check if user is the project owner
    const projectMember = await prisma.projectMember.findUnique({
      where: {
        projectId_userId: {
          projectId: task.projectId,
          userId: currentUserId
        }
      }
    })

    const isProjectOwner = projectMember?.role === 'OWNER'

    if (!isCreator && !isProjectOwner) {
      return NextResponse.json(
        { error: 'Solo el creador de la tarea o el propietario del proyecto pueden eliminarla' },
        { status: 403 }
      )
    }

    // Soft delete - set deletedAt timestamp instead of actually deleting
    await prisma.task.update({
      where: { id: taskId },
      data: { deletedAt: new Date() }
    })

    // Also soft delete all subtasks
    await prisma.task.updateMany({
      where: { parentTaskId: taskId },
      data: { deletedAt: new Date() }
    })

    return NextResponse.json({ message: 'Task deleted successfully' })
  } catch (error) {
    console.error('Error deleting task:', error)
    return NextResponse.json(
      { error: 'Failed to delete task' },
      { status: 500 }
    )
  }
}
