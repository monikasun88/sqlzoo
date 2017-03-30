-- Data
-- movie: id, title, yr, director, budget, gross
-- actor: id, name
-- casting: movieid, actorid, ord

-- 1. List the films where the yr is 1962 [Show id, title]
SELECT id, title
FROM movie
WHERE yr=1962

-- 2. Give year of 'Citizen Kane'.
SELECT yr
FROM movie
WHERE title='Citizen Kane'

-- 3. List all of the Star Trek movies, include the id, title and yr (all of these movies include the words Star Trek in the title). Order results by year.
SELECT id, title, yr
FROM movie
WHERE title like "Star Trek%"

-- 4. What id number does the actor 'Glenn Close' have?
SELECT id
FROM actor
WHERE name='Glenn Close'

-- 5. What is the id of the film 'Casablanca'
SELECT id
FROM movie
WHERE title='Casablanca'

-- 6. Obtain the cast list for 'Casablanca'.
-- what is a cast list?
-- The cast list is the names of the actors who were in the movie.
-- Use movieid=11768, (or whatever value you got from the previous question)
SELECT name
FROM casting JOIN actor ON actor.id=casting.actorid
WHERE movieid=11768

-- 7. Obtain the cast list for the film 'Alien'
SELECT name
FROM (SELECT actorid
FROM movie JOIN casting ON movieid=id
WHERE title='Alien') actorTable JOIN actor ON actorid=id

-- 8. List the films in which 'Harrison Ford' has appeared
SELECT title
FROM (SELECT movieid
FROM (SELECT id
FROM actor
WHERE name = 'Harrison Ford') hfMovie JOIN casting ON id=actorid) a JOIN movie
ON movieid=id

-- 9. List the films where 'Harrison Ford' has appeared - but not in the starring role. [Note: the ord field of casting gives the position of the actor. If ord=1 then this actor is in the starring role]
SELECT title
FROM movie JOIN
(SELECT movieid
FROM casting JOIN
  (SELECT id FROM actor WHERE name = 'Harrison Ford') hf_id
  ON actorid=id
WHERE ord > 1) hf_mov_notstar
ON id=movieid

-- 10. List the films together with the leading star for all 1962 films.
SELECT title, name
FROM actor JOIN (SELECT title, actorid
FROM movie JOIN casting ON id=movieid
WHERE yr=1962 and ord = 1) star_actors ON actorid=id

-- 11. Which were the busiest years for 'John Travolta', show the year and the number of movies he made each year for any year in which he made more than 2 movies.
SELECT yr,COUNT(title)
FROM
  movie JOIN casting ON movie.id=movieid
    JOIN actor ON actorid=actor.id
WHERE name='John Travolta'
GROUP BY yr
HAVING COUNT(title)=(
  SELECT MAX(c)
  FROM
    (SELECT yr,COUNT(title) AS c
      FROM
        movie JOIN casting ON movie.id=movieid
          JOIN actor ON actorid=actor.id
      WHERE name='John Travolta'
      GROUP BY yr) AS t
)

-- 12. List the film title and the leading actor for all of the films 'Julie Andrews' played in.
-- Did you get "Little Miss Marker twice"?
SELECT DISTINCT title, name
FROM
  (SELECT movieid,actorid
  FROM casting
  JOIN (SELECT movieid AS lead
    FROM actor JOIN casting ON actorid=id
    WHERE name='Julie Andrews') ja_mov ON casting.movieid=ja_mov.lead
  WHERE ord = 1) mov
JOIN movie ON movieid=movie.id
JOIN actor ON actorid=actor.id

-- 13. Obtain a list, in alphabetical order, of actors who've had at least 30 starring roles.
SELECT name
FROM
  (SELECT actorid, COUNT(*)
  FROM casting
  WHERE ord = 1
  GROUP BY actorid
  HAVING COUNT(actorid) >= 30) topthirty JOIN actor ON actorid=id
ORDER BY name

-- List the films released in the year 1978 ordered by the number of actors in the cast, then by title.
SELECT title, COUNT(*) AS numActors
FROM
  (SELECT *
  FROM movie
  WHERE yr = 1978) a JOIN casting ON id=movieid
GROUP BY title
ORDER BY numActors DESC, title

-- List all the people who have worked with 'Art Garfunkel'.
SELECT DISTINCT a2.name
FROM actor a1 JOIN casting c1 ON id=actorid
  JOIN casting c2 ON c1.movieid=c2.movieid
  JOIN actor a2 ON c2.actorid = a2.id
WHERE a1.name='Art Garfunkel' AND
  a2.name != 'Art Garfunkel'
