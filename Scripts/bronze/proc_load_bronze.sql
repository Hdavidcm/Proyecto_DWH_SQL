/*
================================================================================
Creación de un procedimiento almacenado para la carga de datos en la capa Bronze.
================================================================================

Proposito: 
Este script crea un procedimiento almacenado cuyo objetivo es cargar los datos provenientes de las fuentes CRM y ERP en las tablas 
de la capa Bronze. El procedimiento utiliza `BULK INSERT` para cargar la información desde archivos CSV y registra los tiempos de 
ejecución de cada tabla, permitiendo realizar un seguimiento básico del rendimiento del proceso de carga.

Precaucion:
este procedimiento elimina los datos existentes en las tablas Bronze antes de cargar nuevamente la información desde los archivos CSV.
Antes de ejecutarlo, verifica que los archivos existan, que las rutas sean correctas y que la información tenga la estructura esperada. 
Si ocurre algún error durante la carga, alguna tabla podría quedar vacía o incompleta.

Parámetros: Este procedimiento almacenado no requiere parámetros para su ejecución.

*/


CREATE OR ALTER PROC bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME,@batch_start_time DATETIME, @batch_end_time DATETIME
	BEGIN TRY
	SET @batch_start_time = GETDATE()
		PRINT '==================================================================';
		PRINT 'CARGANDO LA CAPA BRONZE';
		PRINT '==================================================================';


		PRINT '------------------------------------------------------------------';
		PRINT 'CARGANDO LOS DATOS DEL CRM';
		PRINT '------------------------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>>LIMPIANDO DATOS DE: cmr_cust_info'
		TRUNCATE TABLE bronze.cmr_cust_info
		PRINT '>>INSERTANDO DATOS EN: bronze.cmr_cust_info'
		BULK INSERT bronze.cmr_cust_info
		FROM 'C:\Users\Heiler\Documents\Proyecto DWH SQL\source_cmr\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		
		SET @end_time = GETDATE();
		PRINT '>> TIEMPO DE DURACION:' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' SEGUNDOS'
		PRINT '----------------------------------'

		SET @start_time = GETDATE();
		PRINT '>>LIMPIANDO DATOS DE: cmr_prd_info'
		TRUNCATE TABLE bronze.cmr_prd_info
		PRINT '>>INSERTANDO DATOS EN: bronze.cmr_prd_info'
		BULK INSERT bronze.cmr_prd_info
		FROM 'C:\Users\Heiler\Documents\Proyecto DWH SQL\source_cmr\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> TIEMPO DE DURACION:' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' SEGUNDOS'
		PRINT '----------------------------------'

		SET @start_time = GETDATE();
		PRINT '>>LIMPIANDO DATOS DE: cmr_sales_details'
		TRUNCATE TABLE bronze.cmr_sales_details
		PRINT '>>INSERTANDO DATOS EN: cmr_sales_details'
		BULK INSERT bronze.cmr_sales_details
		FROM 'C:\Users\Heiler\Documents\Proyecto DWH SQL\source_cmr\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> TIEMPO DE DURACION:' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' SEGUNDOS'
		PRINT '----------------------------------'

		SET @start_time = GETDATE();
		PRINT '>>LIMPIANDO DATOS DE: erp_cust_az12'
		TRUNCATE TABLE bronze.erp_cust_az12
		PRINT '>>INSERTANDO DATOS EN: erp_cust_az12'
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\Heiler\Documents\Proyecto DWH SQL\source_erp\cust_az12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> TIEMPO DE DURACION:' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' SEGUNDOS'
		PRINT '----------------------------------'

		PRINT '------------------------------------------------------------------';
		PRINT 'CARGANDO LOS DATOS DEL ERP';
		PRINT '------------------------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>>LIMPIANDO DATOS DE: bronze.erp_loc_a101'
		TRUNCATE TABLE bronze.erp_loc_a101
		PRINT '>>INSERTANDO DATOS EN: bronze.erp_loc_a101'
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\Heiler\Documents\Proyecto DWH SQL\source_erp\loc_a101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> TIEMPO DE DURACION:' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' SEGUNDOS'
		PRINT '----------------------------------'

		
		SET @start_time = GETDATE();
		PRINT '>>LIMPIANDO DATOS DE: bronze.erp_px_cat_g1v2'
		TRUNCATE TABLE bronze.erp_px_cat_g1v2
		PRINT '>>INSERTANDO DATOS EN: erp_px_cat_g1v2'
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\Heiler\Documents\Proyecto DWH SQL\source_erp\px_cat_g1v2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> TIEMPO DE DURACION:' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' SEGUNDOS'
		PRINT '----------------------------------'
	SET @batch_end_time = GETDATE()
	PRINT '======================================'
	PRINT 'CAPA BRONZE CARGADA CORRECTAMENTE'
	PRINT '>> TIEMPO DE DURACION:' + CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time) AS NVARCHAR) + ' SEGUNDOS'
	PRINT '======================================'
	END TRY
	BEGIN CATCH
		PRINT '==================================================================';
		PRINT 'OCURRIO UN ERROR DURANTE EL CARGUE DE LA CAPA BRONZE';
		PRINT 'MENSAJE DE ERROR' + ERROR_MESSAGE();
		PRINT 'MENSAJE DE ERROR' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'MENSAJE DE ERROR' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '==================================================================';

	END CATCH

END
