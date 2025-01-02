1.1 You’ve been tasked to create a detailed overview of all individual customers (these are defined by customerType = ‘I’ and/or stored in an individual table). Write a query that provides:
•	Identity information : CustomerId, Firstname, Last Name, FullName (First Name & Last Name).
•	An Extra column called addressing_title i.e. (Mr. Achong), if the title is missing - Dear Achong.
•	Contact information : Email, phone, account number, CustomerType.
•	Location information : City, State & Country, address.
•	Sales: number of orders, total amount (with Tax), date of the last order.
Copy only the top 200 rows from your written select ordered by total amount (with tax).
•	Hint: Few customers have multiple addresses, to avoid duplicate data take their latest available address by choosing max(AddressId)
•	Result Hint:
 


WITH
  sales AS(
  SELECT
    CustomerID,
    ROUND(SUM(TotalDue), 2) AS total_amount,
    COUNT(SalesOrderID) AS orders_count,
    DATE(MAX(OrderDate)) AS last_order_date
  FROM
    `adwentureworks_db.salesorderheader`
  GROUP BY
    CustomerID ),

  address_id AS(
  SELECT
    CustomerID,
    MAX(AddressID) AS AddressID
  FROM
    `adwentureworks_db.customeraddress`
  GROUP BY
    CustomerID )

SELECT
  individual.CustomerID AS customer_id,
  contact.Firstname AS first_name,
  contact.LastName AS last_name,
  contact.Firstname || "" "" || contact.LastName AS full_name,
  IFNULL(contact.Title, 'Dear') || ' ' || contact.LastName AS addressing_title,
  contact.EmailAddress AS email,
  contact.phone,
  customer.AccountNumber AS account_number,
  customer.CustomerType AS customer_type,
  address.city,
  state.name AS state,
  country.name AS country,
  CONCAT(COALESCE(address.AddressLine1, ''), COALESCE((' ' || address.AddressLine2), '')) AS address_line,
  sales.orders_count,
  sales.total_amount,
  sales.last_order_date
FROM
  `adwentureworks_db.individual` individual
LEFT JOIN
  `adwentureworks_db.contact` contact
ON
  individual.ContactID = contact.ContactID
LEFT JOIN
  `adwentureworks_db.customer` customer
ON
  individual.CustomerID = customer.CustomerID
LEFT JOIN
  address_id
ON
  individual.CustomerID = address_id.CustomerID
LEFT JOIN
  `adwentureworks_db.address` address
ON
  address_id.AddressID = address.AddressID
LEFT JOIN
  `adwentureworks_db.stateprovince` state
ON
  address.StateProvinceID = state.StateProvinceID
LEFT JOIN
  `adwentureworks_db.countryregion` country
ON
  state.CountryRegionCode = country.CountryRegionCode
LEFT JOIN
  sales
ON
  individual.CustomerID = sales.CustomerID
ORDER BY
  sales.total_amount DESC
LIMIT
  200 

1.2 Business finds the original query valuable to analyze customers and now want to get the data from the first query for the top 200 customers with the highest total amount (with tax) who have not ordered for the last 365 days. How would you identify this segment?
Hints:
•	You can use temp table, cte and/or subquery of the 1.1 select.
•	Note that the database is old and the current date should be defined by finding the latest order date in the orders table.
WITH
  sales AS(
  SELECT
    CustomerID,
    ROUND(SUM(TotalDue), 2) AS total_amount,
    COUNT(SalesOrderID) AS orders_count,
    DATE(MAX(OrderDate)) AS last_order_date,
    DATE_DIFF( (
      SELECT
        MAX(DATE(OrderDate))
      FROM
        `adwentureworks_db.salesorderheader` ), DATE(MAX(OrderDate)), DAY) AS diff_from_current_date
  FROM
    `adwentureworks_db.salesorderheader`
  GROUP BY
    CustomerID ),

  address_id AS(
  SELECT
    CustomerID,
    MAX(AddressID) AS AddressID
  FROM
    `adwentureworks_db.customeraddress`
  GROUP BY
    CustomerID )

SELECT
  individual.CustomerID AS customer_id,
  contact.Firstname AS first_name,
  contact.LastName AS last_name,
  contact.Firstname || "" "" || contact.LastName AS full_name,
  IFNULL(contact.Title, 'Dear') || ' ' || contact.LastName AS addressing_title,
  contact.EmailAddress AS email,
  contact.phone,
  customer.AccountNumber AS account_number,
  customer.CustomerType AS customer_type,
  address.city,
  state.name AS state,
  country.name AS country,
  CONCAT(COALESCE(address.AddressLine1, ''), COALESCE((' ' || address.AddressLine2), '')) AS address_line,
  sales.orders_count,
  sales.total_amount,
  sales.last_order_date
FROM
  `adwentureworks_db.individual` individual
LEFT JOIN
  `adwentureworks_db.contact` contact
ON
  individual.ContactID = contact.ContactID
LEFT JOIN
  `adwentureworks_db.customer` customer
ON
  individual.CustomerID = customer.CustomerID
LEFT JOIN
  address_id
ON
  individual.CustomerID = address_id.CustomerID
LEFT JOIN
  `adwentureworks_db.address` address
ON
  address_id.AddressID = address.AddressID
LEFT JOIN
  `adwentureworks_db.stateprovince` state
ON
  address.StateProvinceID = state.StateProvinceID
LEFT JOIN
  `adwentureworks_db.countryregion` country
ON
  state.CountryRegionCode = country.CountryRegionCode
LEFT JOIN
  sales
ON
  individual.CustomerID = sales.CustomerID
WHERE
  diff_from_current_date >= 365 -- more
  OR equal TO because the CURRENT date IS included TO the count AS well
ORDER BY
  sales.total_amount DESC
LIMIT
  200



1.3 Enrich your original 1.1 SELECT by creating a new column in the view that marks active & inactive customers based on whether they have ordered anything during the last 365 days.
•	Copy only the top 500 rows from your written select ordered by CustomerId desc.

WITH
  sales AS(
  SELECT
    CustomerID,
    ROUND(SUM(TotalDue), 2) AS total_amount,
    COUNT(SalesOrderID) AS orders_count,
    DATE(MAX(OrderDate)) AS last_order_date,
    DATE_DIFF( (
      SELECT
        MAX(DATE(OrderDate))
      FROM
        `adwentureworks_db.salesorderheader` ), DATE(MAX(OrderDate)), DAY) AS diff_from_current_date
  FROM
    `adwentureworks_db.salesorderheader`
  GROUP BY
    CustomerID ),

  address_id AS(
  SELECT
    CustomerID,
    MAX(AddressID) AS AddressID
  FROM
    `adwentureworks_db.customeraddress`
  GROUP BY
    CustomerID )

SELECT
  individual.CustomerID AS customer_id,
  contact.Firstname AS first_name,
  contact.LastName AS last_name,
  contact.Firstname || "" "" || contact.LastName AS full_name,
  IFNULL(contact.Title, 'Dear') || ' ' || contact.LastName AS addressing_title,
  contact.EmailAddress AS email,
  contact.phone,
  customer.AccountNumber AS account_number,
  customer.CustomerType AS customer_type,
  address.city,
  state.name AS state,
  country.name AS country,
  CONCAT(COALESCE(address.AddressLine1, ''), COALESCE((' ' || address.AddressLine2), '')) AS address_line,
  sales.orders_count,
  sales.total_amount,
  sales.last_order_date,
  CASE
    WHEN sales.diff_from_current_date >= 365 THEN 'Inactive'
    ELSE 'Active'
END
  AS customer_status
FROM
  `adwentureworks_db.individual` individual
LEFT JOIN
  `adwentureworks_db.contact` contact
ON
  individual.ContactID = contact.ContactID
LEFT JOIN
  `adwentureworks_db.customer` customer
ON
  individual.CustomerID = customer.CustomerID
LEFT JOIN
  address_id
ON
  individual.CustomerID = address_id.CustomerID
LEFT JOIN
  `adwentureworks_db.address` address
ON
  address_id.AddressID = address.AddressID
LEFT JOIN
  `adwentureworks_db.stateprovince` state
ON
  address.StateProvinceID = state.StateProvinceID
LEFT JOIN
  `adwentureworks_db.countryregion` country
ON
  state.CountryRegionCode = country.CountryRegionCode
LEFT JOIN
  sales
ON
  individual.CustomerID = sales.CustomerID
ORDER BY
  customer_id DESC
LIMIT
  500 



1.4 Business would like to extract data on all active customers from North America. Only customers that have either ordered no less than 2500 in total amount (with Tax) or ordered 5 + times should be presented.
In the output for these customers divide their address line into two columns, i.e.:
AddressLine1	address_no	Address_st
'8603 Elmhurst Lane'	8603	Elmhurst Lane
Order the output by country, state and date_last_order.

WITH
  sales AS(
    SELECT
      CustomerID,
      ROUND(SUM(TotalDue), 2) AS total_amount,
      COUNT(SalesOrderID) AS orders_count,
      DATE(MAX(OrderDate)) AS last_order_date,
      DATE_DIFF(
        (
        SELECT
          MAX(DATE(OrderDate))
        FROM
          `adwentureworks_db.salesorderheader`
        ),
        DATE(MAX(OrderDate)), DAY) AS diff_from_current_date
    FROM
      `adwentureworks_db.salesorderheader`
    GROUP BY
      CustomerID
  ),

  address_id AS(
  SELECT
    CustomerID,
    MAX(AddressID) AS AddressID
  FROM
    `adwentureworks_db.customeraddress`
  GROUP BY
    CustomerID
  ),

  main_table AS(
  SELECT
    individual.CustomerID AS customer_id,
    contact.Firstname AS first_name,
    contact.LastName AS last_name,
    contact.Firstname || "" "" || contact.LastName AS full_name,
    IFNULL(contact.Title, 'Dear') || ' ' || contact.LastName AS addressing_title,
    contact.EmailAddress AS email,
    contact.phone,
    customer.AccountNumber AS account_number,
    customer.CustomerType AS customer_type,
    address.city,
    state.name AS state,
    country.name AS country,
    address.AddressLine1 AS address_line1,
    address.AddressLine2 AS address_line2,
    sales.orders_count,
    sales.total_amount,
    sales.last_order_date,
    CASE
      WHEN sales.diff_from_current_date >= 365 THEN 'Inactive'
      ELSE 'Active'
    END AS customer_status
  FROM
    `adwentureworks_db.individual` individual
  LEFT JOIN
    `adwentureworks_db.contact` contact
  ON
    individual.ContactID = contact.ContactID
  LEFT JOIN
    `adwentureworks_db.customer` customer
  ON
    individual.CustomerID = customer.CustomerID
  LEFT JOIN
    address_id
  ON
    individual.CustomerID = address_id.CustomerID
  LEFT JOIN
    `adwentureworks_db.address` address
  ON
    address_id.AddressID = address.AddressID
  LEFT JOIN
    `adwentureworks_db.stateprovince` state
  ON
    address.StateProvinceID = state.StateProvinceID
  LEFT JOIN
    `adwentureworks_db.countryregion` country
  ON
    state.CountryRegionCode = country.CountryRegionCode
  LEFT JOIN
    sales
  ON
    individual.CustomerID = sales.CustomerID
  )

SELECT
  *,
  CASE
    WHEN address_line1 LIKE '%Box %' THEN 'Not provided' -- if instead of address, a post office box information is provided, it is not applicable to split it to address number and street
    ELSE CAST(REPLACE(LEFT(address_line1, STRPOS(address_line1, ' ') - 1), ',', '') AS STRING) -- removing any commas from the address_no with REPLACE
  END AS address_no,
  CASE
    WHEN address_line1 LIKE '%Box %' THEN 'Not provided'
    ELSE SUBSTR(address_line1, STRPOS(address_line1, ' ') + 1)
  END AS address_str
FROM main_table
WHERE
  customer_status ='Active' AND
  country IN ('United States', 'Canada') AND -- checked that there are 6 countries in the main table (SELECT country FROM main_table GROUP BY 1), and two of them are in North America
  (total_amount >= 2500 OR
  orders_count >= 5)
ORDER BY
  country,
  state,
  last_order_date  


2. Reporting Sales’ numbers
•	Main tables to start from: salesorderheader.
2.1 Create a query of monthly sales numbers in each Country & region. Include in the query a number of orders, customers and sales persons in each month with a total amount with tax earned. Sales numbers from all types of customers are required.
•	Result Hint:
 

SELECT
  LAST_DAY(DATE(soh.OrderDate), MONTH) AS order_month,
  s.CountryRegionCode,
  s.Name AS Region,
  COUNT(DISTINCT soh.SalesOrderID) AS number_orders,
  COUNT(DISTINCT soh.CustomerID) AS number_customers,
  COUNT(DISTINCT soh.SalesPersonID) AS no_salespersons,
  ROUND(SUM(soh.TotalDue), 0) AS total_w_tax
FROM
  `tc-da-1.adwentureworks_db.salesorderheader`soh
LEFT JOIN
  `tc-da-1.adwentureworks_db.salesterritory`s
USING
  (TerritoryID)
GROUP BY
  ALL; 


2.2 Enrich 2.1 query with the cumulative_sum of the total amount with tax earned per country & region.
•	Hint: use CTE or subquery.
•	Result Hint:
 

WITH
  MonthlySales AS (
  SELECT
    LAST_DAY(DATE(soh.OrderDate), MONTH) AS order_month,
    s.CountryRegionCode,
    s.Name AS Region,
    COUNT(DISTINCT soh.SalesOrderID) AS number_orders,
    COUNT(DISTINCT soh.CustomerID) AS number_customers,
    COUNT(DISTINCT soh.SalesPersonID) AS no_salespersons,
    ROUND(SUM(soh.TotalDue), 0) AS total_w_tax
  FROM
    `tc-da-1.adwentureworks_db.salesorderheader`soh
  LEFT JOIN
    `tc-da-1.adwentureworks_db.salesterritory`s
  USING
    (TerritoryID)
  GROUP BY
    ALL )
SELECT
  *,
  SUM(total_w_tax) OVER (PARTITION BY CountryRegionCode, Region ORDER BY order_month) AS cumulative_sum
FROM
  MonthlySales;


2.3 Enrich 2.2 query by adding ‘sales_rank’ column that ranks rows from best to worst for each country based on total amount with tax earned each month. I.e. the month where the (US, Southwest) region made the highest total amount with tax earned will be ranked 1 for that region and vice versa.
•	Result Hint (with region filtered on France):
 

WITH
  MonthlySales AS (
  SELECT
    LAST_DAY(DATE(soh.OrderDate), MONTH) AS order_month,
    s.CountryRegionCode,
    s.Name AS Region,
    COUNT(DISTINCT soh.SalesOrderID) AS number_orders,
    COUNT(DISTINCT soh.CustomerID) AS number_customers,
    COUNT(DISTINCT soh.SalesPersonID) AS no_salespersons,
    ROUND(SUM(soh.TotalDue), 0) AS total_w_tax
  FROM
    `tc-da-1.adwentureworks_db.salesorderheader` soh
  LEFT JOIN
    `tc-da-1.adwentureworks_db.salesterritory` s
  USING
    (TerritoryID)
  GROUP BY
    ALL )

SELECT
  *,
  SUM(total_w_tax) OVER (PARTITION BY CountryRegionCode, Region ORDER BY order_month) AS CumulativeTotal,
  RANK() OVER (PARTITION BY CountryRegionCode, Region ORDER BY total_w_tax DESC) AS country_sales_rank
FROM
  MonthlySales; 

2.4 Enrich 2.3 query by adding taxes on a country level:
•	As taxes can vary in country based on province, the needed column is ‘mean_tax_rate’ -> average tax rate in a country.
•	Also, as not all regions have data on taxes, you also want to be transparent and show the ‘perc_provinces_w_tax’ -> a column representing the percentage of provinces with available tax rates for each country (i.e. If US has 53 provinces, and 10 of them have tax rates, then for US it should show 0,19)
•	Hint: If a state has multiple tax rates, choose the higher one. Do not double count a state in country average rate calculation if it has multiple tax rates.
•	Hint: Ignore the isonlystateprovinceFlag rate mechanic, it is beyond the scope of this exercise. Treat all tax rates as equal.
•	Result Hint (with region filtered on US):
 

WITH
  sales_data AS(
  SELECT
    LAST_DAY(DATE(sales.OrderDate), MONTH) AS order_month,
    territory.CountryRegionCode AS country_code,
    territory.Name AS region,
    COUNT(sales.SalesOrderID) AS order_count,
    COUNT(DISTINCT sales.CustomerID) AS customer_count,
    COUNT(DISTINCT sales.SalesPersonID) AS salesperson_count,
    ROUND(SUM(sales.TotalDue), 0) AS total_sales_with_tax
  FROM
    `adwentureworks_db.salesorderheader` sales
  LEFT JOIN
    `adwentureworks_db.salesterritory` territory
  USING
    (TerritoryID)
  GROUP BY
    ALL ),

  state_tax_data AS(
  SELECT
    state_province.CountryRegionCode AS country_code,
    state_province.StateProvinceID AS state_id,
    MAX(tax.TaxRate) AS tax_rate
  FROM
    `adwentureworks_db.stateprovince` state_province
  LEFT JOIN
    `adwentureworks_db.salestaxrate` tax
  USING
    (StateProvinceID)
  GROUP BY
    ALL ),

  tax_stats AS(
  SELECT
    country_code,
    ROUND(AVG(tax_rate), 2) AS mean_tax_rate,
    ROUND(COUNT(tax_rate)/COUNT(state_id), 2) AS perc_provinces_w_tax
  FROM
    state_tax_data
  GROUP BY
    ALL )

SELECT
  sales_data.*,
  SUM(total_sales_with_tax) OVER (PARTITION BY country_code, region ORDER BY order_month) AS cumulative_sales_with_tax,
  RANK() OVER (PARTITION BY country_code, region ORDER BY total_sales_with_tax DESC) AS sales_rank,
  tax_stats.mean_tax_rate,
  tax_stats.perc_provinces_w_tax
FROM
  sales_data
LEFT JOIN
  tax_stats
USING
  (country_code)
ORDER BY
  mean_tax_rate DESC

