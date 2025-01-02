TASK ONE
"SELECT DISTINCT user_pseudo_id
FROM `tc-da-1.turing_data_analytics.raw_events`
"

"1. Analyze the data in raw_events table. Spend time querying the table, getting more familiar with data. Identify events captured by users visiting the website.
* The data in raw_events table captures a lot of events from users based on their timestamps. This can be useful for a number of analysis. However sometimes more data does not help as it can inflate the results. I.e. if we want to see how many users have gone to the checkout the one user who may have gone back and forth to checkout for 8 times can be dangerous when building a funnel chart as it can overpresent how many users in total get to the checkout. Always be mindful of duplicate data and how it can affect your analysis. 
* First Order of the business is to write a query that eliminates the duplicates for our funnel analysis.
The query should contain all of the columns from raw_events table. It should however only have 1 unique event per user_pseudo_id. For example:"
"WITH UniqueUserEvents AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY user_pseudo_id, event_name ORDER BY event_timestamp ASC) AS rn
    FROM 
        `tc-da-1.turing_data_analytics.raw_events`
)

SELECT 
    CAST(CAST(user_pseudo_id AS FLOAT64) AS INT64) AS user_pseudo_id, -- casting user_pseudo_id to a float and then to an integer
    event_name,
    event_timestamp
    -- Include any additional columns you need here explicitly, for example:
    -- , column1, column2, ...
FROM 
    UniqueUserEvents
WHERE 
    rn = 1
"

"2. Now that you have your unique events table create a sales funnel chart from events in it. Not all events are relevant, productive to be used in this chart. Identify & collect data that you think could be used
* Use between 4 to 6 types of events in this analysis.
* Create a funnel chart with a country split. Business is interested in the differences between top 3 countries in the funnel chart.
* Top countries are decided by their overall number of events.
* Provide insights if any found.
* See if you can come up with any other ideas/slices for funnel analysis that could be worth a look."
"WITH UniqueUserEvents AS (
    SELECT 
        user_pseudo_id,
        event_name,
        event_timestamp,
        country
    FROM (
        SELECT 
            user_pseudo_id,
            event_name,
            event_timestamp,
            country,
            ROW_NUMBER() OVER (PARTITION BY user_pseudo_id, event_name ORDER BY event_timestamp ASC) AS rn
        FROM 
            `tc-da-1.turing_data_analytics.raw_events`
    )
    WHERE rn = 1
),

TopCountries AS (
    SELECT 
        country,
        COUNT(*) AS total_events
    FROM 
        UniqueUserEvents
    GROUP BY 
        country
    ORDER BY 
        total_events DESC
    LIMIT 3
),

FunnelCounts AS (
    SELECT 
        event_name,
        country,
        COUNT(DISTINCT user_pseudo_id) AS event_count
    FROM 
        UniqueUserEvents
    WHERE 
        event_name IN ('session_start', 'view_item', 'add_to_cart', 'begin_checkout', 'purchase')
        AND country IN (SELECT country FROM TopCountries)
    GROUP BY 
        event_name, country
),

FunnelWithOrder AS (
    SELECT 
        CASE 
            WHEN event_name = 'session_start' THEN 1
            WHEN event_name = 'view_item' THEN 2
            WHEN event_name = 'add_to_cart' THEN 3
            WHEN event_name = 'begin_checkout' THEN 4
            WHEN event_name = 'purchase' THEN 5
            ELSE 6
        END AS event_order,
        event_name,
        country,
        event_count
    FROM 
        FunnelCounts
),

FunnelDropoff AS (
    SELECT 
        event_order,
        event_name,
        country,
        event_count,
        LAG(event_count) OVER (PARTITION BY country ORDER BY event_order) AS previous_event_count,
        SAFE_DIVIDE(event_count, LAG(event_count) OVER (PARTITION BY country ORDER BY event_order)) * 100 AS dropoff_percent
    FROM 
        FunnelWithOrder
)

SELECT 
    event_order,
    event_name,
    country,
    event_count,
    COALESCE(dropoff_percent, 100) AS dropoff_percent
FROM 
    FunnelDropoff
ORDER BY 
    event_order, country;
"


"Task format.
1. Create a query  for unique events. Copy this query into the Queries used spreadsheet.
2. Write a new query that aggregates your identified events per top 3 countries. Copy this query into the Queries used spreadsheet.
3. Create a table showing the numbers of events' that you want to use in the funnel analysis. Add event_order and  the percentage drop off values, as in the Example:
event_order
4. Create funnel chart(s) based on data you've collected. Document any key points you find.
5. You can have additional sheets created/used if it is needed for you to accomplish your analysis."

WITH UniqueEvents AS (
    SELECT 
        user_pseudo_id,
        event_name,
        country,
        MIN(event_timestamp) AS event_timestamp
    FROM 
        `tc-da-1.turing_data_analytics.raw_events`
    WHERE 
        event_name IN ('page_view', 'view_item', 'add_to_cart', 'begin_checkout', 'checkout', 'add_payment_info', 'purchase', 'login', 'account_creation')
    GROUP BY 
        user_pseudo_id, event_name, country
),
TopCountries AS (
    SELECT 
        country
    FROM (
        SELECT 
            country,
            COUNT(*) AS total_events
        FROM 
            UniqueEvents
        GROUP BY 
            country
        ORDER BY 
            total_events DESC
        LIMIT 3
    )
),
FunnelCounts AS (
    SELECT 
        event_name,
        country,
        COUNT(DISTINCT user_pseudo_id) AS event_count
    FROM 
        UniqueEvents
    WHERE 
        country IN (SELECT country FROM TopCountries)
    GROUP BY 
        event_name, country
),
FunnelTable AS (
    SELECT 
        CASE 
            WHEN event_name = 'page_view' THEN '1'  -- Event order 1 for 'page_view'
            WHEN event_name = 'view_item' THEN '2'  -- Event order 2 for 'view_item'
            WHEN event_name = 'add_to_cart' THEN '3'  -- Event order 3 for 'add_to_cart'
            WHEN event_name = 'begin_checkout' THEN '4'  -- Event order 4 for 'begin_checkout'
            WHEN event_name = 'add_payment_info' THEN '5'  -- Event order 5 for 'add_payment_info'
            WHEN event_name = 'purchase' THEN '6'  -- Event order 6 for 'purchase'
            ELSE 'error'  -- Handle unexpected event types
        END AS event_order,  -- Assign the event order based on event name
        event_name,
        MAX(CASE WHEN country = (SELECT country FROM TopCountries LIMIT 1 OFFSET 0) THEN event_count ELSE 0 END) AS First_Country_events,
        MAX(CASE WHEN country = (SELECT country FROM TopCountries LIMIT 1 OFFSET 1) THEN event_count ELSE 0 END) AS Second_Country_events,
        MAX(CASE WHEN country = (SELECT country FROM TopCountries LIMIT 1 OFFSET 2) THEN event_count ELSE 0 END) AS Third_Country_events
    FROM 
        FunnelCounts
    GROUP BY 
        event_name
)

SELECT 
    event_order,
    event_name,
    First_Country_events,
    Second_Country_events,
    Third_Country_events,
    100 AS Full_perc,
    ROUND((First_Country_events - Second_Country_events) * 100.0 / NULLIF(First_Country_events, 0), 2) AS First_country_perc_drop,
    ROUND((Second_Country_events - Third_Country_events) * 100.0 / NULLIF(Second_Country_events, 0), 2) AS Second_country_perc_drop
FROM 
    FunnelTable
ORDER BY 
    event_order;
WITH UniqueEvents AS (
    SELECT 
        user_pseudo_id,
        event_name,
        country,
        MIN(event_timestamp) AS event_timestamp
    FROM 
        `tc-da-1.turing_data_analytics.raw_events`
    WHERE 
        event_name IN ('page_view', 'view_item', 'add_to_cart', 'begin_checkout', 'checkout', 'add_payment_info', 'purchase', 'login', 'account_creation')
    GROUP BY 
        user_pseudo_id, event_name, country
),
TopCountries AS (
    SELECT 
        country
    FROM (
        SELECT 
            country,
            COUNT(*) AS total_events
        FROM 
            UniqueEvents
        GROUP BY 
            country
        ORDER BY 
            total_events DESC
        LIMIT 3
    )
),
FunnelCounts AS (
    SELECT 
        event_name,
        country,
        COUNT(DISTINCT user_pseudo_id) AS event_count
    FROM 
        UniqueEvents
    WHERE 
        country IN (SELECT country FROM TopCountries)
    GROUP BY 
        event_name, country
),
FunnelTable AS (
    SELECT 
        CASE 
            WHEN event_name = 'page_view' THEN '1'  -- Event order 1 for 'page_view'
            WHEN event_name = 'view_item' THEN '2'  -- Event order 2 for 'view_item'
            WHEN event_name = 'add_to_cart' THEN '3'  -- Event order 3 for 'add_to_cart'
            WHEN event_name = 'begin_checkout' THEN '4'  -- Event order 4 for 'begin_checkout'
            WHEN event_name = 'add_payment_info' THEN '5'  -- Event order 5 for 'add_payment_info'
            WHEN event_name = 'purchase' THEN '6'  -- Event order 6 for 'purchase'
            ELSE 'error'  -- Handle unexpected event types
        END AS event_order,  -- Assign the event order based on event name
        event_name,
        MAX(CASE WHEN country = (SELECT country FROM TopCountries LIMIT 1 OFFSET 0) THEN event_count ELSE 0 END) AS US,
        MAX(CASE WHEN country = (SELECT country FROM TopCountries LIMIT 1 OFFSET 1) THEN event_count ELSE 0 END) AS Canada,
        MAX(CASE WHEN country = (SELECT country FROM TopCountries LIMIT 1 OFFSET 2) THEN event_count ELSE 0 END) AS India
    FROM 
        FunnelCounts
    GROUP BY 
        event_name
)

SELECT 
    event_order,
    event_name,
    US,
    Canada,
    India,
    100 AS Full_perc,
    ROUND((US - Canada) * 100.0 / NULLIF(US, 0), 2) AS US_perc_drop,
    ROUND((Canada - India) * 100.0 / NULLIF(Canada, 0), 2) AS Canada_perc_drop
FROM 
    FunnelTable
ORDER BY 
    event_order;
