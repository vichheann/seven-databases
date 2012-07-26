CREATE OR REPLACE RULE insert_holidays AS ON INSERT TO holidays DO INSTEAD
  INSERT INTO events (title, starts)
  VALUES (New.name, New.date);

INSERT INTO holidays (name, date)
  VALUES ('New Years Day', '2013-01-01 00:00:00');

CREATE OR REPLACE RULE delete_holidays AS ON DELETE TO holidays DO INSTEAD
  DELETE FROM events
  WHERE event_id =  Old.holiday_id;

