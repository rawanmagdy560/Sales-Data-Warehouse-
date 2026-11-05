----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
------------------------------------------------
/* 7) إنشاء جدول أبعاد العملاء*/
------------------------------------------------
IF OBJECT_ID('dbo.DimCustomer', 'U') IS NULL
BEGIN
CREATE TABLE dbo.DimCustomer(CustomerKey          INT IDENTITY(1,1) PRIMARY KEY,
                             SourceCustomerID     INT NOT NULL UNIQUE,
                             CustomerName         NVARCHAR(100) NOT NULL,
                             CustomerCategoryName NVARCHAR(100) NULL,
                             DeliveryCityName      NVARCHAR(100) NULL);
END;
------------------------------------------------
/*إنشاء جدول أبعاد المنتجات*/
------------------------------------------------
IF OBJECT_ID('dbo.DimProduct', 'U') IS NULL
BEGIN CREATE TABLE dbo.DimProduct(ProductKey INT IDENTITY(1,1) PRIMARY KEY,
                                  SourceStockItemID INT NOT NULL UNIQUE,
                                  ProductName NVARCHAR(100) NOT NULL,
                                  Brand NVARCHAR(100) NULL,
                                  ProductSize NVARCHAR(40) NULL,
                                  TaxRate DECIMAL(18,3) NULL,
                                  UnitPrice DECIMAL(18,2) NULL);
END;
------------------------------------------------
-- إنشاء جدول أبعاد التواريخ
------------------------------------------------
IF OBJECT_ID('dbo.DimDate', 'U') IS NULL
BEGIN CREATE TABLE dbo.DimDate (DateKey INT PRIMARY KEY,
                                FullDate DATE NOT NULL UNIQUE,
                                CalendarYear INT NOT NULL,
                                CalendarMonth INT NOT NULL,
                                MonthName NVARCHAR(20) NOT NULL,
                                CalendarQuarter int NOT NULL);
END;
------------------------------------------------
-- إنشاء جدول الحقائق وربطه بجداول الأبعاد
------------------------------------------------
IF OBJECT_ID('dbo.FactSales', 'U') IS NULL
BEGIN CREATE TABLE dbo.FactSales(InvoiceLineID INT PRIMARY KEY,
                                 InvoiceID INT NOT NULL,
                                 DateKey INT NOT NULL,
                                 CustomerKey INT NOT NULL,
                                 ProductKey INT NOT NULL,
                                 Quantity INT NOT NULL,
                                 UnitPrice DECIMAL(18,2) NOT NULL,
                                 TaxAmount DECIMAL(18,2) NOT NULL,
                                 LineProfit DECIMAL(18,2) NOT NULL,
                                 ExtendedPrice DECIMAL(18,2) NOT NULL,CONSTRAINT FK_FactSales_DimDate 
FOREIGN KEY (DateKey)
REFERENCES dbo.DimDate(DateKey),
CONSTRAINT FK_FactSales_DimCustomer
FOREIGN KEY (CustomerKey)
REFERENCES dbo.DimCustomer(CustomerKey),
CONSTRAINT FK_FactSales_DimProduct
FOREIGN KEY (ProductKey)
REFERENCES dbo.DimProduct(ProductKey));
---------------------------------------------------------------------
/* نقل بيانات العملاء */
---------------------------------------------------------------------
INSERT INTO dbo.DimCustomer(SourceCustomerID,CustomerName,CustomerCategoryName, DeliveryCityName)
SELECT c.CustomerID, c.CustomerName,cc.CustomerCategoryName, ci.CityName
FROM WideWorldImporters.Sales.Customers AS c
LEFT JOIN WideWorldImporters.Sales.CustomerCategories AS cc
ON c.CustomerCategoryID = cc.CustomerCategoryID
LEFT JOIN WideWorldImporters.Application.Cities AS ci
ON c.DeliveryCityID = ci.CityID
WHERE NOT EXISTS(
SELECT 1
FROM dbo.DimCustomer AS d
WHERE d.SourceCustomerID = c.CustomerID);
---------------------------------------------------------------------
/* نقل بيانات المنتجات*/
---------------------------------------------------------------------
INSERT INTO dbo.DimProduct(SourceStockItemID,ProductName,Brand,ProductSize,TaxRate,UnitPrice)
SELECT s.StockItemID,s.StockItemName,s.Brand,s.Size,s.TaxRate,s.UnitPrice
                FROM WideWorldImporters.Warehouse.StockItems AS s
                 WHERE NOT EXISTS
(SELECT 1
                 FROM dbo.DimProduct AS d
                 WHERE d.SourceStockItemID = s.StockItemID);
---------------------------------------------------------------------
/*-- نقل تواريخ الفواتير (توليد DateKey بصيغة YYYYMMDD*/
---------------------------------------------------------------------
INSERT INTO dbo.DimDate
(DateKey,FullDate,CalendarYear,CalendarMonth,MonthName,CalendarQuarter)
SELECT DISTINCT CONVERT(INT, CONVERT(CHAR(8), i.InvoiceDate, 112)),i.InvoiceDate,YEAR(i.InvoiceDate),MONTH(i.InvoiceDate),DATENAME(MONTH, i.InvoiceDate),DATEPART(QUARTER, i.InvoiceDate)
FROM WideWorldImporters.Sales.Invoices AS i
WHERE NOT EXISTS
(SELECT 1
 FROM dbo.DimDate AS d 
 WHERE d.FullDate = i.InvoiceDate);
---------------------------------------------------------------------
/*-- ملء جدول الحقائق FactSales بربط مفاتيح الأبعاد (Surrogate Keys)*/
---------------------------------------------------------------------
INSERT INTO dbo.FactSales
(InvoiceLineID,InvoiceID,DateKey,CustomerKey,ProductKey,Quantity,UnitPrice,TaxAmount,LineProfit,ExtendedPrice)
SELECT il.InvoiceLineID, i.InvoiceID,d.DateKey,dc.CustomerKey,dp.ProductKey,il.Quantity,il.UnitPrice,il.TaxAmount,il.LineProfit,il.ExtendedPrice
FROM WideWorldImporters.Sales.InvoiceLines AS il
INNER JOIN WideWorldImporters.Sales.Invoices AS i
    ON il.InvoiceID = i.InvoiceID
INNER JOIN dbo.DimCustomer AS dc
    ON i.CustomerID = dc.SourceCustomerID
INNER JOIN dbo.DimProduct AS dp
    ON il.StockItemID = dp.SourceStockItemID
INNER JOIN dbo.DimDate AS d
    ON i.InvoiceDate = d.FullDate
WHERE NOT EXISTS
(SELECT 1
FROM dbo.FactSales AS f
WHERE f.InvoiceLineID = il.InvoiceLineID);
---------------------------------------------------------------------
/*-- التحقق من إجمالي الصفوف في كل جدول*/
---------------------------------------------------------------------
SELECT 'DimCustomer' AS TableName,COUNT_BIG(*) AS TotalRows
      FROM dbo.DimCustomer
      UNION ALL
SELECT 'DimProduct',COUNT_BIG(*)
     FROM dbo.DimProduct
     UNION ALL
SELECT 'DimDate',COUNT_BIG(*)
     FROM dbo.DimDate
     UNION ALl
SELECT 'FactSales', COUNT_BIG(*)
     FROM dbo.FactSales;
---------------------------------------------------------------------
/*فحص القيم الفارغة في الأبعاد*/
---------------------------------------------------------------------
SELECT COUNT_BIG(*) AS TotalRows, SUM(CASE WHEN CustomerName IS NULL THEN 1 ELSE 0 END) AS NullCustomerNames,SUM(CASE WHEN CustomerCategoryName IS NULL THEN 1 ELSE 0 END) AS NullCategories, SUM(CASE WHEN DeliveryCityName IS NULL THEN 1 ELSE 0 END) AS NullCities
FROM dbo.DimCustomer;
SELECT COUNT_BIG(*) AS TotalRows, SUM(CASE WHEN Brand IS NULL THEN 1 ELSE 0 END) AS NullBrands, SUM(CASE WHEN ProductSize IS NULL THEN 1 ELSE 0 END) AS NullSizes
FROM dbo.DimProduct;
---------------------------------------------------------------------
/*فحص التكرارات في المعرفات الأساسية*/
---------------------------------------------------------------------
SELECT SourceCustomerID, COUNT(*) AS DuplicateCount
       FROM dbo.DimCustomer
       GROUP BY SourceCustomerID
       HAVING COUNT(*) > 1;
SELECT SourceStockItemID, COUNT(*) AS DuplicateCount
      FROM dbo.DimProduct
      GROUP BY SourceStockItemID
      HAVING COUNT(*) > 1;
SELECT InvoiceLineID, COUNT(*) AS DuplicateCount
      FROM dbo.FactSales
      GROUP BY InvoiceLineID
      HAVING COUNT(*) > 1;
---------------------------------------------------------------
/*فحص القيم غير المنطقية (السالبة) في الحقائق والمنتجات*/
---------------------------------------------------------------------
SELECT *
FROM dbo.FactSales
WHERE Quantity < 0
   OR UnitPrice < 0
   OR ExtendedPrice < 0
   OR TaxAmount < 0;
SELECT *
FROM dbo.DimProduct
WHERE UnitPrice < 0
   OR TaxRate < 0;