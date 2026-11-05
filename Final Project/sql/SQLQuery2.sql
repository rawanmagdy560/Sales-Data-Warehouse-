///////////////////////////////*استكشاف وفحص البيانات المصدرية*/////////////////////////////////////////
select TABLE_SCHEMA AS SchemaName,TABLE_NAME AS TableName
from INFORMATION_SCHEMA.TABLES
where TABLE_TYPE = 'BASE TABLE'
and (TABLE_NAME IN ('Orders','OrderLines','Customers','StockItems','Invoices','InvoiceLines','CustomerCategories','Cities'))
order BY TABLE_SCHEMA, TABLE_NAME;
-------------------------------
/*هتظهر أسماء الأعمدة وأنواعها*/
--------------------------------
select TABLE_SCHEMA AS SchemaName,TABLE_NAME AS TableName, COLUMN_NAME AS ColumnName, DATA_TYPE AS DataType
from INFORMATION_SCHEMA.COLUMNS
where(TABLE_SCHEMA = 'Sales'
AND TABLE_NAME IN ('Orders','OrderLines','Customers','Invoices','InvoiceLines','CustomerCategories'))
OR(TABLE_SCHEMA = 'Warehouse'AND TABLE_NAME = 'StockItems')
OR(TABLE_SCHEMA = 'Application'AND TABLE_NAME = 'Cities')
order BY TABLE_SCHEMA,TABLE_NAME,ORDINAL_POSITION;
--------------------------------/*نحدد العلاقات بين الجداول*/---------------------------------------
SELECT fk.name AS ForeignKeyName,OBJECT_SCHEMA_NAME(fk.parent_object_id) AS TableSchema, OBJECT_NAME(fk.parent_object_id) AS TableName,
COL_NAME(fkc.parent_object_id,fkc.parent_column_id) AS ColumnName,
OBJECT_SCHEMA_NAME(fk.referenced_object_id) AS ReferencedSchema,
OBJECT_NAME(fk.referenced_object_id) AS ReferencedTable,
COL_NAME(fkc.referenced_object_id,fkc.referenced_column_id) AS ReferencedColumn
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fkc
ON fk.object_id = fkc.constraint_object_id
WHERE
OBJECT_NAME(fk.parent_object_id) IN ('Orders','OrderLines','Customers','Invoices','InvoiceLines','CustomerCategories','StockItems','Cities')
ORDER BY TableSchema,TableName,ForeignKeyName;
------------------------------------------
/* وكام عدد الصفوف اللي موجوده في كل جدول  
:: نتأكد إن البيانات موجودة*/
------------------------------------------
SELECT 'Sales.InvoiceLines' AS TableName,COUNT_BIG(*) AS TotalRows
FROM Sales.InvoiceLines
UNION ALL
SELECT 'Sales.Invoices',COUNT_BIG(*)
FROM Sales.Invoices
UNION ALL
SELECT 'Sales.Customers',COUNT_BIG(*)
FROM Sales.Customers
UNION ALL
SELECT 'Warehouse.StockItems',COUNT_BIG(*)
FROM Warehouse.StockItems
UNION ALL
SELECT 'Sales.CustomerCategories',COUNT_BIG(*)
FROM Sales.CustomerCategories
UNION ALL
SELECT 'Application.Cities',COUNT_BIG(*)
FROM Application.Cities;
-------------------------------------------
//////////////////////////////////////////*create datawarehouserr*/
-------------------------------------
CREATE DATABASE SalesDataWarehouseRR;
------------------------------------
/*: نسخ جدول تفاصيل الفواتير*/
--------------------------------
SELECT *
INTO dbo.InvoiceLines
FROM WideWorldImporters.Sales.InvoiceLines;
----------------------------------------------/*-- التأكد من عدد الصفوف التي تم نقلها*/-------------------------------------
SELECT COUNT(*) AS TotalRows
FROM dbo.InvoiceLines;
----------------------------------------------/*نقل جدول الفواتير.*/-------------------------------------
SELECT *
INTO dbo.Invoices
FROM WideWorldImporters.Sales.Invoices;

-------------------------------- ا-----------------------------------------لتأكد من عدد الفواتير التي تم نقلها
SELECT COUNT(*) AS TotalRows
FROM dbo.Invoices;
----------------------------------------------/*نقل جدول العملاء.*/-------------------------------------
SELECT *
INTO dbo.Customers
FROM WideWorldImporters.Sales.Customers;
-------------------------------- ا-----------------------------------------لتأكد من عدد العملاء التي تم نقلها
SELECT COUNT(*) AS TotalRows
FROM dbo.Customers;
----------------------------------------------/*نقل جدول بيانات المنتجات.*/-------------------------------------
SELECT *
INTO dbo.StockItems
FROM WideWorldImporters.Warehouse.StockItems;
-------------------------------- ا-----------------------------------------لتأكد من عدد البيانات المنجات  التي تم نقلها
SELECT COUNT(*) AS TotalRows
FROM dbo.StockItems;
----------------------------------------------/*نقل جدول  فئات العملاء  .*/-------------------------------------
SELECT *
INTO dbo.CustomerCategories
FROM WideWorldImporters.Sales.CustomerCategories;
----------------------------------------------/*نقل جدول المدن   .*/-------------------------------------
SELECT *
INTO dbo.Cities
FROM WideWorldImporters.Application.Cities;
---------------------------------------------------
/*فحص أعمدة الجداول الستة.*/
----------------------------------------------
EXEC sp_help 'dbo.InvoiceLines';
EXEC sp_help 'dbo.Invoices';
EXEC sp_help 'dbo.Customers';
EXEC sp_help 'dbo.StockItems';
EXEC sp_help 'dbo.CustomerCategories';
EXEC sp_help 'dbo.Cities';


-0000000000000000000000000000000000000000000- 1. فحص تكرار أرقام الفواتير
SELECT InvoiceID, COUNT(*) AS DuplicateCount
FROM dbo.Invoices
GROUP BY InvoiceID
HAVING COUNT(*) > 1;
-- 2. فحص تكرار أرقام تفاصيل الفواتير
SELECT InvoiceLineID, COUNT(*) AS DuplicateCount
FROM dbo.InvoiceLines
GROUP BY InvoiceLineID
HAVING COUNT(*) > 1;
-- 3. فحص الفواتير غير الموجودة
SELECT COUNT(*) AS MissingInvoices
FROM dbo.InvoiceLines AS IL
LEFT JOIN dbo.Invoices AS I
ON IL.InvoiceID = I.InvoiceID
WHERE I.InvoiceID IS NULL;
-- 4. فحص المنتجات غير الموجودة
SELECT COUNT(*) AS MissingStockItems
FROM dbo.InvoiceLines AS IL
LEFT JOIN dbo.StockItems AS SI
ON IL.StockItemID = SI.StockItemID
WHERE SI.StockItemID IS NULL;
---------------------------------5555555555555555555555555555555555555555555555555555555555555555555555---
-- التأكد من عدد الفواتير التي لا توجد في جدول Invoices
SELECT COUNT(*) AS MissingInvoices
FROM dbo.InvoiceLines AS IL
LEFT JOIN dbo.Invoices AS I
ON IL.InvoiceID = I.InvoiceID
WHERE I.InvoiceID IS NULL;

-- التأكد من عدد المنتجات التي لا توجد في جدول StockItems
SELECT COUNT(*) AS MissingStockItems
FROM dbo.InvoiceLines AS IL
LEFT JOIN dbo.StockItems AS SI
ON IL.StockItemID = SI.StockItemID
WHERE SI.StockItemID IS NULL;
---------------------------------
/*إضافة المفتاح الأساسي لجدول Invoices*/
ALTER TABLE dbo.Invoices
ADD CONSTRAINT PK_Invoices
PRIMARY KEY (InvoiceID);
/*نتأكد من المفتاح الأساسي*/
SELECT name AS PrimaryKeyName, type_desc
FROM sys.key_constraints
WHERE parent_object_id = OBJECT_ID('dbo.Invoices')
  AND type = 'PK';
  ---------------------/*إضافة Primary Key لجدول InvoiceLines*/----------------
  
ALTER TABLE dbo.InvoiceLines
ADD CONSTRAINT PK_InvoiceLines
PRIMARY KEY (InvoiceLineID);
--------------/*إضافة Primary Key لجدول Customers*/-----------------------
ALTER TABLE dbo.Customers
ADD CONSTRAINT PK_Customers
PRIMARY KEY (CustomerID);
---------/*إضافة Primary Key لجدول StockItems*/-----------
ALTER TABLE dbo.StockItems
ADD CONSTRAINT PK_StockItems
PRIMARY KEY (StockItemID);
------------------/*إضافة Primary Key لجدول CustomerCategories*/-------------------------------------
ALTER TABLE dbo.CustomerCategories
ADD CONSTRAINT PK_CustomerCategories
PRIMARY KEY (CustomerCategoryID);

---------------------/*إضافة Primary Key لجدول Cities*/--------------------

ALTER TABLE dbo.Cities
ADD CONSTRAINT PK_Cities
PRIMARY KEY (CityID);

---------------------------------/*: ربط InvoiceLines بجدول Invoices*/

ALTER TABLE dbo.InvoiceLines
ADD CONSTRAINT FK_InvoiceLines_Invoices
FOREIGN KEY (InvoiceID)
REFERENCES dbo.Invoices (InvoiceID);
-- 1. ربط تفاصيل الفواتير بالمنتجات
ALTER TABLE dbo.InvoiceLines
ADD CONSTRAINT FK_InvoiceLines_StockItems
FOREIGN KEY (StockItemID)
REFERENCES dbo.StockItems (StockItemID);
-- 2. ربط الفواتير بالعميل
ALTER TABLE dbo.Invoices
ADD CONSTRAINT FK_Invoices_Customers
FOREIGN KEY (CustomerID)
REFERENCES dbo.Customers (CustomerID);
-- 3. ربط الفواتير بعميل الفوترة
ALTER TABLE dbo.Invoices
ADD CONSTRAINT FK_Invoices_BillToCustomers
FOREIGN KEY (BillToCustomerID)
REFERENCES dbo.Customers (CustomerID);
-- 4. ربط العملاء بتصنيفات العملاء
ALTER TABLE dbo.Customers
ADD CONSTRAINT FK_Customers_CustomerCategories
FOREIGN KEY (CustomerCategoryID)
REFERENCES dbo.CustomerCategories (CustomerCategoryID);
-- 5. ربط مدينة التوصيل بالمدن
ALTER TABLE dbo.Customers
ADD CONSTRAINT FK_Customers_DeliveryCities
FOREIGN KEY (DeliveryCityID)
REFERENCES dbo.Cities (CityID);

-- 6. ربط المدينة البريدية بالمدن
ALTER TABLE dbo.Customers
ADD CONSTRAINT FK_Customers_PostalCities
FOREIGN KEY (PostalCityID)
REFERENCES dbo.Cities (CityID);
---------------------/*ظهر عندك 7 علاقات Foreign Key، وده معناه إن العلاقات السبعة اللي أضفناها موجودة بالفعل في قاعدة البيانات.*/------------
SELECT name AS ForeignKeyName, OBJECT_NAME(parent_object_id) AS TableName
FROM sys.foreign_keys
ORDER BY TableName;
-----------------------------/*الاستعلام ده هيعرض الجداول الموجودة وعدد الصفوف في كل جدول*/---------------

SELECT t.name AS TableName, SUM(p.rows) AS TotalRows
FROM sys.tables AS t
JOIN sys.partitions AS p
 ON t.object_id = p.object_id
WHERE p.index_id IN (0, 1)
GROUP BY t.name
ORDER BY t.name;
------------------------------------------- الاستعلام ده عشان نراجع أسماء العلاقات والجداول المرتبطة بها:------------

SELECT fk.name AS ForeignKeyName, OBJECT_NAME(fk.parent_object_id) AS ChildTable, OBJECT_NAME(fk.referenced_object_id) AS ParentTable, fk.is_disabled AS IsDisabled
FROM sys.foreign_keys AS fk
ORDER BY ChildTable, ForeignKeyName;

-- 1. فحص القيم الفارغة في الأعمدة الأساسية بجدول الفواتير وتفاصيل الفواتير
SELECT
    'Invoices' AS TableName,
    SUM(CASE WHEN InvoiceID IS NULL THEN 1 ELSE 0 END) AS NullInvoiceID,
    SUM(CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END) AS NullCustomerID
FROM dbo.Invoices
UNION ALL
SELECT
    'InvoiceLines',
    SUM(CASE WHEN InvoiceLineID IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN StockItemID IS NULL THEN 1 ELSE 0 END)
FROM dbo.InvoiceLines;
-- 2. فحص القيم غير المنطقية في كمية المنتجات وسعر الوحدة ومعدل الضريبة
SELECT COUNT(*) AS InvalidInvoiceLines
FROM dbo.InvoiceLines
WHERE Quantity <= 0
   OR UnitPrice < 0
   OR TaxRate < 0;
-- 3. التحقق من عدم تكرار رقم الفاتورةفي جدول الفواتير
SELECT COUNT(*) AS DuplicateInvoiceIDs
FROM (
    SELECT InvoiceID
    FROM dbo.Invoices
    GROUP BY InvoiceID
    HAVING COUNT(*) > 1
) AS D;
-- 4. التحقق من عدم تكرار رقم سطر الفاتورة في جدول تفاصيل الفواتير
SELECT COUNT(*) AS DuplicateInvoiceLineIDs
FROM (
    SELECT InvoiceLineID
    FROM dbo.InvoiceLines
    GROUP BY InvoiceLineID
    HAVING COUNT(*) > 1
) AS D;

-- عرض العلاقات بين الجداول وأسماء الأعمدة المرتبطة بها
SELECT
    fk.name AS RelationshipName,
    OBJECT_NAME(fk.parent_object_id) AS ChildTable,
    COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS ChildColumn,
    OBJECT_NAME(fk.referenced_object_id) AS ParentTable,
    COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) AS ParentColumn
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fkc
    ON fk.object_id = fkc.constraint_object_id
ORDER BY ChildTable, RelationshipName;



-- الاستعلام 1: عرض عينة من بيانات الفواتير
SELECT TOP 10 *
FROM dbo.Invoices;
-- الاستعلام 2: عرض أعلى 10 منتجات من حيث إجمالي الكمية المباعة
SELECT TOP 10
    SI.StockItemID,
    SI.StockItemName,
    SUM(IL.Quantity) AS TotalQuantitySold
FROM dbo.InvoiceLines AS IL
INNER JOIN dbo.StockItems AS SI
    ON IL.StockItemID = SI.StockItemID
GROUP BY
    SI.StockItemID,
    SI.StockItemName
ORDER BY TotalQuantitySold DESC;

-- الاستعلام 3: حساب إجمالي قيمة المبيعات قبل الضريبة لكل فاتورة
SELECT
    InvoiceID,
    SUM(Quantity * UnitPrice) AS TotalSales
FROM dbo.InvoiceLines
GROUP BY InvoiceID
ORDER BY TotalSales DESC;

-- الاستعلام 4: حساب عدد الفواتير لكل عميل
SELECT
    C.CustomerID,
    C.CustomerName,
    COUNT(I.InvoiceID) AS TotalInvoices
FROM dbo.Customers AS C
INNER JOIN dbo.Invoices AS I
    ON C.CustomerID = I.CustomerID
GROUP BY
    C.CustomerID,
    C.CustomerName
ORDER BY TotalInvoices DESC;

-- الاستعلام 5: عرض العملاء الذين لديهم أكثر من 100 فاتورة
SELECT
    C.CustomerID,
    C.CustomerName,
    COUNT(I.InvoiceID) AS TotalInvoices
FROM dbo.Customers AS C
INNER JOIN dbo.Invoices AS I
    ON C.CustomerID = I.CustomerID
GROUP BY
    C.CustomerID,
    C.CustomerName
HAVING COUNT(I.InvoiceID) > 100
ORDER BY TotalInvoices DESC;

-- الاستعلام 6: حساب إجمالي المبيعات لكل منتج
SELECT
    SI.StockItemID,
    SI.StockItemName,
    SUM(IL.Quantity * IL.UnitPrice) AS TotalSales
FROM dbo.InvoiceLines AS IL
INNER JOIN dbo.StockItems AS SI
    ON IL.StockItemID = SI.StockItemID
GROUP BY
    SI.StockItemID,
    SI.StockItemName
ORDER BY TotalSales DESC;

-- الاستعلام 7: حساب متوسط سعر الوحدة لكل منتج
SELECT
    SI.StockItemID,
    SI.StockItemName,
    AVG(IL.UnitPrice) AS AverageUnitPrice
FROM dbo.InvoiceLines AS IL
INNER JOIN dbo.StockItems AS SI
    ON IL.StockItemID = SI.StockItemID
GROUP BY
    SI.StockItemID,
    SI.StockItemName
ORDER BY AverageUnitPrice DESC;

-- الاستعلام 8: عرض الفواتير التي تتجاوز قيمتها متوسط قيمة الفواتير
SELECT
    InvoiceID,
    TotalSales
FROM (
    SELECT
        InvoiceID,
        SUM(Quantity * UnitPrice) AS TotalSales
    FROM dbo.InvoiceLines
    GROUP BY InvoiceID
) AS InvoiceTotals
WHERE TotalSales > (
    SELECT AVG(TotalSales)
    FROM (
        SELECT
            SUM(Quantity * UnitPrice) AS TotalSales
        FROM dbo.InvoiceLines
        GROUP BY InvoiceID
    ) AS AverageInvoices
)
ORDER BY TotalSales DESC;

-- الاستعلام 9: حساب إجمالي المبيعات لكل عميل باستخدام CTE
WITH CustomerSales AS (
    SELECT
        C.CustomerID,
        C.CustomerName,
        SUM(IL.Quantity * IL.UnitPrice) AS TotalSales
    FROM dbo.Customers AS C
    INNER JOIN dbo.Invoices AS I
        ON C.CustomerID = I.CustomerID
    INNER JOIN dbo.InvoiceLines AS IL
        ON I.InvoiceID = IL.InvoiceID
    GROUP BY
        C.CustomerID,
        C.CustomerName
)
SELECT *
FROM CustomerSales
ORDER BY TotalSales DESC;
-- الاستعلام 10: عرض العملاء الذين تجاوزت مبيعاتهم 100000
WITH CustomerSales AS (
    SELECT
        C.CustomerID,
        C.CustomerName,
        SUM(IL.Quantity * IL.UnitPrice) AS TotalSales
    FROM dbo.Customers AS C
    INNER JOIN dbo.Invoices AS I
        ON C.CustomerID = I.CustomerID
    INNER JOIN dbo.InvoiceLines AS IL
        ON I.InvoiceID = IL.InvoiceID
    GROUP BY
        C.CustomerID,
        C.CustomerName
)
SELECT *
FROM CustomerSales
WHERE TotalSales > 100000
ORDER BY TotalSales DESC;
---------------------------------------------------------------------------------------------------------------------------------------------


-- الاستعلام 11: ترتيب المنتجات حسب إجمالي المبيعات باستخدام دالة النافذة
SELECT
    SI.StockItemID,
    SI.StockItemName,
    SUM(IL.Quantity * IL.UnitPrice) AS TotalSales,
    RANK() OVER (
        ORDER BY SUM(IL.Quantity * IL.UnitPrice) DESC
    ) AS SalesRank
FROM dbo.InvoiceLines AS IL
INNER JOIN dbo.StockItems AS SI
    ON IL.StockItemID = SI.StockItemID
GROUP BY
    SI.StockItemID,
    SI.StockItemName
ORDER BY SalesRank;
GO

-- الاستعلام 12: حساب الإجمالي التراكمي للمبيعات حسب رقم الفاتورة
WITH InvoiceSales AS (
    SELECT
        InvoiceID,
        SUM(Quantity * UnitPrice) AS TotalSales
    FROM dbo.InvoiceLines
    GROUP BY InvoiceID
)
SELECT
    InvoiceID,
    TotalSales,
    SUM(TotalSales) OVER (
        ORDER BY InvoiceID
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS RunningTotalSales
FROM InvoiceSales
ORDER BY InvoiceID;
GO

-- الاستعلام 13: عرض أعلى 5 عملاء حسب إجمالي المبيعات
WITH CustomerSales AS (
    SELECT
        C.CustomerID,
        C.CustomerName,
        SUM(IL.Quantity * IL.UnitPrice) AS TotalSales
    FROM dbo.Customers AS C
    INNER JOIN dbo.Invoices AS I
        ON C.CustomerID = I.CustomerID
    INNER JOIN dbo.InvoiceLines AS IL
        ON I.InvoiceID = IL.InvoiceID
    GROUP BY
        C.CustomerID,
        C.CustomerName
)
SELECT TOP 5
    CustomerID,
    CustomerName,
    TotalSales
FROM CustomerSales
ORDER BY TotalSales DESC;
GO

-- الاستعلام 14: حساب إجمالي الكمية ومتوسط سعر الوحدة لكل منتج
SELECT
    SI.StockItemID,
    SI.StockItemName,
    SUM(IL.Quantity) AS TotalQuantity,
    AVG(IL.UnitPrice) AS AverageUnitPrice
FROM dbo.StockItems AS SI
INNER JOIN dbo.InvoiceLines AS IL
    ON SI.StockItemID = IL.StockItemID
GROUP BY
    SI.StockItemID,
    SI.StockItemName
ORDER BY TotalQuantity DESC;
GO

-- الاستعلام 15: مقارنة مبيعات كل منتج بمتوسط مبيعات المنتجات
WITH ProductSales AS (
    SELECT
        SI.StockItemID,
        SI.StockItemName,
        SUM(IL.Quantity * IL.UnitPrice) AS TotalSales
    FROM dbo.StockItems AS SI
    INNER JOIN dbo.InvoiceLines AS IL
        ON SI.StockItemID = IL.StockItemID
    GROUP BY
        SI.StockItemID,
        SI.StockItemName
)
SELECT
    StockItemID,
    StockItemName,
    TotalSales,
    AVG(TotalSales) OVER () AS AverageProductSales,
    TotalSales - AVG(TotalSales) OVER () AS DifferenceFromAverage
FROM ProductSales
ORDER BY TotalSales DESC;
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- السؤال 1: من هم أفضل 5 عملاء من حيث إجمالي قيمة المشتريات؟
SELECT TOP 5
    C.CustomerID,
    C.CustomerName,
    SUM(IL.Quantity * IL.UnitPrice) AS TotalPurchases
FROM dbo.Customers AS C
INNER JOIN dbo.Invoices AS I
    ON C.CustomerID = I.CustomerID
INNER JOIN dbo.InvoiceLines AS IL
    ON I.InvoiceID = IL.InvoiceID
GROUP BY
    C.CustomerID,
    C.CustomerName
ORDER BY TotalPurchases DESC;
GO

-- السؤال 2: ما إجمالي المبيعات في كل شهر؟
SELECT
    YEAR(I.InvoiceDate) AS SalesYear,
    MONTH(I.InvoiceDate) AS SalesMonth,
    SUM(IL.Quantity * IL.UnitPrice) AS MonthlySales
FROM dbo.Invoices AS I
INNER JOIN dbo.InvoiceLines AS IL
    ON I.InvoiceID = IL.InvoiceID
GROUP BY
    YEAR(I.InvoiceDate),
    MONTH(I.InvoiceDate)
ORDER BY
    SalesYear,
    SalesMonth;
GO

-- السؤال 3: ما أفضل 10 منتجات من حيث إجمالي المبيعات؟
SELECT TOP 10
    SI.StockItemID,
    SI.StockItemName,
    SUM(IL.Quantity * IL.UnitPrice) AS TotalSales
FROM dbo.StockItems AS SI
INNER JOIN dbo.InvoiceLines AS IL
    ON SI.StockItemID = IL.StockItemID
GROUP BY
    SI.StockItemID,
    SI.StockItemName
ORDER BY TotalSales DESC;
GO

-- السؤال 4: ما إجمالي المبيعات وعدد الفواتير لكل فئة من العملاء؟
SELECT
    CC.CustomerCategoryID,
    CC.CustomerCategoryName,
    COUNT(DISTINCT I.InvoiceID) AS TotalInvoices,
    SUM(IL.Quantity * IL.UnitPrice) AS TotalSales
FROM dbo.CustomerCategories AS CC
INNER JOIN dbo.Customers AS C
    ON CC.CustomerCategoryID = C.CustomerCategoryID
INNER JOIN dbo.Invoices AS I
    ON C.CustomerID = I.CustomerID
INNER JOIN dbo.InvoiceLines AS IL
    ON I.InvoiceID = IL.InvoiceID
GROUP BY
    CC.CustomerCategoryID,
    CC.CustomerCategoryName
ORDER BY TotalSales DESC;
GO

-- السؤال 5: ما متوسط قيمة الفاتورة، وما أعلى وأقل قيمة فاتورة؟
WITH InvoiceTotals AS (
    SELECT
        InvoiceID,
        SUM(Quantity * UnitPrice) AS InvoiceValue
    FROM dbo.InvoiceLines
    GROUP BY InvoiceID
)
SELECT
    AVG(InvoiceValue) AS AverageInvoiceValue,
    MAX(InvoiceValue) AS HighestInvoiceValue,
    MIN(InvoiceValue) AS LowestInvoiceValue
FROM InvoiceTotals;
---------------------------------------------------------------------------------------------------------------------------------