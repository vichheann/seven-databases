DROP TRIGGER IF EXISTS log_events ON events;
DROP FUNCTION IF EXISTS add_event;
DROP FUNCTION IF EXISTS log_events;
DROP RULE IF EXISTS update_holidays ON holidays;
DROP RULE IF EXISTS insert_holidays ON holidays;
DROP RULE IF EXISTS delete_holidays ON holidays;
DROP TABLE IF EXISTS logs;
DROP VIEW IF EXISTS holidays;

DROP TABLE IF EXISTS month_count;

DROP RULE IF EXISTS delete_venues ON venues;
