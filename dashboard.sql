--Уникальные пользователи
SELECT count(DISTINCT visitor_id) AS visitors_count
FROM sessions;

-- Кол-во лидов
SELECT count(DISTINCT lead_id) AS leads_count
FROM leads;
