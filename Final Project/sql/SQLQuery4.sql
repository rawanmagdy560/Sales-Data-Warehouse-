/***********************************Data Cleaning*****************************************/
-------------------------------------------------------------------
                         /*DimProduct*/
-------------------------------------------------------------------
select *
from DimProduct;
-------------------------------------------------------------------
/*1-(DimProduct)استبدل القيم*/
-------------------------------------------------------------------
update DimProduct
set Brand ='Unknown'
where Brand is NULL;
-------
 update DimProduct
 set ProductSize = 'Unknown'
 where ProductSize is NULL;
-------
-------------------------------------------------------------------
/*2-(DimProduct) داتا تايب */
-------------------------------------------------------------------
/*(int)غيرنا الداتا تايب لي   
عشان تكون اعداد صحيحه */
alter Table DimProduct
alter column UnitPrice int;
-------------------------------------------------------------------
/*3-(DimProduct) تنظيف المسافات  */
-------------------------------------------------------------------
update DimProduct
SET ProductName = Ltrim (rtrim(ProductName)),
    Brand       = Ltrim (rtrim(Brand)),
    ProductSize = Ltrim (rtrim(ProductSize)),
    TaxRate     = Ltrim (rtrim(TaxRate)),
    UnitPrice   =Ltrim (rtrim(UnitPrice));

select*
from dbo.FactSales; 
-------------------------------------------------------------------
/*1-(dbo.FactSales) تنظيف المسافات  */
-------------------------------------------------------------------
update dbo.FactSales
SET CustomerKey     = Ltrim (rtrim(CustomerKey)),
    ProductKey      = Ltrim (rtrim(ProductKey)),
    Quantity        = Ltrim (rtrim(Quantity)),
    TaxAmount       = Ltrim (rtrim(TaxAmount)),
    UnitPrice       =Ltrim  (rtrim(UnitPrice)),
    LineProfit      =Ltrim  (rtrim(LineProfit)),
    ExtendedPrice   =Ltrim  (rtrim(ExtendedPrice));
-------------------------------------------------------------------
/*2-(dbo.FactSales) داتا تايب */
-------------------------------------------------------------------
/*من جدول الفاكت خلينا الارقم صحيحه */
alter Table dbo.FactSales
alter column UnitPrice int;
alter Table dbo.FactSales
alter column TaxAmount int;
alter Table dbo.FactSales
alter column LineProfit int;
alter Table dbo.FactSales
alter column ExtendedPrice int;

-------------------------------------------------------------------
                         /*bim customer*/
-------------------------------------------------------------------
select*
from dbo.DimCustomer;
-------------------------------------------------------------------
/*1-(dimcustomer)تنظيف مسافات في جدول */
-------------------------------------------------------------------
update dbo.DimCustomer
SET CustomerName              = Ltrim (rtrim(CustomerName)),
    CustomerCategoryName      = Ltrim (rtrim(CustomerCategoryName)),
    DeliveryCityName          = Ltrim (rtrim(DeliveryCityName));
-------------------------------------------------------------------
                           /*db.Cities*/
-------------------------------------------------------------------
select*
from dbo.Cities;
-------------------------------------------------------------------
/*1-(dbo.Cities) ب0استبدل القيم*/
-------------------------------------------------------------------
update dbo.Cities
set LatestRecordedPopulation ='0'
where LatestRecordedPopulation is NULL;
-------------------------------------------------------------------
/*db.Cities تغير الداتا تايب */
-------------------------------------------------------------------
/*تعديل بيانات (Data Update) فقط داخل الجدول.)*/
UPDATE dbo.Cities
SET ValidTo = '2099-12-31 23:59:59.0000000'
WHERE ValidTo LIKE '9999-12-31%';
/*تعديل هيكل ووصف الجدول (Data Type / Schema Change)*/
ALTER TABLE dbo.Cities
ALTER COLUMN ValidFrom DATE;
ALTER TABLE dbo.Cities
ALTER COLUMN ValidTo DATE;
-------------------------------------------------------------------
                         /* dbo.CustomerCategories*/
-------------------------------------------------------------------
SELECT*
FROM dbo.CustomerCategories;
-------------------------------------------------------------------
/*dbo.CustomerCategories تغير الداتا تايب */
-------------------------------------------------------------------
ALTER TABLE dbo.CustomerCategories
ALTER COLUMN ValidFrom DATE;
ALTER TABLE dbo.CustomerCategories
ALTER COLUMN ValidTo DATE;
---------------------------------------
UPDATE dbo.CustomerCategories
SET ValidTo = '2099-12-31 23:59:59.0000000'
WHERE ValidTo LIKE '9999-12-31%';
-------------------------------------------------------------------
                              /*db.Cities*/
-------------------------------------------------------------------
SELECT *
from dbo.Customers;
-------------------------------------------------------------------
/*1-(dbo.Customers)تنظيف مسافات في جدول */
-------------------------------------------------------------------
UPDATE dbo.Customers
set CustomerName            =Ltrim(rtrim(CustomerName)),
    DeliveryAddressLine1    =Ltrim(rtrim(DeliveryAddressLine1)),
    DeliveryAddressLine2    =Ltrim(rtrim(DeliveryAddressLine2)),
    WebsiteURL              =ltrim(rtrim(WebsiteURL)),
    PostalAddressLine1      =Ltrim(rtrim(PostalAddressLine1)),
    PostalAddressLine2      =Ltrim(rtrim(PostalAddressLine2)),
    PostalPostalCode        =Ltrim(rtrim(PostalPostalCode));
 -------------------------------------------------------------------
 /*1-(dbo.Customers) ب0استبدل القيم*/
 -------------------------------------------------------------------
 update dbo.Customers
 set CreditLimit='0'
 where CreditLimit is NULL;
 -------------------------------------------------------------------
 /*1-(dbo.Customers) مسح عمودين*/
 -------------------------------------------------------------------
 /*DeliveryRun (جولة/خط الشحن)*/
 /*RunPosition (ترتيب التسليم)*/
 Alter table dbo.Customers
 Drop column DeliveryRun,RunPosition;
 -------------------------------------------------------------------
 /*dbo.Customers تغير الداتا تايب */
 -------------------------------------------------------------------
 alter Table dbo.Customers
 alter COlumn Creditlimit int;
 -------------------------------------------------------------------
 /*dbo.Customers تغير الداتا تايب */
 -------------------------------------------------------------------
UPDATE dbo.Customers
SET ValidTo = '2099-12-31 23:59:59.0000000'
WHERE ValidTo LIKE '9999-12-31%';
/*تعديل هيكل ووصف الجدول (Data Type / Schema Change)*/
ALTER TABLE dbo.Customers
ALTER COLUMN ValidFrom DATE;
ALTER TABLE dbo.Customers
ALTER COLUMN ValidTo DATE;
-------------------------------------------------------------------
                           /*1-(dbo.InvoiceLines) */
 -------------------------------------------------------------------
 select *
 from dbo.InvoiceLines;
 --------------------------------------------------------------------
  /*-(dbo.InvoiceLines) المسافات*/
-------------------------------------------------------------------
 update dbo.InvoiceLines
 set Description =Ltrim(rtrim( Description));
  -------------------------------------------------------------------
  /*-(dbo.InvoiceLines) تغير الداتا تايب*/
 -------------------------------------------------------------------
 Alter table dbo.InvoiceLines
 alter column UnitPrice int;
 alter table dbo.InvoiceLines
 alter column TaxAmount int;
 alter table dbo.InvoiceLines
 alter column LineProfit int;
 alter table dbo.InvoiceLines
 alter column ExtendedPrice int ;
-------------------------------------------------------------------
ALTER TABLE dbo.InvoiceLines
alter column LastEditedWhen date;
-------------------------------------------------------------------
                       /*1-(dbo.InvoiceLines) */
-------------------------------------------------------------------
 select* 
 from dbo.Invoices;
-------------------------------------------------------------------
 /*1-(dbo.Invoices) مسح عمودين*/
-------------------------------------------------------------------
  Alter table dbo.Invoices
 Drop column DeliveryRun,RunPosition;
-------------------------------------------------------------------
  /*1-(dbo.Invoices) المسافات*/
-------------------------------------------------------------------
 UPdate dbo.Invoices
 set SalespersonPersonID = Ltrim (rtrim(SalespersonPersonID));
  -------------------------------------------------------------------
  /*1-(dbo.InvoiceLines) تغير الداتا تايب*/
 -------------------------------------------------------------------
 ALTER TABLE dbo.Invoices
alter column ConfirmedDeliveryTime date;

 ALTER TABLE dbo.Invoices
alter column LastEditedWhen date;
-------------------------------------------------------------------
                            /*1-(dbo.StockItems) */
 ------------------------------------------------------------------
select*
from dbo.StockItems;
 ----------------------------------------------------------------
 /*1-(dbo.StockItems) ب0استبدل القيم*/
 ----------------------------------------------------------------
Update dbo.StockItems
set ColorID = '0'
Where ColorID is NULL;

UPdate dbo.StockItems
                        set Brand ='Unknown'
                        where Brand is NULL;
Update dbo.StockItems
                        set Size ='unknown'
                        where Size is NULL;
 --------------------------------------------------------------
 /*1-(dbo.StockItems) مسح عمود*/
 --------------------------------------------------------------
ALTER TABLE dbo.StockItems
                       Drop column InternalComments;
Alter Table dbo.StockItems
                       Drop column Photo;
alter table dbo.StockItems
                      alter column UnitPrice int;
alter table  dbo.StockItems
                    alter column RecommendedRetailPrice int;

 ----------------------------------------------------------------
  /*1-(dbo.StockItems) تغير الداتا تايب*/
 ----------------------------------------------------------------
alter table dbo.StockItems
                    alter column ValidFrom date;
alter table dbo.StockItems
                    alter column ValidTo date;

update dbo.StockItems
                    set ValidFrom='2016-05-31 23:11:00.0000000'
                    where ValidFrom Like '2016-05-31%'
UPDATE dbo.StockItems
                   SET ValidTo = '2099-12-31 23:59:59.0000000'
                   WHERE ValidTo LIKE '9999-12-31%';