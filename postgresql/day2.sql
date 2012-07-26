-- 1
CREATE OR REPLACE RULE delete_venues AS ON DELETE TO venues DO INSTEAD
  UPDATE venues SET active = FALSE WHERE venue_id = Old.venue_id;

-- 2
-- crosstab -> http://www.postgresql.org/docs/9.1/static/tablefunc.html
-- extract -> http://www.postgresql.org/docs/9.1/static/functions-datetime.html#FUNCTIONS-DATETIME-EXTRACT
-- generate_series -> http://www.postgresql.org/docs/9.1/static/functions-srf.html
SELECT *
FROM crosstab ('SELECT
               EXTRACT(year from starts) AS year,
               EXTRACT(month from starts) AS month,
               COUNT(*) FROM events GROUP BY year, month',
               'SELECT generate_series(1,12)')
AS (year int, jan int, feb int, mar int, apr int, may int, jun int,
    jul int, aug int, sep int, oct int, nov int, dec int) ORDER BY year;

-- 3
SELECT *
FROM crosstab ('SELECT
               EXTRACT(week from starts) AS week,
               EXTRACT(dow from starts) AS day,
               COUNT(*) FROM events GROUP BY week, day ORDER BY week',
               'SELECT generate_series(0,6)')
AS (week int, "Sun" int, "Mon" int, "Tue" int, "Wed" int, "Thu" int, "Fri" int, "Sat" int)
ORDER BY week;
