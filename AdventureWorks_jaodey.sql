SELECT *
FROM `tc-da-1.adwentureworks_db.product`

SELECT *
FROM `tc-da-1.adwentureworks_db.productsubcategory`

SELECT *
FROM `tc-da-1.adwentureworks_db.productcategory`

SELECT ProductID, Name, ProductNumber,Size, Color, ProductSubcategoryID
FROM `tc-da-1.adwentureworks_db.product`

-- Subcategory name
SELECT Name AS SubCategory
FROM `tc-da-1.adwentureworks_db.productsubcategory`

-- Category name
SELECT Name AS Category
FROM `tc-da-1.adwentureworks_db.productcategory`


-- 1.1 You’ve been asked to extract the data on products from the Product table where there exists a product subcategory. And also include the name of the ProductSubcategory.

SELECT p.ProductID, p.Name, p.ProductNumber,p.Size, p.Color, ps.ProductSubcategoryID, ps.Name
FROM `tc-da-1.adwentureworks_db.product` p
INNER JOIN `tc-da-1.adwentureworks_db.productsubcategory`ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
ORDER BY ps.Name;


-- 1.2 In 1.1 query you have a product subcategory but see that you could use the category name.
-- Find and add the product category name.
-- Afterwards order the results by Category name.

SELECT p.ProductID, p.Name, p.ProductNumber,p.Size, p.Color, ps.ProductSubcategoryID, ps.Name AS SubCategory, c.Name AS Category
FROM `tc-da-1.adwentureworks_db.product` p
INNER JOIN `tc-da-1.adwentureworks_db.productsubcategory`ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
INNER JOIN `tc-da-1.adwentureworks_db.productcategory`c ON p.ProductSubcategoryID = c.ProductcategoryID
ORDER BY c.Name;

-- 1.3 Use the established query to select the most expensive (price listed over 2000) bikes that are still actively sold (does not have a sales end date)

SELECT *
FROM `tc-da-1.adwentureworks_db.product`

SELECT Name
FROM `tc-da-1.adwentureworks_db.product`
WHERE Name = "Bikes"

SELECT ListPrice
FROM `tc-da-1.adwentureworks_db.product`
WHERE ListPrice > 2000

SELECT ListPrice
FROM `tc-da-1.adwentureworks_db.product`
WHERE Name = "Bikes" AND ListPrice > 2000

SELECT p.ProductID, p.Name, p.ProductNumber,p.Size, p.Color, p.ListPrice, ps.ProductSubcategoryID, ps.Name AS SubCategory, c.Name AS Category
FROM `tc-da-1.adwentureworks_db.product` p
INNER JOIN `tc-da-1.adwentureworks_db.productsubcategory`ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
INNER JOIN `tc-da-1.adwentureworks_db.productcategory`c ON p.ProductSubcategoryID = c.ProductcategoryID
WHERE c.Name = 'Bikes' AND p.ListPrice > 2000 AND p.SellEndDate IS NULL
ORDER BY c.Name;

-- Order the results from most to least expensive bike.

SELECT p.ProductID, p.Name, p.ProductNumber,p.Size, p.Color, p.ListPrice, ps.ProductSubcategoryID, ps.Name AS SubCategory, c.Name AS Category
FROM `tc-da-1.adwentureworks_db.product` p
INNER JOIN `tc-da-1.adwentureworks_db.productsubcategory`ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
INNER JOIN `tc-da-1.adwentureworks_db.productcategory`c ON p.ProductSubcategoryID = c.ProductcategoryID
WHERE c.Name = 'Bikes' AND p.ListPrice > 2000 AND p.SellEndDate IS NULL
ORDER BY p.ListPrice DESC;


--2.1 Create an aggregated query to select the:
-- Number of unique work orders.
-- Number of unique products.
-- Total actual cost.
-- For each location Id from the 'workoderrouting' table for orders in January 2004.

SELECT *
FROM `tc-da-1.adwentureworks_db.workorder`

SELECT ActualCost
FROM `tc-da-1.adwentureworks_db.workorderrouting`


SELECT LocationID,
  COUNT(DISTINCT WorkOrderID) AS NumberOfWorkOrders,
  COUNT(DISTINCT ProductID) AS NumberOfUniqueProducts,
  SUM(ActualCost) AS TotalActualCost
FROM `tc-da-1.adwentureworks_db.workorderrouting` wor
WHERE EXTRACT (YEAR FROM ActualStartDate) = 2004 AND EXTRACT(MONTH FROM ActualStartDate) = 1
GROUP BY LocationID;

--2.2 Update your 2.1 query by adding the name of the location and also add the average days amount between actual start date and actual end date per each location.

SELECT LocationID,
  COUNT(DISTINCT WorkOrderID) AS NumberOfWorkOrders,
  COUNT(DISTINCT ProductID) AS NumberOfUniqueProducts,
  SUM(ActualCost) AS TotalActualCost,
  ROUND(AVG(date_diff(ActualEndDate, ActualStartDate, DAY))) AS AverageDaysToComplete
FROM `tc-da-1.adwentureworks_db.workorderrouting` wor
WHERE EXTRACT(YEAR FROM ActualStartDate) = 2004 AND EXTRACT(MONTH FROM ActualStartDate) = 1
GROUP BY LocationID;



-- 2.3 Select all the expensive work Orders (above 300 actual cost) that happened throught January 2004.

SELECT WorkOrderID, ActualCost
FROM `tc-da-1.adwentureworks_db.workorderrouting`

SELECT WorkOrderID, SUM(ActualCost) AS Actual_Cost,
FROM `tc-da-1.adwentureworks_db.workorderrouting`
WHERE ActualStartDate BETWEEN '2004-01-01' AND '2004-01-31'
GROUP BY WorkOrderID 
HAVING SUM(ActualCost) > 300;

-- 3. Query validation
-- Below you will find 2 queries that need to be fixed/updated.

-- Doubleclick on the cell of the query and you will see it in the original format, copy it into your Bigquery interface and try to fix it there.
-- Once you have it fixed, copy into your spreadsheet of results among previous task results.
-- 3.1 Your colleague has written a query to find the list of orders connected to special offers. The query works fine but the numbers are off, investigate where the potential issue lies.

SELECT sales_detail.SalesOrderId
      ,sales_detail.OrderQty
      ,sales_detail.UnitPrice
      ,sales_detail.LineTotal
      ,sales_detail.ProductId
      ,sales_detail.SpecialOfferID
      ,spec_offer_product.ModifiedDate
      ,spec_offer.Category
      ,spec_offer.Description

FROM `tc-da-1.adwentureworks_db.salesorderdetail`  as sales_detail

left join `tc-da-1.adwentureworks_db.specialofferproduct` as spec_offer_product
on sales_detail.productId = spec_offer_product.ProductID

left join `tc-da-1.adwentureworks_db.specialoffer` as spec_offer
on sales_detail.SpecialOfferID = spec_offer.SpecialOfferID

order by LineTotal desc

-- CORRECTION
-- Issue: The original query likely overcounts the impact of special offers on sales because it joins multiple special offers to a single sale detail record. This can happen if a product is connected to multiple special offers.
-- We use aggregation (SUM and COUNT) to get total quantities, sales, and the number of distinct SpecialOfferID per SalesOrderID. This ensures we only count a special offer impact once for each sales order.

SELECT SalesOrderId,
  SUM(OrderQty) AS TotalOrderQty,
  SUM(UnitPrice * OrderQty) AS TotalSales,
  COUNT(DISTINCT sales_detail.SpecialOfferID) AS NumberOfSpecialOffers
FROM `tc-da-1.adwentureworks_db.salesorderdetail`  as sales_detail

left join `tc-da-1.adwentureworks_db.specialofferproduct` as spec_offer_product
on sales_detail.productId = spec_offer_product.ProductID

left join `tc-da-1.adwentureworks_db.specialoffer` as spec_offer
on sales_detail.SpecialOfferID = spec_offer.SpecialOfferID

GROUP BY SalesOrderId
ORDER BY TotalSales DESC;


-- 3.2 Your colleague has written this query to collect basic Vendor information. The query does not work, look into the query and find ways to fix it. Can you provide any feedback on how to make this query be easier to debug/read?


Code:
SELECT a.VendorId as Id,
  vendor_contact.ContactId, 
  b.ContactTypeId, a.Name, 
  a.CreditRating, 
  a.ActiveFlag,
  c.AddressId,d.City
FROM tc-da-1.adwentureworks_db.Vendor as a
left joiN tc-da-1.adwentureworks_db.vendorcontact as vendor_contact on vendor.VendorId = vendor_contact.VendorId 
left join tc-da1.adwentureworks_db.vendoraddress as c on a.VendorId = c.VendorId
left join tc-da-1.adwentureworks_db.address as address on vendor_address.VendorId = d.VendorId


-- CORRECTION
-- Typo in table alias: tc-da1 should be tc-da-1.
-- Incorrect join on address table: There's no foreign key relationship between VendorAddress and Address based on the provided table names.

SELECT *
FROM tc-da-1.adwentureworks_db.vendoraddress

SELECT a.VendorId AS Id,
       vc.ContactId,
       vc.ContactTypeId,
       a.Name,
       a.CreditRating,
       a.ActiveFlag,
       va.AddressId,
FROM tc-da-1.adwentureworks_db.vendor AS a
LEFT JOIN tc-da-1.adwentureworks_db.vendorcontact AS vc ON a.VendorId = vc.VendorId
LEFT JOIN tc-da-1.adwentureworks_db.vendoraddress AS va ON a.VendorId = va.VendorId;



