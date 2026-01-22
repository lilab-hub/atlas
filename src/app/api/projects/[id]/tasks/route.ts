import { NextRequest, NextResponse } from 'next/server'
import { prisma } from '@/lib/prisma'
import { verifyProjectAccess, verifyProjectEditAccess } from '@/lib/project-access'
import { notifyTaskAssigned } from '@/lib/notifications'
import { normalizeStatusName } from '@/lib/project-config'

// GET /api/projects/[id]/tasks - Get all tasks for a project
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const resolvedParams = await params
    const projectId = parseInt(resolvedParams.id)

    if (isNaN(projectId)) {
      return NextResponse.json(
        { error: 'Invalid project ID' },
        { status: 400 }
      )
    }

    // Verify access in a single query
    const accessCheck = await verifyProjectAccess(projectId)
    if (accessCheck.error) {
      return accessCheck.error
    }

    // Optimized query - removed subtasks include (they'll be loaded separately when needed)
    // Removed comments and attachments count (not shown in list view)
    const tasks = await prisma.task.findMany({
      where: {
        projectId,
        parentTaskId: null, // Only get parent tasks, not subtasks
        deletedAt: null // Exclude soft-deleted tasks
      },
      select: {
        id: true,
        title: true,
        description: true,
        status: true,
        priority: true,
        dueDate: true,
        createdAt: true,
        updatedAt: true,
        order: true,
        projectId: true,
        assigneeId: true, // DEPRECATED: Legacy field
        epicId: true,
        sprintId: true,
        // Legacy single assignee (DEPRECATED)
        assignee: {
          select: {
            id: true,
            name: true,
            email: true
          }
        },
        // Multiple assignees (new)
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
        epic: {
          select: {
            id: true,
            name: true,
            color: true
          }
        },
        sprint: {
          select: {
            id: true,
            name: true,
            status: true
          }
        },
        createdBy: {
          select: {
            id: true,
            name: true,
            email: true
          }
        },
        _count: {
          select: {
            subtasks: true
          }
        },
        // Include subtasks for list view
        subtasks: {
          where: {
            deletedAt: null // Exclude soft-deleted subtasks
          },
          select: {
            id: true,
            title: true,
            description: true,
            status: true,
            priority: true,
            dueDate: true,
            createdAt: true,
            updatedAt: true,
            order: true,
            assigneeId: true,
            createdById: true,
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
          },
          orderBy: {
            order: 'asc'
          }
        }
      },
      orderBy: {
        createdAt: 'desc'
      }
    })

    return NextResponse.json(tasks)
  } catch (error) {
    console.error('Error fetching tasks:', error)
    return NextResponse.json(
      { error: 'Failed to fetch tasks' },
      { status: 500 }
    )
  }
}

// POST /api/projects/[id]/tasks - Create a new task
export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const resolvedParams = await params
    const projectId = parseInt(resolvedParams.id)

    if (isNaN(projectId)) {
      return NextResponse.json(
        { error: 'Invalid project ID' },
        { status: 400 }
      )
    }

    // Verify user can edit (not a VIEWER)
    const accessCheck = await verifyProjectEditAccess(projectId)
    if (accessCheck.error) {
      return accessCheck.error
    }

    const { userId } = accessCheck

    // Get project template to determine default status
    const project = await prisma.project.findUnique({
      where: { id: projectId },
      select: {
        template: {
          include: {
            states: {
              orderBy: { order: 'asc' }
            }
          }
        }
      }
    })

    // Get the first status from the project template, or use PENDING as fallback
    const firstTemplateStateName = project?.template?.states?.[0]?.name
    const defaultStatus = firstTemplateStateName ? normalizeStatusName(firstTemplateStateName) : 'PENDING'

    const body = await request.json()
    const { title, description, priority, dueDate, assigneeId, assigneeIds, sprintId, epicId, status: rawStatus } = body
    // Normalize status to uppercase with underscores if provided, otherwise use template's first status
    const status = rawStatus ? normalizeStatusName(rawStatus) : defaultStatus

    // Validate required fields
    if (!title || !title.trim()) {
      return NextResponse.json(
        { error: 'Task title is required' },
        { status: 400 }
      )
    }

    // Support both legacy assigneeId (single) and new assigneeIds (multiple)
    // If assigneeIds is provided, use it; otherwise fall back to assigneeId
    const assigneeIdsToUse: number[] = assigneeIds
      ? assigneeIds.map((id: string | number) => parseInt(String(id))).filter((id: number) => !isNaN(id))
      : (assigneeId ? [parseInt(assigneeId)] : [])

    const task = await prisma.task.create({
      data: {
        title: title.trim(),
        description: description?.trim() || null,
        status,
        priority: priority || 'MEDIUM',
        dueDate: dueDate ? new Date(dueDate) : null,
        projectId,
        sprintId: sprintId ? parseInt(sprintId) : null,
        epicId: epicId ? parseInt(epicId) : null,
        // Legacy field (DEPRECATED) - set to first assignee for backwards compatibility
        assigneeId: assigneeIdsToUse.length > 0 ? assigneeIdsToUse[0] : null,
        createdById: userId,
        // Create multiple assignees
        assignees: {
          create: assigneeIdsToUse.map(aId => ({
            userId: aId
          }))
        }
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
            color: true
          }
        },
        sprint: {
          select: {
            id: true,
            name: true,
            status: true
          }
        }
      }
    })

    // Send notifications to all assignees (except the creator)
    for (const assignee of task.assignees) {
      if (assignee.userId !== userId) {
        await notifyTaskAssigned(
          task.id.toString(),
          assignee.userId.toString(),
          task.title,
          task.projectId.toString()
        ).catch(err => console.error('Failed to send notification:', err))
      }
    }

    return NextResponse.json(task, { status: 201 })
  } catch (error) {
    console.error('Error creating task:', error)
    return NextResponse.json(
      { error: 'Failed to create task' },
      { status: 500 }
    )
  }
}
