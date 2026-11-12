# Data Warehouse con SQL Server
**T-SQL · ETL · Modelado dimensional · Arquitectura Bronze / Silver / Gold**

Proyecto práctico en desarrollo para integrar archivos de fuentes CRM y ERP, transformar datos y exponer un modelo dimensional de clientes, productos y ventas.

El repositorio contiene scripts de ingesta, transformación, vistas analíticas y consultas de validación. La presencia del código no implica que todas las validaciones hayan sido ejecutadas satisfactoriamente; los resultados de ejecución están pendientes de documentar.

## Objetivo
Construir una base de datos analítica que permita relacionar ventas con clientes, productos, categorías y países. El proyecto permite practicar cómo convertir datos de origen heterogéneos en estructuras consistentes para el análisis.

## Arquitectura
| Capa | Responsabilidad | Implementación |
| --- | --- | --- |
| Bronze | Ingesta de los archivos de origen | Seis tablas y procedimiento de carga mediante `BULK INSERT` |
| Silver | Limpieza, estandarización y transformación | Seis tablas, metadato de carga y procedimiento T-SQL |
| Gold | Consumo analítico | Vistas `dim_customers`, `dim_products` y `fact_sales` |

El [modelo de datos y las decisiones técnicas](documentos/arquitectura.md) explican las relaciones y sus limitaciones.

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

## Ejecución local
### Requisitos
- Una instancia de SQL Server compatible con `CREATE OR ALTER` y `TRIM` (SQL Server 2017 o posterior).
- SQL Server Management Studio u otro cliente que interprete los separadores `GO`.
- Permisos para crear la base, tablas, vistas y procedimientos, y realizar cargas masivas.
- Los seis CSV del ejercicio y acceso de lectura a ellos desde el servicio de SQL Server.

> **Atención:** `init_database.sql` elimina la base `DataWarehouse` si existe. Los DDL de Bronze y Silver recrean tablas y los procedimientos vacían sus destinos antes de recargar. Utiliza una instancia de práctica y revisa los scripts antes de ejecutarlos.

### Preparación
1. Obtén los archivos del material original del ejercicio. Consulta [datasets/README.md](datasets/README.md).
2. Ajusta las seis rutas de `BULK INSERT` en `Scripts/bronze/proc_load_bronze.sql` a la ubicación real de los CSV.
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

Pendiente de registrar en una ejecución local:
- Conteos de filas por tabla y capa.
- Duplicados y nulos antes y después de las transformaciones.
- Ventas sin correspondencia en las dimensiones.
- Tiempos de carga y evidencia de las consultas analíticas.

## Limitaciones conocidas
- Los CSV no están incluidos y las rutas de carga son locales.
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
