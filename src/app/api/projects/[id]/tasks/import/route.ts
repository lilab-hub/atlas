import { NextRequest, NextResponse } from 'next/server'
import { prisma } from '@/lib/prisma'
import { verifyProjectEditAccess } from '@/lib/project-access'
import * as XLSX from 'xlsx'

// Type for parsed row from Excel
interface ExcelRow {
  Título?: string
  Descripción?: string
  Prioridad?: string
  'Fecha Vencimiento'?: string
  Sprint?: string
  Épica?: string
}

// Type for validated task
interface ValidatedTask {
  title: string
  description: string | null
  priority: 'LOW' | 'MEDIUM' | 'HIGH' | 'URGENT'
  dueDate: Date | null
  sprintId: number | null
  epicId: number | null
  status: string
  rowNumber: number
  errors: string[]
}

// Map Spanish priority names to enum values
const priorityMap: Record<string, 'LOW' | 'MEDIUM' | 'HIGH' | 'URGENT'> = {
  'baja': 'LOW',
  'media': 'MEDIUM',
  'alta': 'HIGH',
  'urgente': 'URGENT',
  'low': 'LOW',
  'medium': 'MEDIUM',
  'high': 'HIGH',
  'urgent': 'URGENT',
}

// Parse date from various formats
function parseDate(dateStr: string | undefined): Date | null {
  if (!dateStr) return null

  // Handle Excel serial date numbers
  if (typeof dateStr === 'number') {
    const excelDate = XLSX.SSF.parse_date_code(dateStr)
    if (excelDate) {
      return new Date(excelDate.y, excelDate.m - 1, excelDate.d)
    }
  }

  const str = String(dateStr).trim()
  if (!str) return null

  // Try DD/MM/YYYY format
  const ddmmyyyy = str.match(/^(\d{1,2})\/(\d{1,2})\/(\d{4})$/)
  if (ddmmyyyy) {
    const [, day, month, year] = ddmmyyyy
    return new Date(parseInt(year), parseInt(month) - 1, parseInt(day))
  }

  // Try YYYY-MM-DD format
  const yyyymmdd = str.match(/^(\d{4})-(\d{2})-(\d{2})$/)
  if (yyyymmdd) {
    const [, year, month, day] = yyyymmdd
    return new Date(parseInt(year), parseInt(month) - 1, parseInt(day))
  }

  // Try native Date parsing as fallback
  const parsed = new Date(str)
  if (!isNaN(parsed.getTime())) {
    return parsed
  }

  return null
}

// POST /api/projects/[id]/tasks/import - Import tasks from Excel
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

    // Verify user can edit
    const accessCheck = await verifyProjectEditAccess(projectId)
    if (accessCheck.error) {
      return accessCheck.error
    }

    const { userId } = accessCheck

    // Get form data with file
    const formData = await request.formData()
    const file = formData.get('file') as File | null
    const previewOnly = formData.get('previewOnly') === 'true'

    if (!file) {
      return NextResponse.json(
        { error: 'No file provided' },
        { status: 400 }
      )
    }

    // Validate file type
    const validTypes = [
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'application/vnd.ms-excel',
      'text/csv'
    ]
    if (!validTypes.includes(file.type) && !file.name.match(/\.(xlsx|xls|csv)$/i)) {
      return NextResponse.json(
        { error: 'Invalid file type. Please upload an Excel file (.xlsx, .xls) or CSV' },
        { status: 400 }
      )
    }

    // Read file
    const buffer = await file.arrayBuffer()
    const workbook = XLSX.read(buffer, { type: 'array', cellDates: true })

    // Get first sheet
    const sheetName = workbook.SheetNames[0]
    if (!sheetName) {
      return NextResponse.json(
        { error: 'Excel file is empty' },
        { status: 400 }
      )
    }

    const sheet = workbook.Sheets[sheetName]
    const rows: ExcelRow[] = XLSX.utils.sheet_to_json(sheet)

    if (rows.length === 0) {
      return NextResponse.json(
        { error: 'No data found in Excel file' },
        { status: 400 }
      )
    }

    // Get project template for default status
    const project = await prisma.project.findUnique({
      where: { id: projectId },
      select: {
        template: {
          select: {
            states: {
              orderBy: { order: 'asc' },
              take: 1,
              select: { name: true }
            }
          }
        }
      }
    })

    // Get default status from project template (first state)
    // Convert state name to ID format: "Por Hacer" -> "POR_HACER"
    let defaultStatus = 'PENDING'
    if (project?.template?.states && project.template.states.length > 0) {
      const stateName = project.template.states[0].name
      defaultStatus = stateName.toUpperCase().replace(/\s+/g, '_')
    }

    // Get existing sprints and epics for validation
    const [sprints, epics] = await Promise.all([
      prisma.sprint.findMany({
        where: { projectId },
        select: { id: true, name: true }
      }),
      prisma.epic.findMany({
        where: { projectId },
        select: { id: true, name: true }
      })
    ])

    // Create lookup maps (case-insensitive)
    const sprintMap = new Map(sprints.map(s => [s.name.toLowerCase(), s.id]))
    const epicMap = new Map(epics.map(e => [e.name.toLowerCase(), e.id]))

    // Validate and transform rows
    const validatedTasks: ValidatedTask[] = rows.map((row, index) => {
      const errors: string[] = []
      const rowNumber = index + 2 // Excel rows start at 1, plus header row

      // Get title (required) - check multiple possible column names
      const title = row['Título'] || row['Titulo'] || (row as Record<string, unknown>)['titulo'] || (row as Record<string, unknown>)['TITULO'] || ''
      if (!title || !String(title).trim()) {
        errors.push('Título es requerido')
      }

      // Get description
      const description = row['Descripción'] || row['Descripcion'] || (row as Record<string, unknown>)['descripcion'] || ''

      // Get and validate priority
      const priorityStr = String(row['Prioridad'] || row['prioridad'] || (row as Record<string, unknown>)['PRIORIDAD'] || 'media').toLowerCase().trim()
      const priority = priorityMap[priorityStr]
      if (row['Prioridad'] && !priority) {
        errors.push(`Prioridad inválida: "${row['Prioridad']}". Use: Baja, Media, Alta, Urgente`)
      }

      // Parse due date
      const dueDateStr = row['Fecha Vencimiento'] || row['Fecha de Vencimiento'] || (row as Record<string, unknown>)['fecha vencimiento'] || ''
      const dueDate = parseDate(dueDateStr as string)
      if (dueDateStr && !dueDate) {
        errors.push(`Fecha inválida: "${dueDateStr}". Use formato DD/MM/YYYY`)
      }

      // Resolve sprint
      const sprintName = row['Sprint'] || row['sprint'] || ''
      let sprintId: number | null = null
      if (sprintName && String(sprintName).trim()) {
        sprintId = sprintMap.get(String(sprintName).toLowerCase().trim()) || null
        if (!sprintId) {
          errors.push(`Sprint no encontrado: "${sprintName}"`)
        }
      }

      // Resolve epic
      const epicName = row['Épica'] || row['Epica'] || row['épica'] || row['epica'] || ''
      let epicId: number | null = null
      if (epicName && String(epicName).trim()) {
        epicId = epicMap.get(String(epicName).toLowerCase().trim()) || null
        if (!epicId) {
          errors.push(`Épica no encontrada: "${epicName}"`)
        }
      }

      return {
        title: String(title).trim(),
        description: description ? String(description).trim() : null,
        priority: priority || 'MEDIUM',
        dueDate,
        sprintId,
        epicId,
        status: defaultStatus,
        rowNumber,
        errors
      }
    })

    // Count valid and invalid tasks
    const validTasks = validatedTasks.filter(t => t.errors.length === 0 && t.title)
    const invalidTasks = validatedTasks.filter(t => t.errors.length > 0 || !t.title)

    // If preview only, return validation results
    if (previewOnly) {
      return NextResponse.json({
        preview: true,
        totalRows: rows.length,
        validCount: validTasks.length,
        invalidCount: invalidTasks.length,
        tasks: validatedTasks.map(t => ({
          rowNumber: t.rowNumber,
          title: t.title,
          description: t.description,
          priority: t.priority,
          dueDate: t.dueDate?.toISOString().split('T')[0] || null,
          sprintId: t.sprintId,
          epicId: t.epicId,
          errors: t.errors,
          isValid: t.errors.length === 0 && !!t.title
        })),
        sprints: sprints.map(s => ({ id: s.id, name: s.name })),
        epics: epics.map(e => ({ id: e.id, name: e.name }))
      })
    }

    // Import only valid tasks
    if (validTasks.length === 0) {
      return NextResponse.json({
        error: 'No valid tasks to import',
        invalidCount: invalidTasks.length,
        errors: invalidTasks.map(t => ({
          rowNumber: t.rowNumber,
          errors: t.errors
        }))
      }, { status: 400 })
    }

    // Create tasks in batch
    const createdTasks = await prisma.$transaction(
      validTasks.map(task =>
        prisma.task.create({
          data: {
            title: task.title,
            description: task.description,
            status: task.status,
            priority: task.priority,
            dueDate: task.dueDate,
            projectId,
            sprintId: task.sprintId,
            epicId: task.epicId,
            createdById: userId
          },
          select: {
            id: true,
            title: true
          }
        })
      )
    )

    return NextResponse.json({
      success: true,
      imported: createdTasks.length,
      skipped: invalidTasks.length,
      tasks: createdTasks,
      errors: invalidTasks.length > 0 ? invalidTasks.map(t => ({
        rowNumber: t.rowNumber,
        title: t.title || '(sin título)',
        errors: t.errors
      })) : []
    }, { status: 201 })

  } catch (error) {
    console.error('Error importing tasks:', error)
    return NextResponse.json(
      { error: 'Failed to import tasks' },
      { status: 500 }
    )
  }
}
