-- viewing table data
USE ContosoRetailDW

 -- Dimensional Data --
SELECT * FROM DBO.DimAccount
SELECT * FROM DBO.DimChannel  -- MODE IN WHICH GOODS ARE SOLD   : 4 WAYS TO SELL PRODUCTS -> STORE, ONLINE,CATALOG, RESELLER
SELECT DISTINCT * FROM DBO.DimCurrency -- CURRENCY FOR ALL TRANSACTIONS : ABOUT 28 DIFFERENT CURRENCIES
SELECT TOP 100 * FROM DBO.DimCustomer  -- CUSTOMER DATA
SELECT * FROM DBO.DimDate     -- TIME AND SEASON DATA
SELECT * FROM DBO.DimEmployee -- EMPLOYEES DATA
SELECT * FROM DBO.DimGeography -- contintental distribution
SELECT * FROM DBO.DimMachine
SELECT * FROM DBO.DimOutage
SELECT distinct ProductSubcategoryKey FROM DBO.DimProduct -- Product Data
order by ProductSubcategoryKey desc
SELECT * FROM DBO.DimProductCategory -- Categorical data
SELECT * FROM DBO.DimProductSubcategory
select productsubcategorykey, ProductSubcategoryName From Dbo.DimProductSubcategory
SELECT * FROM DBO.DimPromotion -- Promtional Data
SELECT * FROM DBO.DimSalesTerritory -- Territorial Data
SELECT * FROM DBO.DimScenario -- 
SELECT * FROM DBO.DimStore -- store data

-- Factual Data -- Real Data from actual events
SELECT * FROM DBO.FactExchangeRate
SELECT * FROM DBO.FactInventory  -- Factory inventroy
SELECT * FROM DBO.FactITMachine
SELECT * FROM DBO.FactITSLA
SELECT top 100  * FROM DBO.FactOnlineSales -- Interesting sales
SELECT top 100 * FROM DBO.FactSalesQuota -- Quota's
SELECT * FROM DBO.FactStrategyPlan


-- Project Sales Quota vs reality
-- product data and sales data to be joined by product key - that way we can see what product sold for how much and assess the sales data
SELECT * FROM DBO.DimProduct -- Product Data
SELECT top 30  * FROM DBO.FactOnlineSales -- Interesting sales
order by ProductKey

-- Aggregated sales
with Agg_sales as(
SELECT 
  ProductKey,
  left(datekey,6) as Sale_month_year,
  SUM(SalesQuantity) AS TotalSalesQuantity,
  SUM(SalesAmount) AS TotalSalesAmount,
  SUM(ReturnQuantity) AS TotalReturnQuantity,
  SUM(ReturnAmount) AS TotalReturnAmount,
  SUM(DiscountQuantity) AS TotalDiscountQuantity,
  SUM(DiscountAmount) AS TotalDiscountAmount,
  SUM(TotalCost) AS TotalCost,
  AVG(UnitCost) AS AvgUnitCost,
  AVG(UnitPrice) AS AvgUnitPrice
FROM FactOnlineSales
GROUP BY ProductKey,left(datekey,6)
)
select top 50 * from Agg_sales
order by ProductKey

SELECT top 30  * FROM DBO.FactOnlineSales -- Interesting sales
order by ProductKey
               
-- Quota's - target results

-- how do i get to compare the quotas with the results {side by side comparison}

-- Unfiltered joined sales and prodcut data -> added subcategroy table to get catefory of products
with product_sales as (
select P.ProductKey, P.ProductName, P.ProductDescription, Sb.ProductSubcategoryName,P.Manufacturer,P.BrandName,
		P.ClassName,P.ColorName,P.Weight,P.WeightUnitMeasureID,P.UnitOfMeasureName,P.StockTypeName,
		
		S.StoreKey,S.PromotionKey,S.CurrencyKey,S.CustomerKey,S.SalesQuantity,S.SalesAmount,S.ReturnQuantity,S.ReturnAmount,
		S.DiscountQuantity,S.DiscountAmount,S.TotalCost,S.UnitCost as sale_unit_cost,S.UnitPrice as Sale_unit_price, S.DateKey as Sale_Date
		from DBO.DimProduct P
		Join Dbo.FactOnlineSales S 
		on P.ProductKey = S.ProductKey
		join Dbo.DimProductSubcategory Sb 
		on P.ProductSubcategoryKey = Sb.ProductSubcategoryKey 

)
select top 100 * from product_sales

SELECT top 100 * FROM DBO.FactSalesQuota -- Quota's - target results
-- Temportay table
Select top 1000000 P.ProductKey, P.ProductName, P.ProductDescription, Sb.ProductSubcategoryName,P.Manufacturer,P.BrandName,
		P.ClassName,P.ColorName,P.Weight,P.WeightUnitMeasureID,P.UnitOfMeasureName,P.StockTypeName,
		S.StoreKey,S.PromotionKey,S.CurrencyKey,S.CustomerKey,S.SalesQuantity,S.SalesAmount,S.ReturnQuantity,S.ReturnAmount,
		S.DiscountQuantity,S.DiscountAmount,S.TotalCost,S.UnitCost as sale_unit_cost,S.UnitPrice as Sale_unit_price, S.DateKey as Sale_Date
		INTO #PRODUCT_TABLE 
		FROM DBO.DimProduct P
		Join Dbo.FactOnlineSales S 
		on P.ProductKey = S.ProductKey
		join Dbo.DimProductSubcategory Sb 
		on P.ProductSubcategoryKey = Sb.ProductSubcategoryKey 

-- Optional: add indexes to speed up later joins/filters
CREATE INDEX IX_product_sales_ProductKey ON #PRODUCT_TABLE(ProductKey);

-- joining with sales quota 
Select TOP (1000000)  P.ProductKey, P.ProductName, P.ProductDescription, P.ProductSubcategoryName,P.Manufacturer,P.BrandName,
		P.ClassName,P.ColorName,P.Weight,P.WeightUnitMeasureID,P.UnitOfMeasureName,P.StockTypeName,
		P.StoreKey,P.PromotionKey,P.CurrencyKey,P.CustomerKey,P.SalesQuantity,P.SalesAmount,P.ReturnQuantity,P.ReturnAmount,
		P.DiscountQuantity,P.DiscountAmount,P.TotalCost, P.sale_unit_cost,P.Sale_unit_price,LEFT(P.Sale_Date, 6) AS Sale_YearMonth,
		LEFT(S.DateKey, 6) as Quota_Year_Month, S.ChannelKey,S.SalesQuantityQuota, S.SalesAmountQuota, S.GrossMarginQuota
		INTO #FINAL_SALES 
		from #PRODUCT_TABLE P
join Dbo.FactSalesQuota S 
on  P.ProductKey = S.ProductKey AND LEFT(P.Sale_Date, 6) = LEFT(S.DateKey, 6)



select top 100 * from #FINAL_SALES
 
select top 5000 productkey, TRIM(ProductName) AS ProductName,	Quota_Year_Month, sum(SalesAmountQuota) as total_quota, sum(salesAmount) as total_sales, 
case
		   WHEN SUM(SalesAmount) >= SUM(SalesAmountQuota) THEN 'Met'
        ELSE 'Not Met'
end as Quota_Status
from #FINAL_SALES
group by productkey, TRIM(productname),	Quota_Year_Month 
order by total_sales desc;

SELECT top 50 
  ProductKey,
  TRIM(ProductName) AS ProductName,
  Quota_Year_Month,
  SalesAmountQuota,
  SalesAmount
FROM #FINAL_SALES
ORDER BY ProductKey, Quota_Year_Month


SELECT 
    ProductKey,
    TRIM(ProductName) AS ProductName,
    Quota_Year_Month,
    SUM(SalesAmountQuota) AS TotalQuota,
    SUM(SalesAmount) AS TotalActualSales,
    -- Optional: performance ratio
    ROUND(
        CASE 
            WHEN SUM(SalesAmountQuota) = 0 THEN NULL 
            ELSE (SUM(SalesAmount) * 100.0) / SUM(SalesAmountQuota) 
        END, 
    2) AS AchievementPercent
FROM #FINAL_SALES
GROUP BY 
    ProductKey, 
    TRIM(ProductName),
    Quota_Year_Month
ORDER BY 
    AchievementPercent ;








	---------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------
	------------------------------Better Analysis on Sales and quota-----------------------------
	---------------------------------------------------------------------------------------------

	-- Aggregated sales
with Agg_sales as(
SELECT 
  ProductKey,
  FORMAT(DateKey, 'MMM yyyy') as Sale_month_year,
  SUM(SalesQuantity) AS TotalSalesQuantity,
  SUM(SalesAmount) AS TotalSalesAmount,
  SUM(ReturnQuantity) AS TotalReturnQuantity,
  SUM(ReturnAmount) AS TotalReturnAmount,
  SUM(DiscountQuantity) AS TotalDiscountQuantity,
  SUM(DiscountAmount) AS TotalDiscountAmount,
  SUM(TotalCost) AS TotalCost,
  AVG(UnitCost) AS AvgUnitCost,
  AVG(UnitPrice) AS AvgUnitPrice
FROM FactOnlineSales
GROUP BY ProductKey,FORMAT(DateKey, 'MMM yyyy')
),
agg_quota as (
Select 
	ProductKey,
	FORMAT(DateKey, 'MMM yyyy') as Quota_month_date,
	Avg(SalesQuantityQuota) as AVG_sales_quant_quota,
	SUM(SalesAmountQuota) AS TotalSalesQuota,
	sum(GrossmarginQuota) As TotalMarginQuota

from FactSalesQuota
group by productkey,FORMAT(DateKey, 'MMM yyyy')
),
joined_sales_quota as (
---joining agg_sales and agg-quota
select S.productkey, S.Sale_month_year, S.TotalSalesQuantity, S.TotalSalesAmount,S.TotalReturnQuantity,
		S.TotalReturnAmount,S.TotalDiscountQuantity,S.TotalDiscountAmount,S.TotalCost,S.AvgUnitCost,S.AvgUnitPrice,
		Q.Quota_month_date,Q.AVG_sales_quant_quota,Q.TotalSalesQuota,Q.TotalMarginQuota
from Agg_sales S
Left Join agg_quota Q
on S.productkey = Q.productkey and S.Sale_month_year = Q.Quota_month_date
),
product_sales_quota as (
select P.ProductKey, P.ProductName, P.ProductDescription, P.ProductSubcategoryKey,P.Manufacturer,P.BrandName,
		P.ClassName,P.ColorName,P.Weight,P.WeightUnitMeasureID,P.UnitOfMeasureName,P.StockTypeName,
		SQ.Sale_month_year, SQ.TotalSalesQuantity, SQ.TotalSalesAmount,SQ.TotalReturnQuantity,
		SQ.TotalReturnAmount,SQ.TotalDiscountQuantity,SQ.TotalDiscountAmount,SQ.TotalCost,SQ.AvgUnitCost,SQ.AvgUnitPrice,
		SQ.Quota_month_date,SQ.AVG_sales_quant_quota,SQ.TotalSalesQuota,SQ.TotalMarginQuota
FROM DBO.DimProduct P
JOIN joined_sales_quota SQ
ON P.ProductKey = SQ.ProductKey
)

SELECT TOP 50 * FROM product_sales_quota
ORDER BY PRODUCTKEY, Sale_month_year


----------------------------------------------------------------
----------------------------------------------------------------
------------Table Making----------------------------------------

SELECT 
    P.ProductKey, P.ProductName, P.ProductDescription, P.ProductSubcategoryKey, P.Manufacturer, P.BrandName,
    P.ClassName, P.ColorName, P.Weight, P.WeightUnitMeasureID, P.UnitOfMeasureName, P.StockTypeName,
    SQ.Sale_month_year, SQ.TotalSalesQuantity, SQ.TotalSalesAmount, SQ.TotalReturnQuantity,
    SQ.TotalReturnAmount, SQ.TotalDiscountQuantity, SQ.TotalDiscountAmount, SQ.TotalCost, SQ.AvgUnitCost, SQ.AvgUnitPrice,
    SQ.Quota_month_date, SQ.AVG_sales_quant_quota, SQ.TotalSalesQuota, SQ.TotalMarginQuota, SQ.CustomerKey
INTO dbo.ProductSalesQuota_Final_2
FROM DBO.DimProduct P
JOIN (
    SELECT 
        S.productkey, S.CustomerKey, S.Sale_month_year, S.TotalSalesQuantity, S.TotalSalesAmount, S.TotalReturnQuantity,
        S.TotalReturnAmount, S.TotalDiscountQuantity, S.TotalDiscountAmount, S.TotalCost, S.AvgUnitCost, S.AvgUnitPrice,
        Q.Quota_month_date, Q.AVG_sales_quant_quota, Q.TotalSalesQuota, Q.TotalMarginQuota
    FROM (
        SELECT 
            ProductKey,
			CustomerKey,
            FORMAT(DateKey, 'MMM yyyy') as Sale_month_year,
            SUM(SalesQuantity) AS TotalSalesQuantity,
            SUM(SalesAmount) AS TotalSalesAmount,
            SUM(ReturnQuantity) AS TotalReturnQuantity,
            SUM(ReturnAmount) AS TotalReturnAmount,
            SUM(DiscountQuantity) AS TotalDiscountQuantity,
            SUM(DiscountAmount) AS TotalDiscountAmount,
            SUM(TotalCost) AS TotalCost,
            AVG(UnitCost) AS AvgUnitCost,
            AVG(UnitPrice) AS AvgUnitPrice
        FROM FactOnlineSales
        GROUP BY ProductKey,CustomerKey, FORMAT(DateKey, 'MMM yyyy')
    ) S
    LEFT JOIN (
        SELECT 
            ProductKey,
            FORMAT(DateKey, 'MMM yyyy') as Quota_month_date,
            AVG(SalesQuantityQuota) as AVG_sales_quant_quota,
            SUM(SalesAmountQuota) AS TotalSalesQuota,
            SUM(GrossmarginQuota) As TotalMarginQuota
        FROM FactSalesQuota
        GROUP BY ProductKey, FORMAT(DateKey, 'MMM yyyy')
    ) Q
    ON S.ProductKey = Q.ProductKey AND S.Sale_month_year = Q.Quota_month_date
) SQ
ON P.ProductKey = SQ.ProductKey;

Select top 100 * from ProductSalesQuota_Final

select top 50 productkey, ProductName,Sale_month_year, Quota_month_date, TotalSalesAmount,TotalSalesQuota,
	case
		when TotalSalesAmount >= TotalSalesQuota then 'Met'
		else 'Not Me'
	end as quota_status
from ProductSalesQuota_Final
order by ProductName,Sale_month_year,Quota_month_date

SELECT DISTINCT * FROM ProductSalesQuota_Final



--------------------------------------------------------------------------
------------------------Initial quota and new table data comparison-------

select productkey,productname,Sale_month_year, TotalSalesAmount, TotalSalesQuota from ProductSalesQuota_Final
where productkey = '90'
order by Sale_month_year DESc

SELECT 
	productkey,
    FORMAT(DateKey, 'MMM yyyy') AS Quota_month_date,
    SUM(SalesAmountQuota) AS TotalSalesQuota,
    SUM(GrossMarginQuota) AS TotalMarginQuota
FROM FactSalesQuota
WHERE ProductKey = '90'
GROUP BY productkey, FORMAT(DateKey, 'MMM yyyy')
ORDER BY FORMAT(DateKey, 'MMM yyyy')  Desc



select top 50 * from ProductSalesQuota_Final
where year(Sale_month_year) = '2007' and year(Quota_month_date) = '2007'
ORDER BY Productkey , CAST('01 ' + Sale_month_year AS DATE);



----------------------------------------------------
------------------------------------------New Set------------------------------------------------
------------------------------------------Territorial Data -------------------------------------------

select top 50 *, ((TotalSalesAmount - TotalDiscountAmount) - TotalCost) AS Profit from ProductSalesQuota_Final

-------- -----------------------------------------------------------------------------------------------------
--------------------------------------------Adding Profit to table permanently---------------------------------

Alter Table ProductSalesQuota_Final 
Add Profit Decimal (18, 2);

Update ProductSalesQuota_Final
Set Profit = (TotalSalesAmount - TotalDiscountAmount) - TotalCost;


-------------------------------------------------------------------------------------------------------------
-------------------------------------------------preview new table-------------------------------------------
select top 50 * from ProductSalesQuota_Final
SELECT top 50 * FROM DBO.DimGeography -- contintental distribution
SELECT top 50 * FROM DBO.DimSalesTerritory -- Territorial Data
SELECT top 50 * FROM FactOnlineSales -- Product Data
SELECT TOP 50 * FROM DBO.DimCustomer  -- CUSTOMER DATA




-----------------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------Territoty Customer Data------------------------------------------------------------------

select top 1000000 C.CustomerKey,C.GeographyKey,C.CustomerLabel,C.Title,C.FirstName,C.LastName,C.NameStyle,C.BirthDate,
		C.MaritalStatus,C.Suffix,C.Gender,C.EmailAddress,C.YearlyIncome,C.TotalChildren,C.Education,
		C.Occupation,C.HouseOwnerFlag,C.NumberCarsOwned,C.Phone,C.DateFirstPurchase,C.CustomerType,C.CompanyName,
		GeographyType,G.ContinentName,G.CityName,G.StateProvinceName,G.RegionCountryName,
		S.ProductKey,
        FORMAT(S.DateKey, 'MMM yyyy') as Sale_month_year,
        SUM(S.SalesQuantity) AS TotalSalesQuantity,
        SUM(S.SalesAmount) AS TotalSalesAmount,
        SUM(S.ReturnQuantity) AS TotalReturnQuantity,
        SUM(S.ReturnAmount) AS TotalReturnAmount,
		SUM(S.DiscountQuantity) AS TotalDiscountQuantity,
        SUM(S.DiscountAmount) AS TotalDiscountAmount,
        SUM(S.TotalCost) AS TotalCost,
        AVG(S.UnitCost) AS AvgUnitCost,
        AVG(S.UnitPrice) AS AvgUnitPrice
Into Geo_Cust_Sale

from dbo.DimCustomer C
LEFT JOIN dbo.DimGeography G
on C.GeographyKey = G.GeographyKey
Left join FactOnlineSales S
on C.CustomerKey = S.CustomerKey

GROUP BY
    C.CustomerKey,C.GeographyKey,C.CustomerLabel,C.Title,C.FirstName,C.LastName,C.NameStyle,C.BirthDate,C.MaritalStatus,
    C.Suffix,C.Gender,C.EmailAddress,C.YearlyIncome,C.TotalChildren,C.Education,C.Occupation,C.HouseOwnerFlag,C.NumberCarsOwned,
    C.Phone,C.DateFirstPurchase,C.CustomerType,C.CompanyName,G.GeographyType,G.ContinentName,G.CityName,G.StateProvinceName,G.RegionCountryName,
    S.ProductKey,FORMAT(S.DateKey, 'MMM yyyy');
-----------------------------------------------------------------------------------------------------------------------

select top 50 * from Geo_Cust_Sale
order by CustomerKey Desc
-----------------------------------------------------------------------------------------------------------------------


------------------------------------Geographical data -products, sales geo---------------------------

SELECT TOP 50 * FROM DBO.DimCustomer  -- CUSTOMER DATA
SELECT top 50 * FROM DBO.DimGeography -- Geograpghy
SELECT top 50 * FROM DBO.DimProduct  -- Product Data
SELECT top 50 * FROM FactOnlineSales -- Sales 


/*
customer data has geographical key and Customer key
Geo key is needed to link geogrpahical states
customer key is needed to link to sales 
throuh sales ill be able to link to products through product key

SELECT COUNT(*) AS Row_Count
FROM FactOnlineSales;

*/


WITH GEO_DATA AS (
    SELECT C.CustomerKey, C.GeographyKey,C.Gender, G.GeographyType, G.ContinentName, G.CityName, G.StateProvinceName, G.RegionCountryName
    FROM dbo.DimCustomer C
    LEFT JOIN dbo.DimGeography G ON C.GeographyKey = G.GeographyKey
),
Geo_Sales AS (
    SELECT GD.CustomerKey, GD.GeographyType, GD.ContinentName, GD.CityName, GD.StateProvinceName, GD.RegionCountryName, 
           S.ProductKey, FORMAT(S.DateKey, 'MMM yyyy') AS Sale_month_year, S.SalesQuantity, S.SalesAmount, S.ReturnQuantity, S.ReturnAmount, 
           S.DiscountQuantity, S.DiscountAmount, S.TotalCost, S.UnitCost, S.UnitPrice
    FROM GEO_DATA GD
    INNER JOIN dbo.FactOnlineSales S ON GD.CustomerKey = S.CustomerKey
),
Geo_Prods AS (
    SELECT GS.CustomerKey, GS.GeographyType, GS.ContinentName, GS.CityName, GS.StateProvinceName, GS.RegionCountryName, GS.ProductKey, GS.Sale_month_year, GS.SalesQuantity, GS.SalesAmount, GS.ReturnQuantity, GS.ReturnAmount, GS.DiscountQuantity, GS.DiscountAmount, GS.TotalCost, GS.UnitCost, GS.UnitPrice,
           P.ProductName, P.ProductSubcategoryKey, P.Manufacturer, P.BrandName, P.ClassName, P.ColorName, P.Weight, P.StockTypeName
    FROM Geo_Sales GS
    INNER JOIN dbo.DimProduct P ON GS.ProductKey = P.ProductKey
)
SELECT * INTO Final_Geography_Prod_Sales
FROM Geo_Prods;


SELECT COUNT(*) AS Row_Count
FROM Final_Geography_Prod_Sales;


SELECT top 1000000 FG.*, DS.ProductSubcategoryName into Dataset_2 FROM dbo.Final_Geography_Prod_Sales as FG
inner  join dbo.DimProductSubcategory DS
on FG.ProductSubcategoryKey = DS.ProductSubcategoryKey


select top 50 * from Dataset_2
select * from Dataset_2
-- dropping unneded columns

ALTER TABLE Dataset_2
DROP COLUMN Manufacturer;
---------
-------------------Duplicate check
SELECT 
    CustomerKey,
    GeographyType,
    ContinentName,
    CityName,
    StateProvinceName,
    RegionCountryName,
    ProductKey,
    Sale_month_year,
    SalesQuantity,
    SalesAmount,
    ReturnQuantity,
    ReturnAmount,
    DiscountQuantity,
    DiscountAmount,
    TotalCost,
    UnitCost,
    UnitPrice,
    ProductName,
    ProductSubcategoryKey,
    BrandName,
    ClassName,
    ColorName,
    Weight,
    StockTypeName,
    ProductSubcategoryName,
    COUNT(*) AS duplicate_count
FROM Dataset_2
GROUP BY 
    CustomerKey,
    GeographyType,
    ContinentName,
    CityName,
    StateProvinceName,
    RegionCountryName,
    ProductKey,
    Sale_month_year,
    SalesQuantity,
    SalesAmount,
    ReturnQuantity,
    ReturnAmount,
    DiscountQuantity,
    DiscountAmount,
    TotalCost,
    UnitCost,
    UnitPrice,
    ProductName,
    ProductSubcategoryKey,
    BrandName,
    ClassName,
    ColorName,
    Weight,
    StockTypeName,
    ProductSubcategoryName
HAVING COUNT(*) > 1;



-- Drop Table dbo.Final_Geography_Prod_Sales
------------------TEST---------FactOnlineSales → CustomerKey → DimCustomer → GeographyKey → DimGeography---

/*WITH Agg_sales AS (
  SELECT 
    ProductKey,
    FORMAT(DateKey, 'yyyyMM') AS Sale_month_id,
    SUM(SalesQuantity) AS TotalSalesQuantity,
    SUM(SalesAmount) AS TotalSalesAmount,
    SUM(ReturnQuantity) AS TotalReturnQuantity,
    SUM(ReturnAmount) AS TotalReturnAmount,
    SUM(DiscountQuantity) AS TotalDiscountQuantity,
    SUM(DiscountAmount) AS TotalDiscountAmount,
    SUM(TotalCost) AS TotalCost,
    AVG(UnitCost) AS AvgUnitCost,
    AVG(UnitPrice) AS AvgUnitPrice
  FROM FactOnlineSales
  GROUP BY ProductKey, FORMAT(DateKey, 'yyyyMM')
),
agg_quota AS (
  SELECT 
    ProductKey,
    FORMAT(DateKey, 'yyyyMM') AS Quota_month_id,
    AVG(SalesQuantityQuota) AS AVG_sales_quant_quota,
    SUM(SalesAmountQuota) AS TotalSalesQuota,
    SUM(GrossmarginQuota) AS TotalMarginQuota
  FROM FactSalesQuota
  GROUP BY ProductKey, FORMAT(DateKey, 'yyyyMM')
),
joined_sales_quota AS (
  SELECT 
    S.ProductKey, 
    S.Sale_month_id,
    S.TotalSalesQuantity, S.TotalSalesAmount, S.TotalReturnQuantity,
    S.TotalReturnAmount, S.TotalDiscountQuantity, S.TotalDiscountAmount,
    S.TotalCost, S.AvgUnitCost, S.AvgUnitPrice,
    Q.AVG_sales_quant_quota, Q.TotalSalesQuota, Q.TotalMarginQuota
  FROM Agg_sales S
  LEFT JOIN agg_quota Q
    ON S.ProductKey = Q.ProductKey AND S.Sale_month_id = Q.Quota_month_id
),
product_sales_quota AS (
  SELECT 
    P.ProductKey, P.ProductName, P.ProductDescription, P.ProductSubcategoryKey,
    P.Manufacturer, P.BrandName, P.ClassName, P.ColorName, P.Weight,
    P.WeightUnitMeasureID, P.UnitOfMeasureName, P.StockTypeName,
    SQ.Sale_month_id, SQ.TotalSalesQuantity, SQ.TotalSalesAmount, SQ.TotalReturnQuantity,
    SQ.TotalReturnAmount, SQ.TotalDiscountQuantity, SQ.TotalDiscountAmount,
    SQ.TotalCost, SQ.AvgUnitCost, SQ.AvgUnitPrice,
    SQ.AVG_sales_quant_quota, SQ.TotalSalesQuota, SQ.TotalMarginQuota
  FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY ProductKey ORDER BY ProductKey) AS rn
    FROM DBO.DimProduct
  ) P
  JOIN joined_sales_quota SQ ON P.ProductKey = SQ.ProductKey
  WHERE P.rn = 1
)

*/


SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Dataset_2'
  AND TABLE_SCHEMA = 'dbo'
ORDER BY ORDINAL_POSITION;

SELECT top 50 * FROM DBO.DimGeography
SELECT * FROM DBO.DimSalesTerritory -- Territorial Data