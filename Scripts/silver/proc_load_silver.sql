/*
================================================================================
Creación de un procedimiento almacenado para la carga de datos en la capa Silver.
================================================================================

Propósito:
Este script crea un procedimiento almacenado cuyo objetivo es cargar los datos de la capa Bronze en las tablas de la capa Silver, 
aplicando procesos de limpieza y estandarización. Entre las  transformaciones se incluyen: eliminación de duplicados de clientes, 
normalización de códigos (estado civil, género, línea de producto, país), validación de fechas, recálculo de ventas y 
precios inconsistentes, y eliminación de prefijos en las claves para poder cruzar las fuentes CRM y ERP. 
El procedimiento registra además los tiempos de ejecución de cada tabla y el total,  permitiendo realizar un seguimiento básico del 
rendimiento del proceso de carga.

Precaución:
Este procedimiento elimina los datos existentes en las tablas Silver (TRUNCATE) antes de cargar  nuevamente la información desde 
la capa Bronze. Antes de ejecutarlo, verifica que las tablas  Bronze estén cargadas y contengan la estructura esperada. 
Si ocurre un error durante la carga, el bloque CATCH solo muestra el mensaje y no revierte los cambios, por lo que algunas tablas 
podrían quedar vacías o incompletas mientras otras ya fueron recargadas.

Parámetros: Este procedimiento almacenado no requiere parámetros para su ejecución.

Uso: EXEC silver.load_silver;

*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'CARGANDO LA CAPA SILVER';
        PRINT '================================================';

        PRINT '------------------------------------------------';
        PRINT 'CARGANDO LOS DATOS DEL CRM';
        PRINT '------------------------------------------------';

        -- Carga de la tabla silver.crm_cust_info.
        SET @start_time = GETDATE();
        PRINT '>> LIMPIANDO DATOS DE : silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;
        PRINT '>> INSERTANDO DATOS A: silver.crm_cust_info';

		INSERT INTO silver.crm_cust_info(
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date
			)
		SELECT 
			cst_id,
			cst_key,
			TRIM(cst_firstname) AS cst_firstname, -- Se eliminan los espacios innecesarios de los datos para mejorar su consistencia.
			TRIM(cst_lastname) AS cst_lastname,
			CASE UPPER(TRIM(cst_marital_status))
				WHEN 'M' THEN 'Married'
				WHEN 'S' THEN 'Single'
				ELSE 'n/a'
			END AS cst_marital_status,            -- Normalizacion de los valores a un formato legible
			CASE UPPER(TRIM(cst_gndr))
				WHEN 'F' THEN 'Female'
				WHEN 'M' THEN 'Male'
				ELSE 'n/a'
			END AS cst_gndr,                      -- Normalizacion de los valores a un formato legible
			cst_create_date
		FROM (
			SELECT *,
				ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date) AS flag_last
			FROM bronze.crm_cust_info
		) t WHERE flag_last = 1 AND cst_id IS NOT NULL; -- Seleccionar el registro más reciente de cada cliente para eliminar registros duplicados y conservar la información más actualizada.
		SET @end_time = GETDATE();
        PRINT '>> TIEMPO DE DURACION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' SEGUNDOS';
        PRINT '>> -------------';

		 -- Carga de la tabla silver.crm_prd_info
        SET @start_time = GETDATE();
        PRINT '>> LIMPIANDO DATOS DE: silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info;
        PRINT '>> INSERTANDO DATOS A silver.crm_prd_info';
		INSERT INTO silver.crm_prd_info(
				prd_id,
				cat_id,
				prd_key,
				prd_nm,
				prd_cost,
				prd_line,
				prd_start_dt,
				prd_end_dt
		)
		SELECT 
			prd_id,
			REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id, -- Se extrae la categoría del producto.
			SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,      -- Se extrae el producto.
			prd_nm,
			ISNULL(prd_cost,0) AS prd_cost,
			CASE UPPER(TRIM(prd_line))
					WHEN 'M' THEN 'Mountain'
					WHEN 'R' THEN 'Road'
					WHEN 'S' THEN 'Other Sales'
					WHEN 'T' THEN 'Touring'
					ELSE 'n/a'
			END AS prd_line,                                  -- Normalizacion de los valores a un formato legible
			CAST(prd_start_dt AS date) as prd_start_dt,       -- Se convierte el formato de fecha y hora a fecha.
			CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS date) AS prd_end_dt -- Calcular la fecha de finalización como un día antes de la siguiente fecha de inicio
		FROM bronze.crm_prd_info                 
		 SET @end_time = GETDATE();
        PRINT '>> TIEMPO DE DURACION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' SEGUNDOS';
        PRINT '>> -------------';

		-- carga crm_sales_details
        SET @start_time = GETDATE();
        PRINT '>> LIMPIANDO DATOS DE: silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;
        PRINT '>> INSERTANDO DATOS A: silver.crm_sales_details';
		INSERT INTO silver.crm_sales_details(
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		SELECT 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE
				WHEN sls_order_dt = 0 OR LEN (sls_order_dt) !=8 THEN NULL
				ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
			END AS sls_order_dt, -- Validar las fechas y convertir los valores inválidos en `NULL`
			CASE
				WHEN sls_ship_dt = 0 OR LEN (sls_ship_dt) !=8 THEN NULL
				ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
			END AS sls_ship_dt,  -- Validar las fechas y convertir los valores inválidos en `NULL`
			CASE
				WHEN sls_due_dt = 0 OR LEN (sls_due_dt) !=8 THEN NULL
				ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
			END AS sls_due_dt,   -- Validar las fechas y convertir los valores inválidos en `NULL`
			CASE
				WHEN sls_sales IS NULL OR sls_sales<=0 OR sls_sales != sls_quantity*ABS(sls_price)
				THEN sls_quantity*ABS(sls_price)
				ELSE sls_sales
			END AS sls_sales, -- Recalcular las ventas cuando el valor sea inválido o no coincida con la cantidad por el precio absoluto.
			sls_quantity,
			CASE
				WHEN sls_price IS NULL OR sls_price<=0 
				THEN sls_sales/NULLIF(sls_quantity,0)
				ELSE sls_price
			END AS sls_price -- Recalcular el precio unitario cuando sea nulo o no positivo, evitando la división por cero.
		FROM bronze.crm_sales_details
		SET @end_time = GETDATE();
        PRINT '>> TIEMPO DE DURACION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' SEGUNDOS';
        PRINT '>> -------------';

		PRINT '------------------------------------------------';
        PRINT 'CARGANFO DATOS DEL ERP';
        PRINT '------------------------------------------------';

        -- carga erp_cust_az12
        SET @start_time = GETDATE();
        PRINT '>> LIMPIANDO DATOS DE: silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12;
        PRINT '>> INSERTANDO DATOS A: silver.erp_cust_az12';

		INSERT INTO silver.erp_cust_az12(
			cid,
			bdate,
			gen
		)
		SELECT 
			CASE 
				WHEN cid LIKE 'NAS%'
				THEN SUBSTRING(cid,4,LEN(cid))
				ELSE cid
			END AS cid, -- Removemos el prefijo NAS
			CASE 
				WHEN bdate> GETDATE()
				THEN NULL
				ELSE bdate
			END AS bddate, -- reasignamos fechas de cumpleaños futuras como NULL
			CASE 
				WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
				WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
				ELSE 'n/a' 
			END AS gen -- Normalizacion de los valores a un formato legible
		FROM bronze.erp_cust_az12
		SET @end_time = GETDATE();
        PRINT '>> TIEMPO DE DURACION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' SEGUNDOS';
        PRINT '>> -------------';

		-- cust_loc_a101
		SET @start_time = GETDATE();
        PRINT '>> LIMPIANDO DATOS DE: silver.erp_loc_a101';
        TRUNCATE TABLE silver.erp_loc_a101;
        PRINT '>> INSERTANDO DATOS A: silver.erp_loc_a101';

		INSERT INTO silver.erp_loc_a101(
			cid,
			cntry
		)
		SELECT 
			REPLACE(cid,'-','') AS cid, -- Eliminamos '-'
			CASE 
				WHEN TRIM(cntry) = 'DE' THEN 'Germany'
				WHEN TRIM(cntry) IN ('USA','US') THEN 'United States'
				WHEN TRIM(cntry) = ' ' OR cntry IS NULL THEN 'n/a'
				ELSE cntry
			END AS cntry -- Normalizamos la columna paises
		FROM bronze.erp_loc_a101
		SET @end_time = GETDATE();
        PRINT '>> TIEMPO DE DURACION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' SEGUNDOS';
        PRINT '>> -------------';

		-- carga px_cat_g1v2
		SET @start_time = GETDATE();
        PRINT '>> LIMPIANDO DATOS DE: silver.erp_px_cat_g1v2';
        TRUNCATE TABLE silver.erp_px_cat_g1v2;
        PRINT '>> INSERTANDO DATOS A: silver.erp_px_cat_g1v2';

		INSERT INTO silver.erp_px_cat_g1v2(
			id,
			cat,
			subcat,
			maintenance
		)
		SELECT 
			id, 
			cat,
			subcat,
			maintenance
		FROM bronze.erp_px_cat_g1v2
		SET @end_time = GETDATE();
        PRINT '>> TIEMPO DE DURACION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' SEGUNDOS';
        PRINT '>> -------------';

        SET @batch_end_time = GETDATE();
        PRINT '=========================================='
        PRINT 'CARGA DE LA CAPA SILVER COMPLETADA';
        PRINT '   - DURACION TOTAL: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' SEGUNDOS';
        PRINT '=========================================='

    END TRY
    BEGIN CATCH
        PRINT '===================================================='
        PRINT 'OCURRIO UN ERROR DURANTE EL CARGUE DE LA CAPA SILVER'
        PRINT 'MENSAJE DE ERROR : ' + ERROR_MESSAGE();
        PRINT 'ERROR NUMERO: ' + CAST (ERROR_NUMBER() AS NVARCHAR);
        PRINT 'ESTADO DEL ERROR: ' + CAST (ERROR_STATE() AS NVARCHAR);
        PRINT '===================================================='
    END CATCH
END

