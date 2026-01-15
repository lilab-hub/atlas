'use client'

import { useState } from 'react'
import { Card, CardContent } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Calendar } from '@/components/ui/calendar'
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Checkbox } from '@/components/ui/checkbox'
import { Task, User, ProjectMember } from '@/types'
import { useSortable } from '@dnd-kit/sortable'
import { CSS } from '@dnd-kit/utilities'
import { Calendar as CalendarIcon, Users, CornerDownRight, GripVertical } from 'lucide-react'

interface DraggableTaskCardProps {
  task: Task
  teamMembers: ProjectMember[]
  onTaskUpdate: (taskId: string, updates: Partial<Task>) => void
  formatDate: (dateString: string) => string
  getPriorityColor: (priority: string) => string
  getPriorityText: (priority: string) => string
  canEdit?: boolean
  highlightOverdue?: boolean
  onDoubleClick?: (task: Task) => void
  isDragging?: boolean // For DragOverlay rendering
}

export function DraggableTaskCard({
  task,
  teamMembers,
  onTaskUpdate,
  formatDate,
  getPriorityColor,
  getPriorityText,
  canEdit = true,
  highlightOverdue = false,
  onDoubleClick,
  isDragging: isDraggingProp = false
}: DraggableTaskCardProps) {
  const [isHovering, setIsHovering] = useState(false)
  const [editingField, setEditingField] = useState<string | null>(null)

  // Check if this is a subtask
  const isSubtask = !!(task as any).taskId

  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging,
  } = useSortable({
    id: task.id,
    disabled: !canEdit,
  })

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
  }

  const handleTaskUpdate = async (field: string, value: string | Date | null) => {
    const oldValue = task[field as keyof Task]
    const updates: Partial<Task> = { [field]: value }

    // Update assignee object when assigneeId changes
    if (field === 'assigneeId') {
      updates.assignee = (value === 'unassigned' || !value ? undefined :
        teamMembers.find(member => member.id === value)) as unknown as User | undefined
      updates.assigneeId = value === 'unassigned' || !value ? undefined : value
    }

    // Optimistically update UI
    onTaskUpdate(task.id, updates)
    setEditingField(null)

    // Prepare data for API
    const apiData: any = {}
    if (field === 'assigneeId') {
      apiData.assigneeId = value === 'unassigned' || !value ? null : value
    } else if (field === 'dueDate') {
      if (value) {
        // Convert YYYY-MM-DD to noon local time to avoid timezone issues
        const [year, month, day] = (value as string).split('-').map(Number)
        const localDate = new Date(year, month - 1, day, 12, 0, 0, 0)
        apiData.dueDate = localDate.toISOString()
      } else {
        apiData.dueDate = null
      }
    } else if (field === 'priority') {
      apiData.priority = value
    } else if (field === 'status') {
      apiData.status = value
    }

    // Determine the correct API endpoint
    let apiUrl = `/api/tasks/${task.id}`
    if (isSubtask) {
      const parentTaskId = (task as any).taskId
      apiUrl = `/api/tasks/${parentTaskId}/subtasks/${task.id}`
    }

    // Call API to persist
    try {
      const response = await fetch(apiUrl, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(apiData)
      })

      if (!response.ok) {
        // Revert on error
        onTaskUpdate(task.id, { [field]: oldValue } as Partial<Task>)
        console.error('Failed to update task')
      }
    } catch (error) {
      // Revert on error
      console.error('Error updating task:', error)
      onTaskUpdate(task.id, { [field]: oldValue } as Partial<Task>)
    }
  }

  const handleDateUpdate = (date: Date | undefined) => {
    if (date) {
      // Convert date to YYYY-MM-DD without timezone conversion
      const year = date.getFullYear()
      const month = String(date.getMonth() + 1).padStart(2, '0')
      const day = String(date.getDate()).padStart(2, '0')
      const dateString = `${year}-${month}-${day}`
      handleTaskUpdate('dueDate', dateString)
    }
  }

  const handleFieldClick = (e: React.MouseEvent, field: string) => {
    e.preventDefault()
    e.stopPropagation()
    setEditingField(field)
  }

  // Check if task is overdue
  const isOverdue = task.dueDate && (() => {
    const dueDate = new Date(task.dueDate)
    const today = new Date()
    today.setHours(23, 59, 59, 999) // End of today
    return dueDate < today
  })()

  const actualIsDragging = isDragging || isDraggingProp

  // If this is being rendered in DragOverlay, don't use ref or sortable styling
  if (isDraggingProp) {
    return (
      <div className="flex items-start gap-1">
        <div className="p-1 mt-1">
          <GripVertical className="h-4 w-4 text-gray-400" />
        </div>
        <Card
          className={`flex-1 shadow-lg rotate-2 scale-105 ${
            isSubtask ? 'bg-gray-50 border-l-2 border-l-blue-400' : 'bg-white'
          } ${
            highlightOverdue && isOverdue ? 'bg-red-50' : ''
          }`}
        >
          <CardContent className="px-1.5 py-0.5">
            <TaskCardContent
              task={task}
              teamMembers={teamMembers}
              onTaskUpdate={onTaskUpdate}
              formatDate={formatDate}
              getPriorityColor={getPriorityColor}
              getPriorityText={getPriorityText}
              canEdit={false}
              isHovering={false}
              editingField={null}
              setEditingField={() => {}}
              handleFieldClick={() => {}}
              handleDateUpdate={() => {}}
              handleTaskUpdate={() => {}}
              isSubtask={isSubtask}
            />
          </CardContent>
        </Card>
      </div>
    )
  }

  return (
    <div
      ref={setNodeRef}
      style={style}
      className={`flex items-start gap-1 ${actualIsDragging ? 'opacity-50' : ''}`}
    >
      {/* Drag Handle */}
      {canEdit ? (
        <div
          {...attributes}
          {...listeners}
          className="p-1 mt-1 cursor-grab active:cursor-grabbing hover:bg-gray-100 rounded transition-colors"
        >
          <GripVertical className="h-4 w-4 text-gray-400" />
        </div>
      ) : (
        <div className="p-1 mt-1">
          <GripVertical className="h-4 w-4 text-gray-200" />
        </div>
      )}

      {/* Task Card */}
      <Card
        className={`flex-1 hover:shadow-md transition-shadow ${
          isSubtask ? 'bg-gray-50 border-l-2 border-l-blue-400' : 'bg-white'
        } ${
          highlightOverdue && isOverdue ? 'bg-red-50' : ''
        }`}
        onMouseEnter={() => setIsHovering(true)}
        onMouseLeave={() => {
          if (!editingField) {
            setIsHovering(false)
          }
        }}
        onDoubleClick={() => onDoubleClick?.(task)}
      >
        <CardContent className="px-1.5 py-0.5">
          <TaskCardContent
            task={task}
            teamMembers={teamMembers}
            onTaskUpdate={onTaskUpdate}
            formatDate={formatDate}
            getPriorityColor={getPriorityColor}
            getPriorityText={getPriorityText}
            canEdit={canEdit}
            isHovering={isHovering}
            editingField={editingField}
            setEditingField={setEditingField}
            handleFieldClick={handleFieldClick}
            handleDateUpdate={handleDateUpdate}
            handleTaskUpdate={handleTaskUpdate}
            isSubtask={isSubtask}
          />
        </CardContent>
      </Card>
    </div>
  )
}

// Extracted card content to avoid duplication
interface TaskCardContentProps {
  task: Task
  teamMembers: ProjectMember[]
  onTaskUpdate: (taskId: string, updates: Partial<Task>) => void
  formatDate: (dateString: string) => string
  getPriorityColor: (priority: string) => string
  getPriorityText: (priority: string) => string
  canEdit: boolean
  isHovering: boolean
  editingField: string | null
  setEditingField: (field: string | null) => void
  handleFieldClick: (e: React.MouseEvent, field: string) => void
  handleDateUpdate: (date: Date | undefined) => void
  handleTaskUpdate: (field: string, value: string | Date | null) => void
  isSubtask: boolean
}

function TaskCardContent({
  task,
  teamMembers,
  onTaskUpdate,
  formatDate,
  getPriorityColor,
  getPriorityText,
  canEdit,
  isHovering,
  editingField,
  setEditingField,
  handleFieldClick,
  handleDateUpdate,
  handleTaskUpdate,
  isSubtask
}: TaskCardContentProps) {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const assignees = (task as any).assignees || []
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const currentAssigneeIds = assignees.map((a: any) => String(a.userId))

  const displayAssignees = assignees.length > 0
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    ? assignees.map((a: any) => a.user)
    : (task.assignee ? [task.assignee] : [])

  const getInitials = (name?: string, email?: string) => {
    if (name) {
      const words = name.split(' ').filter(w => w.length > 0)
      return words.slice(0, 2).map(w => w.charAt(0).toUpperCase()).join('')
    }
    return email?.charAt(0).toUpperCase() || '?'
  }

  const toggleAssignee = async (userId: string) => {
    const newAssigneeIds = currentAssigneeIds.includes(userId)
      ? currentAssigneeIds.filter((id: string) => id !== userId)
      : [...currentAssigneeIds, userId]

    const newAssignees = newAssigneeIds.map((id: string) => {
      const member = teamMembers.find(m => String(m.id) === id)
      return {
        userId: id,
        user: member ? {
          id: member.id,
          name: (member as unknown as User).name,
          email: (member as unknown as User).email
        } : { id, name: 'Usuario', email: '' }
      }
    })

    onTaskUpdate(task.id, { assignees: newAssignees } as unknown as Partial<Task>)

    // Determine the correct API endpoint
    let apiUrl = `/api/tasks/${task.id}`
    if (isSubtask) {
      const parentTaskId = (task as any).taskId
      apiUrl = `/api/tasks/${parentTaskId}/subtasks/${task.id}`
    }

    try {
      const response = await fetch(apiUrl, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ assigneeIds: newAssigneeIds })
      })
      if (!response.ok) {
        onTaskUpdate(task.id, { assignees } as unknown as Partial<Task>)
      }
    } catch (error) {
      console.error('Error updating assignees:', error)
      onTaskUpdate(task.id, { assignees } as unknown as Partial<Task>)
    }
  }

  return (
    <div className="space-y-0.5">
      {/* Título de la tarea */}
      <div className="flex items-start gap-1">
        {isSubtask && (
          <CornerDownRight className="h-3 w-3 text-blue-500 mt-0.5 flex-shrink-0" />
        )}
        <h4 className="font-medium text-sm leading-tight line-clamp-2">{task.title}</h4>
      </div>

      {/* Información adicional: fecha, asignado y prioridad */}
      <div className="space-y-1">
        {/* Fecha de vencimiento - Editable */}
        <div className="flex items-center gap-1 text-xs text-gray-500">
          <CalendarIcon className="h-3 w-3" />
          {canEdit && editingField === 'dueDate' ? (
            <Popover open={true} onOpenChange={(open) => {
              if (!open) {
                setEditingField(null)
              }
            }}>
              <PopoverTrigger asChild>
                <Button
                  variant="ghost"
                  size="sm"
                  className="h-auto p-0 text-xs text-blue-600"
                  onClick={(e) => e.stopPropagation()}
                >
                  {task.dueDate ? formatDate(task.dueDate as unknown as string) : 'Sin fecha'}
                </Button>
              </PopoverTrigger>
              <PopoverContent className="w-auto p-0" align="start">
                <Calendar
                  mode="single"
                  selected={task.dueDate ? new Date(task.dueDate) : undefined}
                  onSelect={handleDateUpdate}
                  initialFocus
                />
              </PopoverContent>
            </Popover>
          ) : (
            <span
              className={`${isHovering && canEdit ? 'hover:text-blue-600 cursor-pointer' : ''}`}
              onClick={(e) => canEdit && handleFieldClick(e, 'dueDate')}
            >
              {task.dueDate ? formatDate(task.dueDate as unknown as string) : 'Sin fecha'}
            </span>
          )}
        </div>

        {/* Personas asignadas y prioridad */}
        <div className="flex items-center justify-between">
          {/* Personas asignadas - Editable with multi-select */}
          <div className="flex items-center gap-1 text-xs text-gray-500">
            {canEdit ? (
              <Popover>
                <PopoverTrigger asChild>
                  <Button variant="ghost" className="h-6 p-1 hover:bg-gray-100" onClick={(e) => e.stopPropagation()}>
                    <Users className="h-3 w-3 text-gray-400 mr-1" />
                    {displayAssignees.length === 0 ? (
                      <span className="text-xs text-gray-500">Sin asignar</span>
                    ) : (
                      <div className="flex items-center -space-x-1">
                        {displayAssignees.slice(0, 2).map((user: User, index: number) => (
                          <div
                            key={user?.id || index}
                            className="h-5 w-5 rounded-full bg-blue-100 flex items-center justify-center border border-white"
                            title={user?.name || user?.email}
                          >
                            <span className="text-[9px] font-medium text-blue-600">
                              {getInitials(user?.name, user?.email)}
                            </span>
                          </div>
                        ))}
                        {displayAssignees.length > 2 && (
                          <div className="h-5 w-5 rounded-full bg-gray-200 flex items-center justify-center border border-white">
                            <span className="text-[9px] font-medium text-gray-600">+{displayAssignees.length - 2}</span>
                          </div>
                        )}
                      </div>
                    )}
                  </Button>
                </PopoverTrigger>
                <PopoverContent className="w-52 p-2" align="start" onClick={(e) => e.stopPropagation()}>
                  <div className="space-y-1 max-h-48 overflow-y-auto">
                    {teamMembers.map((member) => (
                      <div
                        key={member.id}
                        className="flex items-center space-x-2 p-1.5 hover:bg-accent rounded cursor-pointer"
                        onClick={(e) => {
                          e.stopPropagation()
                          toggleAssignee(String(member.id))
                        }}
                      >
                        <Checkbox checked={currentAssigneeIds.includes(String(member.id))} />
                        <span className="text-xs">{(member as unknown as User).name || (member as unknown as User).email}</span>
                      </div>
                    ))}
                  </div>
                </PopoverContent>
              </Popover>
            ) : (
              <div className="flex items-center gap-1">
                <Users className="h-3 w-3" />
                {displayAssignees.length === 0 ? (
                  <span className="text-xs">Sin asignar</span>
                ) : (
                  <div className="flex items-center -space-x-1">
                    {displayAssignees.slice(0, 2).map((user: User, index: number) => (
                      <div
                        key={user?.id || index}
                        className="h-5 w-5 rounded-full bg-blue-100 flex items-center justify-center border border-white"
                        title={user?.name || user?.email}
                      >
                        <span className="text-[9px] font-medium text-blue-600">
                          {getInitials(user?.name, user?.email)}
                        </span>
                      </div>
                    ))}
                    {displayAssignees.length > 2 && (
                      <span className="text-xs ml-1">+{displayAssignees.length - 2}</span>
                    )}
                  </div>
                )}
              </div>
            )}
          </div>

          {/* Prioridad - Editable */}
          {canEdit && editingField === 'priority' ? (
            <Select
              open={true}
              value={task.priority}
              onValueChange={(value) => handleTaskUpdate('priority', value)}
              onOpenChange={(open) => {
                if (!open) {
                  setEditingField(null)
                }
              }}
            >
              <SelectTrigger
                className="h-auto p-0 border-none bg-transparent"
                onClick={(e) => e.stopPropagation()}
              >
                <Badge
                  variant="outline"
                  className={`text-xs cursor-pointer ${getPriorityColor(task.priority)} ring-2 ring-blue-200`}
                >
                  {getPriorityText(task.priority)}
                </Badge>
              </SelectTrigger>
              <SelectContent onClick={(e) => e.stopPropagation()}>
                <SelectItem value="LOW">
                  <Badge
                    variant="outline"
                    className={`text-xs ${getPriorityColor('LOW')}`}
                  >
                    {getPriorityText('LOW')}
                  </Badge>
                </SelectItem>
                <SelectItem value="MEDIUM">
                  <Badge
                    variant="outline"
                    className={`text-xs ${getPriorityColor('MEDIUM')}`}
                  >
                    {getPriorityText('MEDIUM')}
                  </Badge>
                </SelectItem>
                <SelectItem value="HIGH">
                  <Badge
                    variant="outline"
                    className={`text-xs ${getPriorityColor('HIGH')}`}
                  >
                    {getPriorityText('HIGH')}
                  </Badge>
                </SelectItem>
                <SelectItem value="URGENT">
                  <Badge
                    variant="outline"
                    className={`text-xs ${getPriorityColor('URGENT')}`}
                  >
                    {getPriorityText('URGENT')}
                  </Badge>
                </SelectItem>
              </SelectContent>
            </Select>
          ) : (
            <Badge
              variant="outline"
              className={`text-xs ${getPriorityColor(task.priority)} ${isHovering && canEdit ? 'hover:ring-2 hover:ring-blue-200 cursor-pointer' : ''}`}
              onClick={(e) => canEdit && handleFieldClick(e, 'priority')}
            >
              {getPriorityText(task.priority)}
            </Badge>
          )}
        </div>
      </div>
    </div>
  )
}
