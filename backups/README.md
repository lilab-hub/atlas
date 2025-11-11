# Atlas Database Backups

Este directorio contiene los backups de la base de datos de Atlas.

## Contenido del Backup

El archivo de backup incluye:

1. **Estructura completa de la base de datos** (schema-only):
   - Todas las tablas
   - Índices
   - Constraints
   - Sequences
   - Tipos de datos personalizados

2. **Datos de las tablas de plantillas**:
   - `project_templates` - Plantillas de proyectos predefinidas (7 registros)
   - `template_states` - Estados de las plantillas (37 registros)

## Cómo Restaurar el Backup

### Opción 1: Restaurar en una base de datos vacía

```bash
# 1. Crear una nueva base de datos
createdb -U ernestomonge atlas_new

# 2. Restaurar el backup
psql -U ernestomonge -d atlas_new -f atlas_backup_complete_YYYYMMDD_HHMMSS.sql
```

### Opción 2: Restaurar en la base de datos existente (con precaución)

```bash
# 1. Hacer backup de la base de datos actual (opcional pero recomendado)
pg_dump -U ernestomonge -d lilab_ops_dev -F c -f lilab_ops_dev_backup_$(date +%Y%m%d).dump

# 2. Limpiar la base de datos
psql -U ernestomonge -d lilab_ops_dev -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

# 3. Restaurar el backup
psql -U ernestomonge -d lilab_ops_dev -f atlas_backup_complete_YYYYMMDD_HHMMSS.sql
```

### Opción 3: Usar Prisma (Recomendado para desarrollo)

```bash
# 1. Asegúrate de que las migraciones estén actualizadas
npm run db:migrate

# 2. Ejecutar el seed para cargar las plantillas
npm run db:seed
```

## Información Importante

- **NO incluye datos de usuarios, proyectos, tareas, etc.** - Solo estructura y plantillas
- Las tablas `project_templates` y `template_states` contienen datos de plantillas predefinidas
- El backup fue creado sin especificar propietarios (--no-owner) ni permisos (--no-acl) para mayor portabilidad
- Compatible con PostgreSQL 15+

## Verificar el Backup

Para verificar el contenido del backup sin restaurarlo:

```bash
# Ver las tablas en el backup
grep "CREATE TABLE" atlas_backup_complete_YYYYMMDD_HHMMSS.sql

# Ver los datos de plantillas
grep "COPY public.project_templates" atlas_backup_complete_YYYYMMDD_HHMMSS.sql -A 10
```

## Historial de Backups

- `atlas_backup_complete_20251110_213758.sql` - Backup inicial con estructura completa + datos de plantillas
