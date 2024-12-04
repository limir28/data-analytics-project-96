--Уникальные пользователи
SELECT count(DISTINCT visitor_id) AS visitors_count
FROM sessions;

-- Кол-во лидов
SELECT count(lead_id) AS leads_count
FROM leads;

--Суммарная выручка
SELECT SUM(amount) AS amount
FROM sessions;
