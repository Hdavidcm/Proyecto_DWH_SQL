/* 
==========================================================================
Creacion de la base de datos y esquemas
==========================================================================

Proposito:
Este script crea una nueva base de datos llamada DataWarehouse. Antes de iniciar, se valida si ya existe una base de datos con este nombre. 
En caso de existir, se elimina y se crea una nueva. Además, se crean los esquemas Bronze, Silver y Gold, que representan las diferentes 
capas utilizadas en el proceso de transformación y almacenamiento de los datos.

Riegos:
La ejecución de este script puede eliminar una base de datos existente, lo que implica la eliminación permanente de todos los datos 
almacenados en ella. Antes de ejecutar el script, asegúrate de contar con un respaldo de la base de datos en caso de que sea necesario 
recuperar la información. Ejecuta este script con precaución y únicamente cuando estés seguro de que la base de datos puede ser eliminada.
*/

USE master

-- Validacion y eliminacion de la base de datos 'DataWarehouse' 
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

-- Creacion y uso de la base de datos 'DataWarehouse'

CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Creacion de Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
