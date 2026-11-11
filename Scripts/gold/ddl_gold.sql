/*
====================================================================================================================================
DDL capa Gold
====================================================================================================================================

Proposito: 
Este código crea tres vistas en la capa Gold: clientes, productos y ventas. A partir de la información de 
la capa Silver, integra y organiza los datos en un modelo estrella, relacionando las ventas con sus respectivos clientes y productos.

Uso: Estas vistas pueden consultarse directamente para realizar análisis y generar informes.
*/

-- =============================================================================
-- Creacion de la Dimension: gold.dim_customers
-- =============================================================================
CREATE VIEW gold.dim_customers AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY cst_id) AS Customer_Key,
	c.cst_id AS Customer_Id,
	c.cst_key AS Customer_Number,
	c.cst_firstname AS First_Name,
	c.cst_lastname AS Last_Name,
	p.cntry AS Country,
	c.cst_marital_status AS Marital_Status,
	CASE
		WHEN c.cst_gndr != 'n/a' THEN c.cst_gndr
		ELSE COALESCE (d.gen,'n/a')
	END AS Gender,
	d.bdate AS Birthday,
	c.cst_create_date AS Create_Date
FROM silver.crm_cust_info c
LEFT JOIN silver.erp_loc_a101 p
	ON p.cid = c.cst_key
LEFT JOIN silver.erp_cust_az12 d
	ON d.cid = c.cst_key

-- =============================================================================
-- Creacion de la Dimension: gold.dim_products
-- =============================================================================

CREATE VIEW gold.dim_products AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt,pn.prd_key) AS product_key,
	pn.prd_id AS product_id,
	pn.prd_key AS product_number,
	pn.prd_nm AS product_name,
	pn.cat_id AS category_id,
	ct.cat AS category,
	ct.subcat AS subcategory,
	ct.maintenance,
	pn.prd_cost AS cost,
	pn.prd_line AS product_line,
	pn.prd_start_dt AS start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 ct ON pn.cat_id = ct.ID
WHERE pn.prd_end_dt IS NULL


-- =============================================================================
-- Creacion de la tabal de hechos: gold.fact_sales
-- =============================================================================

CREATE VIEW gold.fact_sales AS
SELECT 
	sd.sls_ord_num AS order_number,
	pr.product_key,
	cu.Customer_Key,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS shipping_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales_amount,
	sd.sls_quantity AS quantity,
	sd.sls_price AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
	ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
	ON cu.Customer_Id = sd.sls_cust_id

