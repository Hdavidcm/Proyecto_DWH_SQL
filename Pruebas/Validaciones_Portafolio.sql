/*
Validaciones de solo lectura para el portafolio.
Ejecutar sobre una copia estable de DataWarehouse, sin cargas concurrentes.
Los resultados esperados son los observados en noviembre de 2026, no constantes
garantizadas para otros datasets. No modifica datos ni detiene cargas.
Ver documentos/resultados_validacion.md para procedencia y limitaciones.
*/
USE DataWarehouse;
GO

-- 1. Conteos observados: 18493, 18484, 18484, 295, 60398.
SELECT 'Bronze' AS capa, 'Clientes CRM' AS entidad, COUNT_BIG(*) AS filas
FROM bronze.crm_cust_info
UNION ALL SELECT 'Silver', 'Clientes CRM', COUNT_BIG(*) FROM silver.crm_cust_info
UNION ALL SELECT 'Gold', 'Clientes', COUNT_BIG(*) FROM gold.dim_customers
UNION ALL SELECT 'Gold', 'Productos', COUNT_BIG(*) FROM gold.dim_products
UNION ALL SELECT 'Gold', 'Ventas', COUNT_BIG(*) FROM gold.fact_sales;

-- 2. Descomposicion observada: 18493 = 3 + 6 + 18484.
-- COUNT sobre columnas nulas puede mostrar una advertencia informativa.
SELECT COUNT_BIG(*) AS filas_bronze,
       COUNT_BIG(*) - COUNT_BIG(cst_id) AS filas_id_nulo,
       COUNT_BIG(cst_id) - COUNT_BIG(DISTINCT cst_id) AS filas_duplicadas_excedentes,
       COUNT_BIG(DISTINCT cst_id) AS clientes_unicos_no_nulos
FROM bronze.crm_cust_info;

-- 3. Esperado: ninguna fila por consulta.
SELECT cst_id, COUNT_BIG(*) AS cantidad
FROM silver.crm_cust_info
GROUP BY cst_id HAVING COUNT_BIG(*) > 1 OR cst_id IS NULL;

SELECT customer_id, COUNT_BIG(*) AS cantidad
FROM gold.dim_customers
GROUP BY customer_id HAVING COUNT_BIG(*) > 1 OR customer_id IS NULL;

SELECT product_number, COUNT_BIG(*) AS cantidad
FROM gold.dim_products
GROUP BY product_number HAVING COUNT_BIG(*) > 1 OR product_number IS NULL;

-- 4. Observado: cero claves sin correspondencia.
SELECT
    COALESCE(SUM(CASE WHEN customer_key IS NULL THEN CAST(1 AS BIGINT) ELSE 0 END), 0)
        AS ventas_sin_cliente,
    COALESCE(SUM(CASE WHEN product_key IS NULL THEN CAST(1 AS BIGINT) ELSE 0 END), 0)
        AS ventas_sin_producto
FROM gold.fact_sales;

-- 5. Observado: cero casos bajo estas reglas del ejercicio.
SELECT COUNT_BIG(*) AS ventas_inconsistentes
FROM gold.fact_sales
WHERE sales_amount IS NULL OR quantity IS NULL OR price IS NULL
   OR sales_amount <= 0 OR quantity <= 0 OR price <= 0
   OR CAST(sales_amount AS DECIMAL(38,4))
      <> CAST(quantity AS DECIMAL(18,4)) * CAST(price AS DECIMAL(18,4));

-- 6. Observado: 60398 filas y 29356250.00 en ambas capas.
SELECT 'Silver' AS capa, COUNT_BIG(*) AS filas,
       SUM(CAST(sls_sales AS DECIMAL(38,2))) AS importe_total
FROM silver.crm_sales_details
UNION ALL
SELECT 'Gold', COUNT_BIG(*), SUM(CAST(sales_amount AS DECIMAL(38,2)))
FROM gold.fact_sales;

-- 7. Observado: 19 pedidos sin fecha; restantes controles en cero.
-- Una fecha NULL no participa en las comparaciones cronologicas.
SELECT COUNT_BIG(*) AS total_ventas,
       COUNT_BIG(*) - COUNT_BIG(order_date) AS pedidos_sin_fecha,
       COUNT_BIG(*) - COUNT_BIG(shipping_date) AS envios_sin_fecha,
       COUNT_BIG(*) - COUNT_BIG(due_date) AS vencimientos_sin_fecha,
       SUM(CASE WHEN shipping_date < order_date THEN CAST(1 AS BIGINT) ELSE 0 END)
           AS envios_anteriores_al_pedido,
       SUM(CASE WHEN due_date < order_date THEN CAST(1 AS BIGINT) ELSE 0 END)
           AS vencimientos_anteriores_al_pedido
FROM gold.fact_sales;

-- 8. Diagnostico de Bronze: observado 17 ceros y 2 longitudes incorrectas.
-- Reproduce el filtro actual, no detecta todas las fechas calendarias invalidas.
SELECT sls_ord_num AS numero_orden, sls_order_dt AS fecha_original,
       CASE WHEN sls_order_dt IS NULL THEN 'Nulo en origen'
            WHEN sls_order_dt = 0 THEN 'Cero en origen'
            WHEN LEN(sls_order_dt) <> 8 THEN 'Longitud incorrecta'
            ELSE 'Revisar' END AS motivo,
       sls_sales AS importe
FROM bronze.crm_sales_details
WHERE sls_order_dt IS NULL OR sls_order_dt = 0 OR LEN(sls_order_dt) <> 8;

-- 9. Inspeccion del caso; el numero de orden no identifica una linea unica.
SELECT sls_ord_num, sls_order_dt, sls_sales, sls_quantity, sls_price
FROM silver.crm_sales_details
WHERE sls_ord_num = 'SO69215';
