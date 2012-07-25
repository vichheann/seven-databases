-- 1
SELECT relname FROM pg_class
WHERE relkind ='r' AND relname NOT LIKE '%pg_%' AND relname NOT LIKE '%sql_%';

-- 2
SELECT c.country_name, v.name, e.title  FROM countries c, events e, venues v
WHERE e.title = 'LARP Club' AND e.venue_id = v.venue_id AND v.country_code = c.country_code;

SELECT c.country_name, v.name, e.title FROM events e
INNER JOIN venues v on e.venue_id = v.venue_id
INNER JOIN countries c on v.country_code = c.country_code WHERE e.title = 'LARP Club';

-- 3
ALTER TABLE venues ADD COLUMN active boolean DEFAULT TRUE;
