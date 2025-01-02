"WITH cohort_data AS (
    SELECT 
        DATE_TRUNC(subscription_start, WEEK) AS cohort_week, -- Cohort week based on subscription start
        user_pseudo_id,
        subscription_start,
        subscription_end
    FROM 
        tc-da-1.turing_data_analytics.subscriptions
),
week_retention AS (
    SELECT 
        cohort_week,
        COUNT(user_pseudo_id) AS week_0, -- Number of subscriptions at start of the cohort
        COUNT(CASE WHEN DATE(subscription_start) <= DATE_ADD(cohort_week, INTERVAL 1 WEEK)
                            AND (subscription_end IS NULL OR subscription_end > DATE_ADD(cohort_week, INTERVAL 1 WEEK)) THEN user_pseudo_id END) AS week_1,
        COUNT(CASE WHEN DATE(subscription_start) <= DATE_ADD(cohort_week, INTERVAL 2 WEEK)
 AND (subscription_end IS NULL OR subscription_end > DATE_ADD(cohort_week, INTERVAL 2 WEEK)) THEN user_pseudo_id END) AS week_2,
        COUNT(CASE WHEN DATE(subscription_start) <= DATE_ADD(cohort_week, INTERVAL 3 WEEK)
                            AND (subscription_end IS NULL OR subscription_end > DATE_ADD(cohort_week, INTERVAL 3 WEEK)) THEN user_pseudo_id END) AS week_3,
        COUNT(CASE WHEN DATE(subscription_start) <= DATE_ADD(cohort_week, INTERVAL 4 WEEK)
                            AND (subscription_end IS NULL OR subscription_end > DATE_ADD(cohort_week, INTERVAL 4 WEEK)) THEN user_pseudo_id END) AS week_4,
        COUNT(CASE WHEN DATE(subscription_start) <= DATE_ADD(cohort_week, INTERVAL 5 WEEK)
                            AND (subscription_end IS NULL OR subscription_end > DATE_ADD(cohort_week, INTERVAL 5 WEEK)) THEN user_pseudo_id END) AS week_5,
        COUNT(CASE WHEN DATE(subscription_start) <= DATE_ADD(cohort_week, INTERVAL 6 WEEK)
AND (subscription_end IS NULL OR subscription_end > DATE_ADD(cohort_week, INTERVAL 6 WEEK)) THEN user_pseudo_id END) AS week_6
    FROM 
        cohort_data
    GROUP BY 
        cohort_week
)
SELECT 
    cohort_week, 
    week_0, 
    week_1, 
    (week_1 / week_0) * 100 AS retention_week_1,
    week_2, 
    (week_2 / week_0) * 100 AS retention_week_2,
    week_3, 
    (week_3 / week_0) * 100 AS retention_week_3,
    week_4, 
    (week_4 / week_0) * 100 AS retention_week_4,
    week_5, 
    (week_5 / week_0) * 100 AS retention_week_5,
    week_6, 
    (week_6 / week_0) * 100 AS retention_week_6
FROM 
    week_retention
ORDER BY 
    cohort_week;