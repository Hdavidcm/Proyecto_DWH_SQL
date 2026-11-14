# Data Warehouse con SQL Server
**T-SQL · ETL · Modelado dimensional · Arquitectura Bronze / Silver / Gold**

Proyecto práctico en desarrollo para integrar archivos de fuentes CRM y ERP, transformar datos y exponer un modelo dimensional de clientes, productos y ventas.

El repositorio contiene scripts de ingesta, transformación, vistas analíticas y consultas de validación. Los resultados de consultas ejecutadas en la instancia local del autor se documentan en [Resultados de validación](documentos/resultados_validacion.md), con sus excepciones y alcance.

## Objetivo
Construir una base de datos analítica que permita relacionar ventas con clientes, productos, categorías y países. El proyecto permite practicar cómo convertir datos de origen heterogéneos en estructuras consistentes para el análisis.

## Arquitectura
| Capa | Responsabilidad | Implementación |
| --- | --- | --- |
| Bronze | Ingesta de los archivos de origen | Seis tablas y procedimiento de carga mediante `BULK INSERT` |
| Silver | Limpieza, estandarización y transformación | Seis tablas, metadato de carga y procedimiento T-SQL |
| Gold | Consumo analítico | Vistas `dim_customers`, `dim_products` y `fact_sales` |

El [modelo de datos y las decisiones técnicas](documentos/arquitectura.md) explican las relaciones y sus limitaciones.

## Diagramas del proyecto

Los cuatro diagramas están disponibles en PDF para consulta y en draw.io para edición. Consulta el [índice de diagramas](documentos/diagramas/README.md).

| Perspectiva | Visualizar | Editar | Propósito |
| --- | --- | --- | --- |
| Arquitectura | [PDF](documentos/diagramas/Diagram%20SQL%20SERVER.drawio.pdf) | [draw.io](documentos/diagramas/Diagram%20SQL%20SERVER.drawio) | Fuentes, capas, objetos y consumo |
| Integración | [PDF](documentos/diagramas/Diagrama%20Modelo%20de%20integracion.drawio.pdf) | [draw.io](documentos/diagramas/Diagrama%20Modelo%20de%20integracion.drawio) | Relación conceptual entre fuentes CRM y ERP |
| Linaje | [PDF](documentos/diagramas/Diagrama%20de%20Flujo.drawio.pdf) | [draw.io](documentos/diagramas/Diagrama%20de%20Flujo.drawio) | Recorrido de los datos entre capas |
| Modelo analítico | [PDF](documentos/diagramas/Data%20Model.pdf) | [draw.io](documentos/diagramas/Data%20Model.drawio) | Esquema estrella de ventas |

Los PDF se pueden consultar desde GitHub; los archivos editables se abren con draw.io/diagrams.net. Gold se implementa con vistas y las relaciones representan el modelo lógico.

## Capacidades presentes en el código
- **Ingesta:** carga completa de seis CSV con `TRUNCATE` y `BULK INSERT`.
- **Deduplicación:** selección del registro de cliente más reciente mediante `ROW_NUMBER()`.
- **Estandarización:** normalización de género, estado civil, país y línea de producto.
- **Transformación:** limpieza de cadenas, tratamiento de nulos y adecuación de claves para integrar fuentes.
- **Fechas de productos:** cálculo de fecha final mediante `LEAD()`.
- **Consistencia comercial:** reglas para recalcular importes y precios; protección contra división por cero con `NULLIF`.
- **Modelado:** integración mediante `LEFT JOIN` y exposición de dimensiones y hechos como vistas.
- **Seguimiento básico:** mensajes de duración y captura de errores con `TRY/CATCH`.
- **Validación:** consultas exploratorias y controles sobre duplicados, nulos, fechas e importes.

## Estructura
| Ruta | Contenido |
| --- | --- |
| [Scripts/init_database.sql](Scripts/init_database.sql) | Inicialización de la base y esquemas |
| [Scripts/bronze](Scripts/bronze) | DDL e ingesta de fuentes |
| [Scripts/silver](Scripts/silver) | DDL y transformaciones |
| [Scripts/gold/ddl_gold.sql](Scripts/gold/ddl_gold.sql) | Dimensiones y hechos como vistas |
| [Pruebas/Test_Silver_Layer.sql](Pruebas/Test_Silver_Layer.sql) | Consultas de diagnóstico y validación |
| [datasets/README.md](datasets/README.md) | Archivos requeridos y configuración de rutas |
| [documentos/arquitectura.md](documentos/arquitectura.md) | Modelo, reglas y decisiones |
| [documentos/roadmap.md](documentos/roadmap.md) | Estado, pendientes y criterios de aceptación |

## Datos de origen

Los seis CSV del ejercicio están incluidos en el repositorio:

| Fuente | Archivo | Destino Bronze |
| --- | --- | --- |
| CRM | [cust_info.csv](datasets/Source_CRM/cust_info.csv) | `bronze.crm_cust_info` |
| CRM | [prd_info.csv](datasets/Source_CRM/prd_info.csv) | `bronze.crm_prd_info` |
| CRM | [sales_details.csv](datasets/Source_CRM/sales_details.csv) | `bronze.crm_sales_details` |
| ERP | [CUST_AZ12.csv](datasets/Source_ERP/CUST_AZ12.csv) | `bronze.erp_cust_az12` |
| ERP | [LOC_A101.csv](datasets/Source_ERP/LOC_A101.csv) | `bronze.erp_loc_a101` |
| ERP | [PX_CAT_G1V2.csv](datasets/Source_ERP/PX_CAT_G1V2.csv) | `bronze.erp_px_cat_g1v2` |

Descarga el repositorio completo con **Code → Download ZIP**, o clónalo para conservar la estructura de carpetas. Consulta la [guía de datos](datasets/README.md) para configurar la carga.

## Ejecución local
### Requisitos
- Una instancia de SQL Server compatible con `CREATE OR ALTER` y `TRIM` (SQL Server 2017 o posterior).
- SQL Server Management Studio u otro cliente que interprete los separadores `GO`.
- Permisos para crear la base, tablas, vistas y procedimientos, y realizar cargas masivas.
- Los seis CSV del ejercicio y acceso de lectura a ellos desde el servicio de SQL Server.

> **Atención:** `init_database.sql` elimina la base `DataWarehouse` si existe. Los DDL de Bronze y Silver recrean tablas y los procedimientos vacían sus destinos antes de recargar. Utiliza una instancia de práctica y revisa los scripts antes de ejecutarlos.

### Preparación
1. Descarga o clona este repositorio. Los CSV están en `datasets/Source_CRM/` y `datasets/Source_ERP/`.
2. Ajusta las seis rutas de `BULK INSERT` en [proc_load_bronze.sql](Scripts/bronze/proc_load_bronze.sql) a la ubicación local de esos archivos. Respeta los nombres y mayúsculas de la tabla anterior; las rutas personales actuales no se actualizan automáticamente al descargar el repositorio.
3. Verifica que la cuenta del servicio SQL Server pueda leer esa ubicación. Si SQL Server está en otra máquina, las rutas deben ser accesibles desde esa máquina.

### Orden de ejecución
Ejecuta cada archivo completo en este orden. Tras inicializar la base, selecciona explícitamente `DataWarehouse` en cada nueva ventana del cliente.

| Paso | Archivo o comando | Acción |
| --- | --- | --- |
| 1 | `Scripts/init_database.sql` | Crear la base y los esquemas |
| 2 | `Scripts/bronze/ddl_bronze.sql` | Crear tablas Bronze |
| 3 | `Scripts/bronze/proc_load_bronze.sql` | Crear procedimiento Bronze |
| 4 | `USE DataWarehouse; EXEC bronze.load_bronze;` | Cargar los CSV |
| 5 | `Scripts/silver/ddl_silver.sql` | Crear tablas Silver |
| 6 | `Scripts/silver/proc_load_silver.sql` | Crear procedimiento Silver |
| 7 | `USE DataWarehouse; EXEC silver.load_silver;` | Transformar y cargar Silver |
| 8 | `Scripts/gold/ddl_gold.sql` | Crear las vistas Gold |
| 9 | `Pruebas/Test_Silver_Layer.sql` | Inspeccionar diagnósticos y controles |

Revisa los mensajes y los datos después de cada carga. Actualmente el bloque `CATCH` imprime el error sin relanzarlo: que el cliente termine un comando no garantiza una carga correcta. No continúes a la siguiente capa si la anterior falló.

### Consulta de ejemplo
Después de crear las vistas, esta consulta permite explorar las ventas por categoría:
```sql
USE DataWarehouse;
GO

SELECT
    p.category,
    SUM(CAST(f.sales_amount AS BIGINT)) AS total_sales,
    SUM(CAST(f.quantity AS BIGINT)) AS total_quantity
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
    ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY total_sales DESC;
```

## Validación y resultados
El script actual combina consultas exploratorias con controles de inconsistencias. Un resultado con filas puede ser esperado en un diagnóstico de Bronze; debe interpretarse según la regla evaluada. Todavía no constituye una batería automatizada de pruebas.

Resultados reportados desde SSMS por el autor (11 y 13 de noviembre de 2026):

| Indicador | Resultado |
| --- | ---: |
| Clientes CRM Bronze / Silver | 18.493 / 18.484 |
| IDs nulos excluidos / duplicados excedentes | 3 / 6 |
| Clientes / productos en Gold | 18.484 / 295 |
| Ventas Silver / Gold | 60.398 / 60.398 |
| Importe total Silver / Gold | 29.356.250,00 / 29.356.250,00 |
| Ventas sin cliente o producto | 0 |
| Inconsistencias aritméticas según las reglas evaluadas | 0 |
| Fechas de pedido inválidas representadas como NULL | 19 |

Las 19 fechas proceden de 17 ceros y 2 valores con longitud incorrecta. Las filas se conservan y requieren un grupo “Sin fecha” en análisis temporales. No se ha atribuido moneda al importe.

Consulta el [informe completo](documentos/resultados_validacion.md) y ejecuta [Validaciones_Portafolio.sql](Pruebas/Validaciones_Portafolio.sql) para repetir los controles. La evidencia corresponde a la base local existente; no acredita una instalación desde cero ni una comparación fila a fila. Siguen pendientes versión del motor, tiempos de carga y conteos completos de las seis tablas por capa.

## Limitaciones conocidas
- Los seis CSV están incluidos; las rutas de `BULK INSERT` siguen siendo locales y deben ajustarse antes de ejecutar.
- Las cargas son completas; no existe carga incremental ni orquestación programada.
- Los errores se imprimen, sin `THROW`, rollback global ni registro persistente de ejecución.
- Validar que una fecha tenga ocho dígitos no garantiza que sea una fecha válida.
- Gold utiliza vistas con claves generadas por `ROW_NUMBER()`; esas claves pueden cambiar si cambian las filas de origen.
- La dimensión de productos solo expone registros vigentes; no resuelve el cruce histórico de ventas por fecha de vigencia.
- No se incluyen Python, Pandas, infraestructura cloud ni una implementación empresarial.

## Origen y alcance
La implementación parte del tutorial de **Data with Baraa** y se utiliza como práctica complementaria a la formación en SQL Server realizada en Coursera.

- Referencia del autor: [Data with Baraa](https://www.youtube.com/@DataWithBaraa).
- No se presenta como un proyecto oficial de Coursera, ni como una implementación empresarial.
- El alcance guiado, las decisiones observables y las mejoras futuras se documentan en [arquitectura](documentos/arquitectura.md) y [roadmap](documentos/roadmap.md).
- Las mejoras propuestas no se consideran implementadas hasta incorporar su código y evidencia.

## Autor
[Heiler David Cabrera](https://github.com/Hdavidcm)

## Licencia
Consulta [LICENSE](LICENSE). La licencia del repositorio no sustituye las condiciones de uso de los datasets o materiales de terceros.
