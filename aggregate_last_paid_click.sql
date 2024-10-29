WITH sel AS (
    SELECT DISTINCT
        s.visitor_id,
        s.visit_date,
        s.source AS utm_source,
        s.medium AS utm_medium,
        s.campaign AS utm_campaign,
        l.lead_id,
        l.created_at,
        l.amount,
        l.closing_reason,
        l.status_id,
        ROW_NUMBER()
            OVER (PARTITION BY s.visitor_id ORDER BY s.visit_date DESC)
        AS rnk
    FROM sessions AS s
    LEFT JOIN
        leads AS l
        ON s.visitor_id = l.visitor_id AND s.visit_date <= l.created_at
    WHERE s.medium != 'organic'
),

tab AS (
    SELECT
        sel.utm_source,
        sel.utm_medium,
        sel.utm_campaign,
        COUNT(sel.visitor_id) AS visitors_count,
        DATE(sel.visit_date) AS visit_date,
        COUNT(sel.lead_id) AS leads_count,
        COUNT(sel.lead_id) FILTER (
            WHERE sel.status_id = '142'
        ) AS purchases_count,
        SUM(sel.amount) FILTER (WHERE sel.status_id = '142') AS revenue
    FROM sel
    WHERE sel.rnk = 1
    GROUP BY
        DATE(sel.visit_date),
        sel.utm_source,
        sel.utm_medium,
        sel.utm_campaign,
        sel.created_at
),

ads_aggregated AS (
    SELECT
        ya_ads.utm_source,
        ya_ads.utm_medium,
        ya_ads.utm_campaign,
        DATE(ya_ads.campaign_date) AS campaign_date,
        SUM(ya_ads.daily_spent) AS total_cost
    FROM ya_ads
    GROUP BY
        ya_ads.utm_source,
        ya_ads.utm_medium,
        ya_ads.utm_campaign,
        DATE(ya_ads.campaign_date)
    UNION ALL
    SELECT
        vk_ads.utm_source,
        vk_ads.utm_medium,
        vk_ads.utm_campaign,
        DATE(vk_ads.campaign_date) AS campaign_date,
        SUM(vk_ads.daily_spent) AS total_cost
    FROM vk_ads
    GROUP BY
        vk_ads.utm_source,
        vk_ads.utm_medium,
        vk_ads.utm_campaign,
        DATE(vk_ads.campaign_date)
)

SELECT
    tab.visit_date,
    tab.utm_source,
    tab.utm_medium,
    tab.utm_campaign,
    tab.visitors_count,
    aa.total_cost,
    tab.leads_count,
    tab.purchases_count,
    tab.revenue
FROM tab
LEFT JOIN ads_aggregated AS aa
    ON
        tab.utm_source = aa.utm_source
        AND tab.utm_medium = aa.utm_medium
        AND tab.utm_campaign = aa.utm_campaign
        AND tab.visit_date::date = aa.campaign_date::date
ORDER BY
    tab.revenue DESC NULLS LAST,
    tab.visit_date ASC,
    tab.visitors_count DESC,
    tab.utm_source ASC,
    tab.utm_medium ASC,
    tab.utm_campaign ASC
LIMIT 15;

