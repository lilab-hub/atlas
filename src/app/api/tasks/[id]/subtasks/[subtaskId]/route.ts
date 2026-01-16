import { NextRequest, NextResponse } from 'next/server'
import { prisma } from '@/lib/prisma'
import { getServerSession } from 'next-auth'
import { authOptions } from '@/lib/auth'
import { notifyTaskAssigned, notifyTaskCompleted } from '@/lib/notifications'

// PATCH /api/tasks/[id]/subtasks/[subtaskId] - Update a subtask
export async function PATCH(
  request: NextRequest,
  { params }: { params: { id: string; subtaskId: string } }
) {
  try {
    const session = await getServerSession(authOptions)

    if (!session?.user) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      )
    }

    const taskId = parseInt(params.id)
    const subtaskId = parseInt(params.subtaskId)

    if (isNaN(taskId) || isNaN(subtaskId)) {
      return NextResponse.json(
        { error: 'Invalid task ID or subtask ID' },
        { status: 400 }
      )
    }

    // Verify subtask exists and user has access
    const subtask = await prisma.task.findUnique({
      where: { id: subtaskId },
      include: {
        parentTask: {
          include: {
            project: {
              select: {
                organizationId: true
              }
            }
          }
        }
      }
    })

    if (!subtask || !subtask.parentTaskId || subtask.deletedAt) {
      return NextResponse.json(
        { error: 'Subtask not found' },
        { status: 404 }
      )
    }

    if (subtask.parentTask?.project.organizationId !== session.user.organizationId) {
      return NextResponse.json(
        { error: 'Forbidden' },
        { status: 403 }
      )
    }

    if (subtask.parentTaskId !== taskId) {
      return NextResponse.json(
        { error: 'Subtask does not belong to this task' },
        { status: 400 }
      )
    }

    const body = await request.json()
    const { title, description, status, priority, dueDate, assigneeId, assigneeIds, order } = body

    // Store previous status for notification comparison
    const previousStatus = subtask.status

    // Get current assignee IDs for comparison
    const currentAssignees = await prisma.taskAssignee.findMany({
      where: { taskId: subtaskId },
      select: { userId: true }
    })
    const previousAssigneeIds = currentAssignees.map(a => a.userId)

    // Support both legacy assigneeId (single) and new assigneeIds (multiple)
    const assigneeIdsToUse: number[] | undefined = assigneeIds !== undefined
      ? assigneeIds.map((id: string | number) => parseInt(String(id))).filter((id: number) => !isNaN(id))
      : (assigneeId !== undefined
          ? (assigneeId ? [parseInt(assigneeId)] : [])
          : undefined)

    const updatedSubtask = await prisma.task.update({
      where: { id: subtaskId },
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
        ...(order !== undefined && { order })
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
        }
      }
    })

    // Update multiple assignees if provided
    if (assigneeIdsToUse !== undefined) {
      // Delete existing assignees
      await prisma.taskAssignee.deleteMany({
        where: { taskId: subtaskId }
      })

      // Create new assignees
      if (assigneeIdsToUse.length > 0) {
        await prisma.taskAssignee.createMany({
          data: assigneeIdsToUse.map(userId => ({
            taskId: subtaskId,
            userId
          }))
        })
      }

      // Reload to get updated assignees
      const reloadedSubtask = await prisma.task.findUnique({
        where: { id: subtaskId },
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
          }
        }
      })

      // Send notifications to newly assigned users
      const newAssigneeIds = assigneeIdsToUse.filter(id => !previousAssigneeIds.includes(id))
      const currentUserId = parseInt(session.user.id)

      for (const userId of newAssigneeIds) {
        if (userId !== currentUserId) {
          await notifyTaskAssigned(
            updatedSubtask.id.toString(),
            userId.toString(),
            updatedSubtask.title,
            subtask.parentTask?.project?.id?.toString() || ''
          ).catch(err => console.error('Failed to send assignment notification:', err))
        }
      }

      // Return reloaded subtask with updated assignees
      if (reloadedSubtask) {
        return NextResponse.json(reloadedSubtask)
      }
    }

    // Send notification when subtask is completed
    if (status !== undefined &&
        previousStatus !== 'COMPLETED' &&
        updatedSubtask.status === 'COMPLETED') {
      const usersToNotify = new Set<number>()
      const currentUserId = parseInt(session.user.id)

      // Add all assignees if different from current user
      if (updatedSubtask.assignees && updatedSubtask.assignees.length > 0) {
        for (const assignee of updatedSubtask.assignees) {
          if (assignee.userId !== currentUserId) {
            usersToNotify.add(assignee.userId)
          }
        }
      } else if (updatedSubtask.assigneeId && updatedSubtask.assigneeId !== currentUserId) {
        // Fallback to legacy single assignee
        usersToNotify.add(updatedSubtask.assigneeId)
      }

      // Add creator if different from current user
      if (updatedSubtask.createdById && updatedSubtask.createdById !== currentUserId) {
        usersToNotify.add(updatedSubtask.createdById)
      }

      // Send notifications to all relevant users
      for (const userId of usersToNotify) {
        await notifyTaskCompleted(
          userId.toString(),
          updatedSubtask.id.toString(),
          updatedSubtask.title,
          session.user.name || session.user.email,
          subtask.parentTask?.project?.id?.toString() || ''
        ).catch(err => console.error('Failed to send task completion notification:', err))
      }
    }

    return NextResponse.json(updatedSubtask)
  } catch (error) {
    console.error('Error updating subtask:', error)
    return NextResponse.json(
      { error: 'Failed to update subtask' },
      { status: 500 }
    )
  }
}

// DELETE /api/tasks/[id]/subtasks/[subtaskId] - Delete a subtask
export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string; subtaskId: string } }
) {
  try {
    const session = await getServerSession(authOptions)

    if (!session?.user) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      )
    }

    const taskId = parseInt(params.id)
    const subtaskId = parseInt(params.subtaskId)

    if (isNaN(taskId) || isNaN(subtaskId)) {
      return NextResponse.json(
        { error: 'Invalid task ID or subtask ID' },
        { status: 400 }
      )
    }

    // Verify subtask exists and user has access
    const subtask = await prisma.task.findUnique({
      where: { id: subtaskId },
      include: {
        parentTask: {
          include: {
            project: {
              select: {
                organizationId: true
              }
            }
          }
        }
      }
    })

    if (!subtask || !subtask.parentTaskId || subtask.deletedAt) {
      return NextResponse.json(
        { error: 'Subtask not found' },
        { status: 404 }
      )
    }

    if (subtask.parentTask?.project.organizationId !== session.user.organizationId) {
      return NextResponse.json(
        { error: 'Forbidden' },
        { status: 403 }
      )
    }

    if (subtask.parentTaskId !== taskId) {
      return NextResponse.json(
        { error: 'Subtask does not belong to this task' },
        { status: 400 }
      )
    }

    // Only the creator or project owner can delete the subtask
    const currentUserId = parseInt(session.user.id)
    const isCreator = subtask.createdById === currentUserId

    // Check if user is the project owner
    const projectId = subtask.parentTask?.project?.id
    if (!projectId) {
      return NextResponse.json(
        { error: 'Project not found' },
        { status: 404 }
      )
    }

    const projectMember = await prisma.projectMember.findUnique({
      where: {
        projectId_userId: {
          projectId: projectId,
          userId: currentUserId
        }
      }
    })

    const isProjectOwner = projectMember?.role === 'OWNER'

    if (!isCreator && !isProjectOwner) {
      return NextResponse.json(
        { error: 'Solo el creador de la subtarea o el propietario del proyecto pueden eliminarla' },
        { status: 403 }
      )
    }

    // Soft delete - set deletedAt timestamp instead of actually deleting
    await prisma.task.update({
      where: { id: subtaskId },
      data: { deletedAt: new Date() }
    })

    return NextResponse.json({ message: 'Subtask deleted successfully' })
  } catch (error) {
    console.error('Error deleting subtask:', error)
    return NextResponse.json(
      { error: 'Failed to delete subtask' },
      { status: 500 }
    )
  }
}
