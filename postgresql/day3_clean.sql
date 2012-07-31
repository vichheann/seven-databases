DROP FUNCTION IF EXISTS find_movies_with(text);
DROP FUNCTION IF EXISTS find_movies_like(text,integer);
DROP FUNCTION IF EXISTS find_top5(text);
DROP FUNCTION IF EXISTS find_actors_starring(text);
DROP FUNCTION IF EXISTS add_comment(text, text, text);
DROP FUNCTION IF EXISTS querify_name(text);
DROP FUNCTION IF EXISTS find_most_talked_actors_in_comments();

DROP INDEX IF EXISTS movies_title_pattern; 
DROP INDEX IF EXISTS movies_title_trigram; 
DROP INDEX IF EXISTS movies_title_searchable; 
DROP INDEX IF EXISTS comments_movie_searchable; 

DROP TABLE IF EXISTS comments;
