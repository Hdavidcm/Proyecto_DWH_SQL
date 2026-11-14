# Resultados de validación local

## Procedencia y alcance
Resultados de consultas ejecutadas por Heiler David Cabrera en su instancia local de SQL Server y compartidos desde SSMS el **11 y 13 de noviembre de 2026** (UTC-05:00). Se transcriben las salidas proporcionadas; no constituyen una ejecución independiente ni certifican una instalación desde cero. No se dispone de versión del motor, tiempos de carga o commit exacto de la copia local.

Consultas reproducibles: [Pruebas/Validaciones_Portafolio.sql](../Pruebas/Validaciones_Portafolio.sql). El script solo lee datos. Su salida dependerá del estado actual de la base.

## Clientes y volumen
| Control | Resultado observado |
| --- | ---: |
| Filas de clientes CRM en Bronze | 18.493 |
| Filas con ID nulo en Bronze | 3 |
| Filas duplicadas excedentes con ID no nulo en Bronze | 6 |
| Clientes únicos no nulos en Bronze | 18.484 |
| Filas de clientes CRM en Silver | 18.484 |
| Filas de clientes en Gold | 18.484 |
| Productos en Gold | 295 |
| Registros de ventas en Gold | 60.398 |

La diferencia de nueve filas entre Bronze y Silver queda explicada por tres IDs nulos y seis duplicados excedentes. No equivale a nueve clientes duplicados.

## Integridad y consistencia
| Control | Resultado observado |
| --- | ---: |
| Grupos con ID de cliente duplicado o nulo en Silver | 0 |
| Grupos con customer_id duplicado o nulo en Gold | 0 |
| Grupos con product_number duplicado o nulo en Gold | 0 |
| Ventas con customer_key nulo en Gold | 0 |
| Ventas con product_key nulo en Gold | 0 |
| Ventas con importes, cantidades o precios nulos, no positivos o incoherentes con cantidad × precio | 0 |

Los controles son consultas de diagnóstico; no imponen restricciones ni bloquean una carga.

## Reconciliación Silver–Gold
| Capa | Filas de ventas | Importe total |
| --- | ---: | ---: |
| Silver | 60.398 | 29.356.250,00 |
| Gold | 60.398 | 29.356.250,00 |

El volumen y el importe agregado coinciden en esta ejecución. Esto no es una comparación fila a fila ni una reconciliación de importes entre Bronze y Silver. No se atribuye moneda al importe porque no se ha confirmado su unidad.

## Fechas y excepción documentada
| Control | Resultado observado |
| --- | ---: |
| Ventas sin fecha de pedido | 19 |
| Ventas sin fecha de envío | 0 |
| Ventas sin fecha de vencimiento | 0 |
| Envíos anteriores al pedido | 0 |
| Vencimientos anteriores al pedido | 0 |

Los 19 registros representan aproximadamente el **0,031 %** de las ventas. Las comparaciones cronológicas excluyen implícitamente los pedidos con fecha nula.

La inspección de Bronze explica esos casos:
- **17** fechas de pedido con valor cero.
- **2** fechas con longitud incorrecta: `32154` y `5489`.
- La transformación de Silver las representa como `NULL` y conserva las líneas de ventas.

**Tratamiento analítico:** mostrar estas líneas como “Sin fecha” en análisis por fecha de pedido. No inferir una fecha a partir de otra línea de la misma orden sin una regla de negocio aprobada. Los totales globales pueden incluirlas; un filtro temporal puede excluirlas.

### Caso SO69215
| Fecha de pedido en Silver | Importe | Cantidad | Precio |
| --- | ---: | ---: | ---: |
| 2013-10-26 | 2.295 | 1 | 2.295 |
| NULL | 35 | 1 | 35 |
| NULL | 5 | 1 | 5 |
| 2013-10-26 | 35 | 1 | 35 |

En Bronze se observó una línea de esta orden con fecha `32154` e importe `-35`. En Silver aparece una línea sin fecha con importe 35, cantidad 1 y precio 35, consistente con la regla de recálculo del ejercicio. Las salidas compartidas no incluyen una clave única de línea para probar trazabilidad fila a fila.

**Límite de negocio:** consistencia aritmética no prueba que un negativo sea erróneo. En un entorno real habría que distinguir errores, devoluciones y notas de crédito antes de convertirlo en positivo.

## Interpretación
Los controles observados respaldan la depuración de clientes, correspondencia con dimensiones, consistencia aritmética y conservación de agregados Silver–Gold. La calidad no se considera absoluta: se conserva una excepción conocida de fechas y siguen pendientes controles adicionales.

## Pendientes
- Conteos completos de las seis tablas por capa.
- Versión de SQL Server, tiempos y evidencia de una ejecución desde cero.
- Claves sustitutas persistentes, vigencias de producto y validaciones ERP.
- Validación de reglas de negocio para negativos y tratamiento de fechas sin valor.
