-- load day 1 before

INSERT INTO countries (country_code, country_name)
VALUES ('fr', 'France');

INSERT INTO cities
VALUES ('Paris', '75000', 'fr');

INSERT INTO venues (name, postal_code, country_code)
VALUES ('My Place', '75000', 'fr');

INSERT INTO events (title, starts, ends, venue_id)
VALUES ('Moby', '2012-02-06 21:00:00', '2012-02-06 23:00:00',
          (SELECT venue_id FROM venues where name = 'Crystal Ballroom'));

INSERT INTO events (title, starts, ends, venue_id)
VALUES ('Wedding', '2012-02-26 21:00:00', '2012-02-26 23:00:00',
         (SELECT venue_id FROM venues where name = 'Voodoo Donuts'));

INSERT INTO events (title, starts, ends, venue_id)
VALUES ('Dinner with Mom', '2012-02-26 18:00:00', '2012-02-26 20:30:00',
          (SELECT venue_id FROM venues where name = 'My Place'));

INSERT INTO events (title, starts, ends)
VALUES ('Valetine''s Day', '2012-02-14 00:00:00', '2012-02-14 23:59:59');

-- create the add_event stored procedure before
-- use it like this
-- SELECT add_event('House Party', '2012-05-03 23:00', '2012-05-04 02:00', 'Run''s House', '97205', 'us');

CREATE TABLE logs (
  event_id integer,
  old_title varchar(255),
  old_starts timestamp,
  old_ends timestamp,
  logged_at timestamp DEFAULT current_timestamp
  );

-- create log_event() procedure before
-- CREATE TRIGGER log_events AFTER UPDATE ON events FOR EACH ROW EXECUTE PROCEDURE log_event();
-- UPDATE events SET ends = '2012-05-04 01:00:00' WHERE title = 'House Party';

ALTER TABLE events ADD colors text ARRAY;

-- create rule update_holidays before
-- UPDATE holidays SET colors ='{"red", "green"}' where name = 'Christmas Day';

-- use for the pivot table but homework will show a better way
CREATE TEMPORARY TABLE month_count(month INT);
INSERT INTO month_count VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12);


