/*
================================================================================
Validaciones de calidad de datos de las capas Bronze y Silver.
================================================================================

Propósito:
Este script reúne las consultas de validación utilizadas para revisar la calidad de los datos antes y después de la limpieza. 
En Bronze se detectan los problemas que justifican las transformaciones (duplicados y nulos en claves primarias, espacios no deseados, 
valores sin estandarizar, fechas inválidas e inconsistencias entre ventas, cantidad y precio). En Silver se comprueba que esas 
transformaciones se aplicaron correctamente (valores normalizados, sin duplicados y con cálculos coherentes). 

*/


-- ====================================================
-- cust_info
-- ====================================================

-- Validacion de nulos y duplicados en la primary key

SELECT 
	cst_id,
	COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*)>1 OR cst_id IS NULL


-- Validacion de espacio no deseados

SELECT cst_firstname, cst_lastname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname) OR cst_lastname != TRIM(cst_lastname) OR cst_gndr != TRIM(cst_gndr)

-- Estandarizacion y consistencia de los datos

SELECT 
	DISTINCT(cst_gndr)
FROM bronze.crm_cust_info

SELECT 
	DISTINCT(cst_marital_status)
FROM bronze.crm_cust_info



-- ====================================================
-- prd_info
-- ====================================================

SELECT 
	prd_id,
	COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- Validacion nombre producto

SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

-- Validacion de costos (no negativos - no null)
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost IS NULL

-- Validacion linea de productos

SELECT 
	DISTINCT(prd_line)
FROM silver.crm_prd_info

-- Fecha de productos

SELECT *
FROM silver.crm_prd_info


-- ====================================================
-- sales_details
-- ====================================================


SELECT
	NULLIF(sls_order_dt,0) AS sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt = 0
OR LEN(sls_order_dt) != 8

SELECT DISTINCT
	sls_sales,
	sls_quantity,
	sls_price,
CASE
		WHEN sls_sales IS NULL OR sls_sales<=0 OR sls_sales != sls_quantity*ABS(sls_price)
		THEN sls_quantity*ABS(sls_price)
		ELSE sls_sales
END AS sls_sales2,
CASE
		WHEN sls_price IS NULL OR sls_price<=0 
		THEN sls_sales/NULLIF(sls_quantity,0)
		ELSE sls_price
END AS sls_price2
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity*sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <=0  OR sls_quantity <=0  OR sls_price <=0
ORDER BY sls_sales, sls_quantity, sls_price


SELECT DISTINCT
	sls_sales,
	sls_quantity,
	sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity*sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <=0  OR sls_quantity <=0  OR sls_price <=0
ORDER BY sls_sales, sls_quantity, sls_price


SELECT * FROM silver.crm_sales_details


-- ====================================================
-- erp_cust_az12
-- ====================================================


SELECT DISTINCT gen
FROM silver.erp_cust_az12


SELECT * FROM silver.erp_cust_az12



-- ====================================================
-- Validaciones erp_loc_a101
-- ====================================================


SELECT DISTINCT CNTRY FROM silver.erp_loc_a101

SELECT * FROM silver.erp_loc_a101
