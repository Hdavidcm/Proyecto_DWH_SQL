# Datos de entrada

Los seis archivos CSV del ejercicio están incluidos en este repositorio y corresponden a las fuentes CRM y ERP de la práctica basada en Data with Baraa.

## Archivos disponibles

| Fuente | Archivo | Tabla Bronze |
| --- | --- | --- |
| CRM | [cust_info.csv](Source_CRM/cust_info.csv) | `bronze.crm_cust_info` |
| CRM | [prd_info.csv](Source_CRM/prd_info.csv) | `bronze.crm_prd_info` |
| CRM | [sales_details.csv](Source_CRM/sales_details.csv) | `bronze.crm_sales_details` |
| ERP | [CUST_AZ12.csv](Source_ERP/CUST_AZ12.csv) | `bronze.erp_cust_az12` |
| ERP | [LOC_A101.csv](Source_ERP/LOC_A101.csv) | `bronze.erp_loc_a101` |
| ERP | [PX_CAT_G1V2.csv](Source_ERP/PX_CAT_G1V2.csv) | `bronze.erp_px_cat_g1v2` |

Puedes descargarlos junto con el repositorio mediante **Code → Download ZIP** o clonarlo para conservar las carpetas.

## Configuración de la carga

1. Ubica las carpetas `datasets/Source_CRM/` y `datasets/Source_ERP/` en tu copia local.
2. Revisa [ddl_bronze.sql](../Scripts/bronze/ddl_bronze.sql) para comprobar el orden y los tipos de columnas esperados.
3. Cambia las seis rutas de `BULK INSERT` en [proc_load_bronze.sql](../Scripts/bronze/proc_load_bronze.sql). No es necesario ejecutar el DDL para editar las rutas.
4. Utiliza los nombres exactos de la tabla anterior. Los CSV de ERP tienen nombres en mayúsculas.
5. Verifica acceso de lectura desde la cuenta del servicio SQL Server. Si el motor está en otra máquina, la ruta debe existir o ser accesible desde esa máquina.

Ejemplo de ruta local tras descomprimir:
```text
C:\ruta_del_proyecto\datasets\Source_CRM\cust_info.csv
```

Las rutas personales actualmente presentes en el procedimiento no se actualizan al descargar el repositorio. Ajustarlas es un paso manual.

La configuración de importación actual omite el encabezado (`FIRSTROW = 2`) y utiliza coma como separador. Comprueba separadores, codificación y orden de campos antes de ejecutar. No se presupone que el cargador actual admita cualquier variante de CSV.

## Origen

Los datos forman parte del ejercicio guiado de Data with Baraa. Consulta la [atribución del proyecto](../README.md#origen-y-alcance). La referencia exacta al material original sigue pendiente; la inclusión de los archivos permite acceder a ellos desde este repositorio sin buscar en el canal.

Volver al [README principal](../README.md).
