'use client'

import { useState, useCallback } from 'react'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { ScrollArea } from '@/components/ui/scroll-area'
import {
  Upload,
  FileSpreadsheet,
  Download,
  CheckCircle2,
  XCircle,
  AlertCircle,
  Loader2,
  X,
  FileWarning
} from 'lucide-react'
import * as XLSX from 'xlsx'

interface ImportTasksModalProps {
  projectId: string
  open: boolean
  onOpenChange: (open: boolean) => void
  onTasksImported: () => void
}

interface PreviewTask {
  rowNumber: number
  title: string
  description: string | null
  priority: string
  dueDate: string | null
  sprintId: number | null
  epicId: number | null
  errors: string[]
  isValid: boolean
}

interface PreviewResponse {
  preview: boolean
  totalRows: number
  validCount: number
  invalidCount: number
  tasks: PreviewTask[]
  sprints: { id: number; name: string }[]
  epics: { id: number; name: string }[]
}

interface ImportResponse {
  success: boolean
  imported: number
  skipped: number
  tasks: { id: number; title: string }[]
  errors: { rowNumber: number; title: string; errors: string[] }[]
}

const priorityLabels: Record<string, string> = {
  LOW: 'Baja',
  MEDIUM: 'Media',
  HIGH: 'Alta',
  URGENT: 'Urgente'
}

const priorityColors: Record<string, string> = {
  LOW: 'bg-gray-100 text-gray-700',
  MEDIUM: 'bg-yellow-100 text-yellow-700',
  HIGH: 'bg-orange-100 text-orange-700',
  URGENT: 'bg-red-100 text-red-700'
}

export function ImportTasksModal({
  projectId,
  open,
  onOpenChange,
  onTasksImported
}: ImportTasksModalProps) {
  const [file, setFile] = useState<File | null>(null)
  const [isDragging, setIsDragging] = useState(false)
  const [isLoading, setIsLoading] = useState(false)
  const [isImporting, setIsImporting] = useState(false)
  const [preview, setPreview] = useState<PreviewResponse | null>(null)
  const [importResult, setImportResult] = useState<ImportResponse | null>(null)
  const [error, setError] = useState<string | null>(null)

  const resetState = useCallback(() => {
    setFile(null)
    setPreview(null)
    setImportResult(null)
    setError(null)
    setIsLoading(false)
    setIsImporting(false)
  }, [])

  const handleClose = useCallback(() => {
    resetState()
    onOpenChange(false)
  }, [resetState, onOpenChange])

  const downloadTemplate = useCallback(() => {
    // Create template workbook
    const wb = XLSX.utils.book_new()
    const templateData = [
      {
        'Título': 'Ejemplo: Implementar login',
        'Descripción': 'Descripción opcional de la tarea',
        'Prioridad': 'Media',
        'Fecha Vencimiento': '25/01/2026',
        'Sprint': '',
        'Épica': ''
      },
      {
        'Título': 'Ejemplo: Diseñar dashboard',
        'Descripción': '',
        'Prioridad': 'Alta',
        'Fecha Vencimiento': '',
        'Sprint': '',
        'Épica': ''
      }
    ]
    const ws = XLSX.utils.json_to_sheet(templateData)

    // Set column widths
    ws['!cols'] = [
      { wch: 35 }, // Título
      { wch: 40 }, // Descripción
      { wch: 12 }, // Prioridad
      { wch: 18 }, // Fecha Vencimiento
      { wch: 15 }, // Sprint
      { wch: 15 }, // Épica
    ]

    XLSX.utils.book_append_sheet(wb, ws, 'Tareas')

    // Download
    XLSX.writeFile(wb, 'plantilla_importar_tareas.xlsx')
  }, [])

  const handleDragOver = useCallback((e: React.DragEvent) => {
    e.preventDefault()
    setIsDragging(true)
  }, [])

  const handleDragLeave = useCallback((e: React.DragEvent) => {
    e.preventDefault()
    setIsDragging(false)
  }, [])

  const handleDrop = useCallback((e: React.DragEvent) => {
    e.preventDefault()
    setIsDragging(false)

    const droppedFile = e.dataTransfer.files[0]
    if (droppedFile) {
      handleFileSelect(droppedFile)
    }
  }, [])

  const handleFileSelect = async (selectedFile: File) => {
    // Validate file type
    const validExtensions = ['.xlsx', '.xls', '.csv']
    const extension = selectedFile.name.toLowerCase().slice(selectedFile.name.lastIndexOf('.'))

    if (!validExtensions.includes(extension)) {
      setError('Tipo de archivo no válido. Use Excel (.xlsx, .xls) o CSV')
      return
    }

    setFile(selectedFile)
    setError(null)
    setPreview(null)
    setImportResult(null)

    // Upload for preview
    setIsLoading(true)
    try {
      const formData = new FormData()
      formData.append('file', selectedFile)
      formData.append('previewOnly', 'true')

      const response = await fetch(`/api/projects/${projectId}/tasks/import`, {
        method: 'POST',
        body: formData
      })

      const data = await response.json()

      if (!response.ok) {
        setError(data.error || 'Error al procesar el archivo')
        return
      }

      setPreview(data)
    } catch (err) {
      console.error('Error uploading file:', err)
      setError('Error al procesar el archivo')
    } finally {
      setIsLoading(false)
    }
  }

  const handleFileInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const selectedFile = e.target.files?.[0]
    if (selectedFile) {
      handleFileSelect(selectedFile)
    }
  }

  const handleImport = async () => {
    if (!file) return

    setIsImporting(true)
    setError(null)

    try {
      const formData = new FormData()
      formData.append('file', file)
      formData.append('previewOnly', 'false')

      const response = await fetch(`/api/projects/${projectId}/tasks/import`, {
        method: 'POST',
        body: formData
      })

      const data = await response.json()

      if (!response.ok) {
        setError(data.error || 'Error al importar tareas')
        return
      }

      setImportResult(data)
      onTasksImported()
    } catch (err) {
      console.error('Error importing tasks:', err)
      setError('Error al importar tareas')
    } finally {
      setIsImporting(false)
    }
  }

  return (
    <Dialog open={open} onOpenChange={handleClose}>
      <DialogContent className="sm:max-w-[700px] max-h-[85vh] overflow-hidden flex flex-col">
        <DialogHeader>
          <div className="flex items-center gap-2">
            <FileSpreadsheet className="h-5 w-5 text-green-600" />
            <DialogTitle>Importar Tareas desde Excel</DialogTitle>
          </div>
          <DialogDescription>
            Sube un archivo Excel con las tareas a importar. Puedes descargar la plantilla para ver el formato esperado.
          </DialogDescription>
        </DialogHeader>

        <div className="flex-1 overflow-hidden flex flex-col gap-4">
          {/* Import Result View */}
          {importResult ? (
            <div className="space-y-4">
              <div className="flex items-center gap-3 p-4 bg-green-50 rounded-lg border border-green-200">
                <CheckCircle2 className="h-8 w-8 text-green-600" />
                <div>
                  <h3 className="font-semibold text-green-800">Importación completada</h3>
                  <p className="text-sm text-green-700">
                    {importResult.imported} tarea{importResult.imported !== 1 ? 's' : ''} importada{importResult.imported !== 1 ? 's' : ''} correctamente
                    {importResult.skipped > 0 && `, ${importResult.skipped} omitida${importResult.skipped !== 1 ? 's' : ''}`}
                  </p>
                </div>
              </div>

              {importResult.errors.length > 0 && (
                <div className="space-y-2">
                  <h4 className="text-sm font-medium text-gray-700">Filas con errores (omitidas):</h4>
                  <ScrollArea className="h-32 rounded border">
                    <div className="p-2 space-y-1">
                      {importResult.errors.map((err, i) => (
                        <div key={i} className="text-sm text-red-600 flex items-start gap-2">
                          <span className="font-medium">Fila {err.rowNumber}:</span>
                          <span>{err.errors.join(', ')}</span>
                        </div>
                      ))}
                    </div>
                  </ScrollArea>
                </div>
              )}
            </div>
          ) : (
            <>
              {/* Download Template Button */}
              <div className="flex justify-end">
                <Button variant="outline" size="sm" onClick={downloadTemplate}>
                  <Download className="h-4 w-4 mr-2" />
                  Descargar Plantilla
                </Button>
              </div>

              {/* Upload Area */}
              {!preview && (
                <div
                  className={`
                    border-2 border-dashed rounded-lg p-8 text-center transition-colors
                    ${isDragging ? 'border-blue-500 bg-blue-50' : 'border-gray-300 hover:border-gray-400'}
                    ${error ? 'border-red-300 bg-red-50' : ''}
                  `}
                  onDragOver={handleDragOver}
                  onDragLeave={handleDragLeave}
                  onDrop={handleDrop}
                >
                  {isLoading ? (
                    <div className="flex flex-col items-center gap-3">
                      <Loader2 className="h-10 w-10 text-blue-500 animate-spin" />
                      <p className="text-gray-600">Procesando archivo...</p>
                    </div>
                  ) : (
                    <>
                      <Upload className={`h-10 w-10 mx-auto mb-3 ${error ? 'text-red-400' : 'text-gray-400'}`} />
                      <p className="text-gray-600 mb-2">
                        Arrastra tu archivo Excel aquí o
                      </p>
                      <label className="cursor-pointer">
                        <span className="text-blue-600 hover:underline">selecciona un archivo</span>
                        <input
                          type="file"
                          className="hidden"
                          accept=".xlsx,.xls,.csv"
                          onChange={handleFileInputChange}
                        />
                      </label>
                      <p className="text-xs text-gray-400 mt-2">
                        Formatos soportados: .xlsx, .xls, .csv
                      </p>
                      {error && (
                        <p className="text-sm text-red-600 mt-3 flex items-center justify-center gap-1">
                          <AlertCircle className="h-4 w-4" />
                          {error}
                        </p>
                      )}
                    </>
                  )}
                </div>
              )}

              {/* Preview */}
              {preview && (
                <div className="space-y-3 flex-1 overflow-hidden flex flex-col">
                  {/* File info */}
                  <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                    <div className="flex items-center gap-2">
                      <FileSpreadsheet className="h-5 w-5 text-green-600" />
                      <span className="text-sm font-medium">{file?.name}</span>
                    </div>
                    <Button variant="ghost" size="sm" onClick={resetState}>
                      <X className="h-4 w-4" />
                    </Button>
                  </div>

                  {/* Summary */}
                  <div className="flex gap-4">
                    <div className="flex items-center gap-2 px-3 py-2 bg-green-50 rounded-lg">
                      <CheckCircle2 className="h-4 w-4 text-green-600" />
                      <span className="text-sm text-green-700">
                        {preview.validCount} válida{preview.validCount !== 1 ? 's' : ''}
                      </span>
                    </div>
                    {preview.invalidCount > 0 && (
                      <div className="flex items-center gap-2 px-3 py-2 bg-red-50 rounded-lg">
                        <XCircle className="h-4 w-4 text-red-600" />
                        <span className="text-sm text-red-700">
                          {preview.invalidCount} con errores
                        </span>
                      </div>
                    )}
                  </div>

                  {/* Tasks Preview Table */}
                  <ScrollArea className="flex-1 border rounded-lg">
                    <div className="min-w-full">
                      {/* Header */}
                      <div className="grid grid-cols-12 gap-2 p-2 bg-gray-50 border-b text-xs font-medium text-gray-600 sticky top-0">
                        <div className="col-span-1">#</div>
                        <div className="col-span-5">Título</div>
                        <div className="col-span-2">Prioridad</div>
                        <div className="col-span-2">Fecha</div>
                        <div className="col-span-2">Estado</div>
                      </div>

                      {/* Rows */}
                      {preview.tasks.map((task) => (
                        <div
                          key={task.rowNumber}
                          className={`grid grid-cols-12 gap-2 p-2 border-b text-sm items-center ${
                            task.isValid ? 'bg-white' : 'bg-red-50'
                          }`}
                        >
                          <div className="col-span-1 text-gray-500">{task.rowNumber}</div>
                          <div className="col-span-5 truncate" title={task.title || '(sin título)'}>
                            {task.title || <span className="text-red-500 italic">(sin título)</span>}
                          </div>
                          <div className="col-span-2">
                            <Badge className={`text-xs ${priorityColors[task.priority] || ''}`}>
                              {priorityLabels[task.priority] || task.priority}
                            </Badge>
                          </div>
                          <div className="col-span-2 text-gray-600 text-xs">
                            {task.dueDate || '-'}
                          </div>
                          <div className="col-span-2">
                            {task.isValid ? (
                              <CheckCircle2 className="h-4 w-4 text-green-500" />
                            ) : (
                              <div className="flex items-center gap-1" title={task.errors.join(', ')}>
                                <FileWarning className="h-4 w-4 text-red-500" />
                                <span className="text-xs text-red-600 truncate">
                                  {task.errors[0]}
                                </span>
                              </div>
                            )}
                          </div>
                        </div>
                      ))}
                    </div>
                  </ScrollArea>

                  {error && (
                    <p className="text-sm text-red-600 flex items-center gap-1">
                      <AlertCircle className="h-4 w-4" />
                      {error}
                    </p>
                  )}
                </div>
              )}
            </>
          )}
        </div>

        <DialogFooter>
          {importResult ? (
            <Button onClick={handleClose}>Cerrar</Button>
          ) : (
            <>
              <Button variant="outline" onClick={handleClose}>
                Cancelar
              </Button>
              {preview && preview.validCount > 0 && (
                <Button onClick={handleImport} disabled={isImporting}>
                  {isImporting ? (
                    <>
                      <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                      Importando...
                    </>
                  ) : (
                    <>
                      <Upload className="h-4 w-4 mr-2" />
                      Importar {preview.validCount} tarea{preview.validCount !== 1 ? 's' : ''}
                    </>
                  )}
                </Button>
              )}
            </>
          )}
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
