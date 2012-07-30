CREATE INDEX movies_title_pattern ON movies (lower(title) text_pattern_ops);
CREATE INDEX movies_title_trigram ON movies USING gist(title gist_trgm_ops);
CREATE INDEX movies_title_searchable ON movies USING gin(to_tsvector('english', title));

-- 1

CREATE OR REPLACE FUNCTION find_movies_with( actor_name text )
RETURNS SETOF text AS $$
BEGIN

  RETURN QUERY EXECUTE 'SELECT title
  FROM movies m NATURAL JOIN movies_actors NATURAL JOIN actors
  WHERE name ILIKE $1 ORDER BY m.genre DESC'
  USING actor_name;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION find_movies_like( movie_title text, distance integer )
RETURNS SETOF text AS $$
DECLARE
  movie_param text;
  default_distance integer := 5;
  distance_param integer;
BEGIN

  movie_param := movie_title;
  distance_param := distance;
  IF distance < 0 THEN distance_param := 5;
  END IF;

  RETURN QUERY EXECUTE
  'SELECT m.title
   FROM movies m, (SELECT genre, title FROM movies WHERE title = $1) s
   WHERE cube_enlarge(s.genre, $2, 18) @> m.genre AND s.title <> m.title
   ORDER BY cube_distance(m.genre, s.genre)'
  USING movie_param, distance_param;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION find_top5( movie_or_actor text)
RETURNS SETOF text AS $$
DECLARE
  max_count CONSTANT integer := 5;
  mc text;
BEGIN

  SELECT * INTO mc FROM MOVIES WHERE title = movie_or_actor;

  IF NOT FOUND THEN
    RETURN QUERY SELECT find_movies_with(movie_or_actor) LIMIT max_count;
  ELSE
    RETURN QUERY SELECT find_movies_like(movie_or_actor, 5) LIMIT max_count;
  END IF;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION find_actors_starring( movie_title text )
RETURNS table(movie text, actor text) AS $$
DECLARE
  movie_param text;
BEGIN

  movie_param := '%' || movie_title || '%';

  RETURN QUERY EXECUTE 'SELECT title as movie, name as actor
  FROM actors NATURAL JOIN movies_actors NATURAL JOIN movies
  WHERE title ILIKE $1 GROUP BY movie, actor ORDER BY movie'
  USING movie_param;

END;
$$ LANGUAGE plpgsql;


-- 2 Not sastifying, need some rework 

CREATE TABLE comments (
	comment_id SERIAL PRIMARY KEY,
        username text,
	comment text,
	movie_id integer REFERENCES movies NOT NULL
);

CREATE OR REPLACE FUNCTION add_comment( username text, comment text, movie_title text) 
RETURNS integer AS $$
DECLARE
  m_id integer;
  c_id integer;
BEGIN

  SELECT movie_id INTO m_id FROM MOVIES WHERE title = movie_title;

  IF m_id IS NULL THEN
    RAISE EXCEPTION 'Movie not found: %', movie_title; 
  ELSE
    INSERT INTO comments (username, comment, movie_id)
    VALUES (username, comment, m_id)
    RETURNING comment_id INTO c_id;
    RETURN c_id;
  END IF;

END;
$$ LANGUAGE plpgsql;

CREATE INDEX comments_movie_searchable ON comments USING gin(to_tsvector('english', comment));

SELECT add_comment('luke', 'This Mark Hamill is so great', 'Star Wars');
SELECT add_comment('yoda', 'Harrison Ford is so fun', 'Star Wars');
SELECT add_comment('Prof. Venkman', 'My favourite actor is Bill Muray', 'Ghostbusters');
SELECT add_comment('Prof. Venkman', 'I love Bill Muray', 'Groundhog Day');
SELECT add_comment('Prof. Venkman', 'Bill Muray the best', 'Ghostbusters II');
SELECT add_comment('Capt. Dan', 'Amazing Tom Hanks', 'Forrest Gump');
SELECT add_comment('Capt. Dan', 'Fly me to the moon ... or not Tom Hanks', 'Appolo 13');
SELECT add_comment('Capt. Dan', 'Another great performance for Tom Hanks', 'Saving Private Ryan');
SELECT add_comment('Jenny', 'Tom Hanks is such a great actor', 'Philadelphia');

CREATE OR REPLACE FUNCTION get_lastname( name text )
RETURNS text AS $$
DECLARE
  lastname text;
BEGIN
  lastname := trim(substring(name, '[\s][^\s]*$'));
  RETURN lastname; 
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION find_most_talked_actors_in_comments()
RETURNS TABLE(name text, rank bigint) AS $$
BEGIN
  RETURN QUERY SELECT a.name, count(a.name) AS rank
  FROM actors a, comments c
  WHERE to_tsvector('english', c.comment) @@ to_tsquery('english', get_lastname(a.name))
  GROUP BY a.name
  ORDER by rank desc;
END;
$$ LANGUAGE plpgsql;


