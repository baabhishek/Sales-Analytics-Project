-- Sales Analytics Project
-- Product: Toy Sales 
-- This is a project that utilizes a sample dataset with multiple tables detailing retail-based stores 
-- that focus on selling toys in Mexico.

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
create database toy_sales_project

USE toy_sales_project
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Data Prepairation:

---------------------SALES TABLE---------------------
create table sales
(Sale_ID varchar(max),Date VARCHAR(max),Store_ID VARCHAR (max),Product_ID VARCHAR (max),Units VARCHAR (max))

BULK INSERT sales
FROM 'C:\Users\abhis\Desktop\sales.csv'
WITH (FIELDTERMINATOR = ',',  ROWTERMINATOR = '\n',    FIRSTROW = 2,  MAXERRORS = 40)
go

---------------------STORE TABLE---------------------
create table stores
(Store_ID varchar(max),	Store_Name varchar(max),	Store_City varchar(max),Store_Location varchar(max),Store_Open_Date varchar(max))

BULK INSERT stores
FROM 'C:\Users\abhis\Desktop\stores.csv'
WITH (FIELDTERMINATOR = ',',  ROWTERMINATOR = '\n',    FIRSTROW = 2,  MAXERRORS = 40)
go

---------------------PRODUCT TABLE---------------------
create table products
(Product_ID varchar(max),Product_Name varchar(max),Product_Category varchar(max),Product_Cost varchar(max),Product_Price varchar(max))


BULK INSERT products
FROM 'C:\Users\abhis\Desktop\products.csv'
WITH (FIELDTERMINATOR = ',',  ROWTERMINATOR = '\n',    FIRSTROW = 2,  MAXERRORS = 40)
go

---------------------INVENTORY TABLE---------------------

create table inventory
(Store_ID varchar(max),Product_ID varchar(max),Stock_On_Hand varchar(max))

BULK INSERT inventory
FROM 'C:\Users\abhis\Desktop\inventory.csv'
WITH (FIELDTERMINATOR = ',',  ROWTERMINATOR = '\n',    FIRSTROW = 2,  MAXERRORS = 40)
go

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
select * from sales
select * from stores
select * from products
select * from inventory

-- Performing Data cleaning (Coversion Data Types,Null Values, Eliminate unwanted)
---------------- ---------------- ---------------- ---------------- ---------------- ---------------- ---------------- ---------------- ----------------
select column_name, data_type
from information_schema.columns

---------------------SALES TABLE---------------------
select * from sales

SELECT * FROM sales
WHERE ISNUMERIC(sale_id) = 0       --Error

SELECT *FROM sales
WHERE ISDATE([date]) = 0

SELECT * FROM sales
WHERE ISNUMERIC(store_id) = 0 

SELECT * FROM sales
WHERE ISNUMERIC(product_id) = 0

SELECT * FROM sales
WHERE ISNUMERIC(Units) = 0           --Error

-- We have 2 sale_id non numeric 
-- and all records of unit column is not numeric (units column with unwanted arrow mark)

---------------------STORE TABLE---------------------
SELECT * FROM stores
WHERE ISNUMERIC(store_id) = 0 

SELECT * FROM stores
WHERE ISDATE(Store_Open_Date) = 0    

---------------------PRODUCT TABLE---------------------
SELECT * FROM products
WHERE ISNUMERIC(product_id) = 0        -- Error

SELECT * FROM products
WHERE ISNUMERIC(product_cost) = 0  

SELECT * FROM products
WHERE ISNUMERIC(Product_Price) = 0  

-- 
-- -- We have only one record from product Id column.

---------------------Inventory TABLE---------------------

SELECT * FROM inventory
WHERE ISNUMERIC(Store_ID) = 0 

SELECT * FROM inventory
WHERE ISNUMERIC(Product_ID) = 0 

select * from inventory
where ISNUMERIC(Stock_On_Hand)=0        

------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Changing The data types from above investigation based on that we can chage the types

-- lets change the dtype of date 


alter table sales
alter column product_id int

select [date] from sales
where [date] like '%[!@#$%^&*()__+:";<>.,]%' or [date] like '%[/]%'


select [date] from sales
where [date] like '__/__/2022%' or [date] like '%[/]%'


update sales set [date]= replace(date,'/','-') from sales

select date from sales
where [date] like '%__-202%'

select date, try_convert(date,[date],103) from sales
where try_convert(date,[date],103) is not null

update sales set [date]=try_convert(date,[date],103)
where try_convert(date,[date],103) is not null

select [date] from sales
where isdate([date])=0

update sales set date='2022-04-01'
where sale_id='89588'

--Some dates are in mm-yyyy-dd need to convert the position of yyyy and dd so 
--that we can get mm-dd-yyyy to convert date format

select date from sales
where date like '__-2022-%' or date like '_-2022-%' or date like '_-2023-%' or date like '__-2023-%'

-- 17 column found in wromg date format

select date, stuff(replace(date,'2022','4'),1,1,'2022') from sales
where date like '__-2022-%' or date like '_-2022-%' or date like '_-2023-%' or date like '__-2022-%'


update sales set date=stuff(replace(date,'2022','4'),1,1,'2022') from sales
where date like '__-2022-%' or date like '_-2022-%' or date like '_-2023-%' or date like '__-2022-%'

select sale_id from sales
where sale_id like '%[^0-9]%'

update sales set sale_id= case when sale_id like '%[^0-9]%' then 
replace(sale_id,substring(sale_id,Patindex('%[^0-9]%',Sale_id),1),'')  else sale_id end from sales
where sale_id like '%[^0-9]%'

select units from sales
where units like '%[^0-9]%'

update sales set units= case when units like '%[^0-9]%' then 
replace(units,substring(units,Patindex('%[^0-9]%',units),1),'')  else units end
where units like '%[^0-9]%'

-- Coverting to required Data Types
ALTER TABLE sales
ALTER column sale_id INT

ALTER TABLE sales
ALTER column [date] DATE

ALTER TABLE sales
ALTER column store_id INT

ALTER TABLE SALES
ALTER COLUMN Product_ID INT

ALTER TABLE SALES
ALTER COLUMN units INT

select Column_name, Data_type 
from INFORMATION_SCHEMA.columns
where table_name='Sales'

---------------- ---------------- ---------------- ---------------- STORES TABLE---------------- ---------------- ---------------- ---------------- ----------------
-- Store open date column having unwanted item found need to be remove to convert to date

select * from stores


UPDATE stores
SET Store_Open_Date = CONVERT(DATE, Store_Open_Date, 105)

SELECT Store_Open_Date FROM stores

ALTER TABLE STORES
ALTER column Store_ID INT

alter table stores
alter column store_open_date DATE

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'stores'

---------------- ---------------- ---------------- ---------------- PRODUCT TABLE---------------- ---------------- ---------------- ---------------- ----------------
-- Product Id,price,cost  having unwated item and special character value need to be removed 

select * from products

UPDATE products
SET Product_ID = TRANSLATE(Product_ID, '$',' ')


UPDATE products
SET Product_Cost = TRANSLATE(Product_Cost, '$',' ')

UPDATE products
SET Product_Price = TRANSLATE(Product_Price, '$',' ')

alter table products
alter column product_id INT

alter TABLE products
ALTER COLUMN Product_Cost DECIMAL(10, 2)

alter TABLE products
ALTER COLUMN Product_Price DECIMAL(10, 2)

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'products'

---------------- ---------------- ---------------- ---------------- INVENTORY TABLE---------------- ---------------- ---------------- ---------------- ----------------

SELECT * FROM inventory


ALTER TABLE INVENTORY
ALTER COLUMN Store_ID INT

ALTER TABLE INVENTORY
ALTER COLUMN Product_ID INT

ALTER TABLE INVENTORY
ALTER COLUMN Stock_On_Hand INT

select column_name, data_type
from INFORMATION_SCHEMA.columns
where table_name='inventory'

---------------- ---------------- ---------------- ---------------- -------------------------------- ---------------- ---------------- ---------------- ----------------
select column_name, data_type
from INFORMATION_SCHEMA.columns

select Column_name, Data_type 
from INFORMATION_SCHEMA.columns
where table_name in('Inventory','stores','sales','products')

-- All data types of column from those table now converted as per data integrity.
-- Let's see the final table from all. 

select * from sales
select * from stores
select * from products
select * from inventory

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Any duplicate data from the Sales and Product tables might create problems in the data analysis process.
-- Let's dive into this and remove any duplicates

select sale_id from sales
select count(distinct sale_id) as unique_saleID from sales

select count(Distinct product_id) 'unique_ProductId' from products
select * from products

-- Found duplicated product id which are repeating lets remove this

with Duplrows as
(select *, row_number() over(partition by 
Product_id,Product_name,Product_category,Product_cost,Product_price order by product_id) as row_num
from products)

select * from Duplrows
where row_num>1

-- 3 Product ID repeating, by CTE lets delete from this from product table.

with Duplrows as(select *, row_number() over(partition by 
Product_id,Product_name,Product_category,Product_cost,Product_price order by product_id) as row_num
from products)

delete from Duplrows
where row_num>1
-- Recheacking the if any duplicates are there.
select count(Distinct product_id) 'unique_ProductId' from products
select * from products

-- Now data cleaning and data prepairation and required data types done lets dive into our data and start working on data analysis.
