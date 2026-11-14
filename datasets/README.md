# Datos de entrada

Los CSV del ejercicio no están incluidos en este repositorio.

## Archivos requeridos
| Fuente | Archivo | Tabla Bronze |
| --- | --- | --- |
| CRM | cust_info.csv | bronze.crm_cust_info |
| CRM | prd_info.csv | bronze.crm_prd_info |
| CRM | sales_details.csv | bronze.crm_sales_details |
| ERP | cust_az12.csv | bronze.erp_cust_az12 |
| ERP | loc_a101.csv | bronze.erp_loc_a101 |
| ERP | px_cat_g1v2.csv | bronze.erp_px_cat_g1v2 |

Obtén los archivos desde los materiales del tutorial original de Data with Baraa. La referencia general está en el README principal.

## Configuración
1. Mantén los nombres y la estructura de columnas del material original.
2. Revisa `Scripts/bronze/ddl_bronze.sql` para comprobar el orden de columnas esperado.
3. Cambia cada ruta de `BULK INSERT` en `Scripts/bronze/proc_load_bronze.sql`.
4. Verifica acceso de lectura desde el servicio SQL Server; la ruta no se resuelve desde el cliente SSMS.
5. Comprueba encabezados, separador y codificación antes de cargar.

La configuración actual omite la primera fila (`FIRSTROW = 2`) y utiliza coma como separador. El orden de los campos debe coincidir con las tablas. Los archivos con comas entrecomilladas requieren revisar el formato de importación: no se presupone que el cargador actual maneje cualquier CSV.

No añadas información empresarial, datos personales reales ni credenciales para completar el ejercicio.
