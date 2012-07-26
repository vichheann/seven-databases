CREATE TABLE countries (
  country_code char(2) PRIMARY KEY,
  country_name text UNIQUE
  );

INSERT INTO countries (country_code, country_name)
VALUES ('us', 'United States'),
       ('mx', 'Mexico'),
       ('au', 'Australia'),
       ('gb', 'United Kingdom'),
       ('de', 'Germany'),
       ('ll', 'Loompaland');

CREATE TABLE cities (
  name text NOT NULL,
  postal_code varchar(9) CHECK (postal_code <> ''),
  country_code char(2) REFERENCES countries,
  PRIMARY KEY (country_code, postal_code)
  );

INSERT INTO cities
VALUES ('Portland', '87200', 'us');

UPDATE cities
SET postal_code = '97205'
WHERE name = 'Portland';

CREATE TABLE venues (
  venue_id SERIAL PRIMARY KEY,
  name varchar(255),
  street_address text,
  type char(7) CHECK ( type in ('public', 'private') ) DEFAULT 'public',
  postal_code varchar(9),
  country_code char(2),
  FOREIGN KEY (country_code, postal_code)
  REFERENCES cities (country_code, postal_code) MATCH FULL
  -- http://www.postgresql.org/docs/9.1/static/sql-createtable.html
  );

INSERT INTO venues (name, postal_code, country_code)
VALUES ('Crystal Ballroom', '97205', 'us');

INSERT INTO venues (name, postal_code, country_code)
VALUES ('Voodoo Donuts', '97205', 'us') RETURNING venue_id;

CREATE TABLE events (
  event_id SERIAL PRIMARY KEY,
  title text NOT NULL,
  starts timestamp,
  ends timestamp,
  venue_id integer,
  FOREIGN KEY (venue_id) REFERENCES venues
  );

INSERT INTO events (title, starts, ends, venue_id)
VALUES ('LARP Club', '2012-02-15 17:30:00', '2012-02-15 19:30:00', 2);

INSERT INTO events (title, starts, ends)
VALUES ('April Fools Day', '2012-04-01 00:00:00', '2012-04-01 23:59:00'),
       ('Christmas Day', '2012-02-25 00:00:00', '2012-02-25 23:59:00');

CREATE INDEX events_title ON events USING hash (title);
CREATE INDEX events_starts ON events USING btree (starts);
