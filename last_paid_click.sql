WITH sel AS (
    SELECT DISTINCT
        s.visitor_id,
        s.visit_date,
        s.source AS utm_source,
        s.medium AS utm_medium,
        s.campaign AS utm_campaign,
        s.content AS utm_content,
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
)

SELECT
    sel.visitor_id,
    sel.visit_date,
    sel.utm_source,
    sel.utm_medium,
    sel.utm_campaign,
    sel.utm_content,
    sel.lead_id,
    sel.created_at,
    sel.amount,
    sel.closing_reason,
    sel.status_id
FROM sel
WHERE sel.rnk = 1
ORDER BY
    sel.amount DESC NULLS LAST,
    sel.visit_date ASC,
    sel.utm_source ASC,
    sel.utm_medium ASC,
    sel.utm_campaign ASC
LIMIT 10;

