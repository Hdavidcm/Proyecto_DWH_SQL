# Estado y próximos pasos

El estado combina revisión del código y [resultados locales reportados por el autor](resultados_validacion.md). La reproducción desde una base vacía sigue pendiente.

## Código presente
- [x] Inicialización de DataWarehouse y esquemas.
- [x] Tablas y procedimiento de ingesta Bronze.
- [x] Tablas y procedimiento de transformación Silver.
- [x] Vistas de clientes, productos y ventas en Gold.
- [x] Consultas exploratorias y validaciones parciales.
- [x] Documentación de arquitectura e instrucciones de ejecución.
- [x] Documentación de controles ejecutados en la base local existente.
- [ ] Ejecución completa reproducida desde una base vacía.

## Prioridad 1: reproducibilidad
- [ ] Añadir referencia exacta del tutorial y de sus datasets.
- [ ] Ejecutar desde una base de práctica vacía siguiendo el README.
- [ ] Registrar versión de SQL Server, filas y duración.
- [ ] Sustituir las rutas personales por una configuración documentada.

**Criterio de aceptación:** otra persona puede obtener los datos y ejecutar el proyecto siguiendo instrucciones explícitas, sin adivinar rutas u orden de pasos.

## Prioridad 2: validación y robustez
- [ ] Tratar fechas inválidas con conversión tolerante y registrar los rechazos.
- [ ] Propagar errores con THROW y definir la estrategia de recuperación de una carga parcial.
- [ ] Validar duplicados en ERP antes de integrar dimensiones.
- [x] Añadir consultas de diagnóstico Gold de unicidad de claves de negocio y ventas sin correspondencia.
- [ ] Convertir los diagnósticos en controles automatizados que detecten fallos.
- [ ] Separar diagnósticos Bronze de comprobaciones Silver/Gold.
- [ ] Revisar precisión numérica de importes, costos y precios antes de cambiar tipos.

**Criterio de aceptación:** incluir casos con fecha inválida, duplicados y fallo de carga; documentar resultado esperado y observado. Un fallo no debe parecer una ejecución exitosa.

## Prioridad 3: aportes propios
Estas son propuestas pendientes, no capacidades implementadas:
- [ ] Crear un registro persistente de ejecución por tabla y capa.
- [ ] Automatizar una validación de archivos con Python y Pandas.
- [ ] Diseñar una alternativa con claves dimensionales persistentes.
- [ ] Evaluar la asociación histórica de ventas y versiones de producto.
- [ ] Publicar una consulta de negocio con resultados obtenidos del dataset.

**Criterio de aceptación:** cada aporte incluye problema, decisión, código, comprobación y limitaciones.

## Registro de decisiones
Completar al implementar cada mejora:

| Fecha | Problema | Decisión y alternativa | Archivo o commit | Evidencia |
| --- | --- | --- | --- | --- |
| Pendiente | Pendiente | Pendiente | Pendiente | Pendiente |

## Presentación del proyecto
La implementación de base sigue un tutorial de Data with Baraa. Mantener esa atribución y distinguir las ampliaciones propias. La formación en Coursera es contexto de aprendizaje; este repositorio no se presenta como un entregable oficial del programa.
