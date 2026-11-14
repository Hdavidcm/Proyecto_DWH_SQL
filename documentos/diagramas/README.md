# Diagramas del Data Warehouse

Archivos editables en [diagrams.net](https://app.diagrams.net/). Descarga el archivo y selecciona **Archivo > Abrir desde > Dispositivo** para visualizarlo y editarlo.

| Diagrama | Archivo | Propósito |
| --- | --- | --- |
| Arquitectura SQL Server | [arquitectura SQL Server](Diagram%20SQL%20SERVER.drawio) | Fuentes, capas, objetos y consumo |
| Integración de fuentes | [integracion_fuentes](Diagrama%20Modelo%20de%20integracion.drawio) | Claves de cruce CRM/ERP tras transformación |
| Flujo de datos | [flujo_datos.drawio](Diagrama%20de%20Flujo.drawio) | Linaje entre capas y dependencias Gold |
| Modelo estrella | [modelo_estrella.drawio](Data%20Model.drawio) | Dimensiones y detalle de ventas |

[Ver modelo estrella en PDF](Data%20Model.pdf)

## Alcance
Copias corregidas de los cuatro diagramas proporcionados por el autor. Los originales adjuntos se conservan sin cambios. La implementación de base sigue el ejercicio de Data with Baraa, como se explica en el README principal.

- Los nombres se alinean con los scripts revisados.
- La categoría se integra mediante `erp_px_cat_g1v2.id = crm_prd_info.cat_id` en Silver.
- Gold utiliza vistas: las marcas PK/FK representan roles lógicos, no restricciones físicas.
- Las claves calculadas con `ROW_NUMBER()` no son persistentes.
- `fact_sales` consulta las dimensiones Gold para obtener las claves.
- BI/reporting se presenta como consumo previsto; Machine Learning como potencial, no implementado.

## Revisión
Se comprobaron etiquetas, identificadores únicos, referencias de conectores y balance de etiquetas XML. No se verificó el renderizado en draw.io: revisar distribución, rutas de conectores y legibilidad al abrir los archivos. Las notas añadidas amplían el área del diagrama; al exportar, usar recorte al contenido o ajustar la página.

Los diagramas documentan el código y no sustituyen la [evidencia de validación](../resultados_validacion.md).
