/*
===================================================================
Creación de las tablas que almacenarán los datos en la capa Bronze.
===================================================================

Proposito: 
Este script crea las tablas necesarias para almacenar la información proveniente de las fuentes de datos (CRM y ERP). Antes de crear 
cada tabla, se valida si ya existe una tabla con el mismo nombre. En caso de existir, se elimina y posteriormente se crea una nueva 
tabla con la estructura definida.

Precaucion:
este script elimina las tablas existentes antes de crearlas nuevamente. Asegúrate de contar con un respaldo si contienen información 
que necesites conservar.

*/


IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;
GO

CREATE TABLE bronze.cmr_cust_info(
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_marital_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date DATE
);
GO


IF OBJECT_ID('bronze.cmr_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.cmr_prd_info;
GO

CREATE TABLE bronze.cmr_prd_info(
	prd_id INT,
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(50),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATE,
	prd_end_dt DATE
);
GO

IF OBJECT_ID('bronze.cmr_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.cmr_sales_details;
GO

CREATE TABLE bronze.cmr_sales_details(
	sls_ord_num		NVARCHAR(50),
	sls_prd_key		NVARCHAR(50),
	sls_cust_id		INT,
	sls_order_dt	INT,
	sls_ship_dt		INT,
	sls_due_dt		INT,
	sls_sales		INT,
	sls_quantity	INT,
	sls_price		INT
);
GO

IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;
GO

CREATE TABLE bronze.erp_cust_az12(
	CID		NVARCHAR(50),
	BDATE	DATE,
	GEN		NVARCHAR(50)
);
GO

IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;
GO



CREATE TABLE bronze.erp_loc_a101(
	CID		NVARCHAR(50),
	CNTRY	NVARCHAR(50)
);
GO

IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;
GO


CREATE TABLE bronze.erp_px_cat_g1v2(
	ID			NVARCHAR(50),
	CAT			NVARCHAR(50),
	SUBCAT		NVARCHAR(50),
	MAINTENANCE NVARCHAR(50)
);
GO
