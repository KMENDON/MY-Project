
USE imdb;

/* Let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.*/

-- Q1. Find the total number of rows in each table of the schema?

-- Number of rows = 3867
SELECT COUNT(*) as Direct_mapping_count FROM DIRECTOR_MAPPING;

-- Number of rows = 14662
SELECT COUNT(*)  as Genre_count FROM GENRE ;

-- Number of rows = 7997
SELECT COUNT(*) as Movie_count FROM  MOVIE;

-- Number of rows = 25735
SELECT COUNT(*) as Names_count FROM  NAMES;

-- Number of rows = 7997
SELECT COUNT(*)  as Rating_count FROM  RATINGS;

-- Number of rows = 15615
SELECT COUNT(*) as Role_Mapping_count FROM  ROLE_MAPPING;

-- Q2. Which columns in the movie table have null values?

SELECT SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS id_nulls_counts, 
	SUM(CASE WHEN title IS NULL THEN 1 ELSE 0 END) AS title_nulls_counts, 
	SUM(CASE WHEN date_published IS NULL THEN 1 ELSE 0 END) AS date_published_nulls_counts, 
	SUM(CASE WHEN duration IS NULL THEN 1 ELSE 0 END) AS duration_nulls_counts,
	SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS country_nulls_counts,
	SUM(CASE WHEN worlwide_gross_income IS NULL THEN 1 ELSE 0 END) AS worlwide_gross_income_nulls_counts,
	SUM(CASE WHEN languages IS NULL THEN 1 ELSE 0 END) AS languages_nulls_counts,
	SUM(CASE WHEN production_company IS NULL THEN 1 ELSE 0 END) AS production_company_nulls_counts 
FROM movie;

-- Four columns of the movie table has null values (id_nulls_counts,title_nulls_counts,date_published_nulls_counts,duration_nulls_counts) 


-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */

SELECT year AS Year, COUNT(title) AS counts_of_number_of_movies
FROM movie
GROUP BY year;

SELECT MONTH(date_published) AS month_num, COUNT(title) AS counts_of_number_of_movies
FROM movie
GROUP BY month_num
ORDER BY month_num;

-- The highest number of movies is produced in the month of March.

/*We know USA and India produces huge number of movies each year. Lets find the number of movies produced by 
USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019?

SELECT Count(DISTINCT id) AS number_of_movies, year
FROM   movie
WHERE  ( country LIKE '%INDIA%'
          OR country LIKE '%USA%' )
       AND year = 2019; 

-- Number of movies produced in year 2019 in USA or India are 1059.

/* USA and India produced more than a thousand movies in the year 2019.*/

-- Let’s find out the different genres in the dataset.
-- Q5. Find the unique list of the genres present in the data set?

SELECT DISTINCT genre FROM genre;

/* So, RSVP Movies plans to make a movie of one of these genres.*/

/*Now, we want to know which genre had the highest number of movies produced in the last year.*/
-- Q6.Which genre had the highest number of movies produced overall?

SELECT     genre,
           Count(m.id) AS number_of_movies_count
FROM       movie       AS m
INNER JOIN genre       AS g
where      g.movie_id = m.id
GROUP BY   genre
ORDER BY   number_of_movies_count DESC limit 1 ;

-- Drama genre has produced the highest number of movies overall with overall count of 4285.


/* So, based on the insight, RSVP Movies should focus on the ‘Drama’ genre. 
However, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?

WITH movies_with_one_genre
     AS (SELECT movie_id
         FROM   genre
         GROUP  BY movie_id
         HAVING Count(DISTINCT genre) = 1)
SELECT Count(*) AS movies_with_one_genre_count
FROM   movies_with_one_genre; 

-- Number of movie belong to only one genre count is 3289.

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)

/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */

SELECT     genre,
           Round(Avg(duration),2) AS avg_duration_length
FROM       movie                  AS m
INNER JOIN genre                  AS g
ON      g.movie_id = m.id
GROUP BY   genre
ORDER BY avg_duration_length DESC;

-- Action genre has the highest duration of 112.88 seconds

/* Movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the rank of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 

/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/

WITH genre_summary AS(
SELECT genre, COUNT(movie_id) AS movie_count,
	RANK() OVER(ORDER BY COUNT(movie_id) DESC) AS genre_rank
FROM genre
GROUP BY genre)
SELECT *
FROM genre_summary
WHERE genre='Thriller';

-- Thriller has rank=3 and movie count of 1484

/*Thriller movies is in top 3 among all genres in terms of number of movies*/

-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/

SELECT MIN(avg_rating) AS min_avg_rating,
	MAX(avg_rating) AS max_avg_rating,
	MIN(total_votes) AS min_total_votes,
	MAX(total_votes) AS max_total_votes,
	MIN(median_rating) AS min_median_rating,
	MAX(median_rating) AS max_median_rating
FROM ratings;
    
/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/

WITH movie_ranking_avgRating AS(
SELECT m.title AS title, avg_rating,
	RANK() OVER(ORDER BY avg_rating DESC) AS movie_rank
FROM ratings AS r
	INNER JOIN movie AS m ON m.id = r.movie_id)
SELECT *
FROM movie_ranking_avgRating
WHERE movie_rank<=10;

-- Top 3 movies have average rating >= 9.8

/*Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */

SELECT median_rating,
       Count(movie_id) AS movie_count_median_rating
FROM   ratings
GROUP  BY median_rating
ORDER  BY movie_count_median_rating DESC; 

/* Movies with a median rating of 7 are highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/ 

WITH production_company_hit_movie_summary
     AS (SELECT production_company,
                Count(movie_id)                     AS MOVIE_COUNT,
                Rank()
                  OVER(
                    ORDER BY Count(movie_id) DESC ) AS PROD_COMPANY_RANK
         FROM   ratings AS R
                INNER JOIN movie AS M
                        ON M.id = R.movie_id
         WHERE  avg_rating > 8
                AND production_company IS NOT NULL
         GROUP  BY production_company)
SELECT *
FROM   production_company_hit_movie_summary
WHERE  prod_company_rank = 1;

-- Dream Warrior Pictures and National Theatre Live production houses has produced the most number of hit movies , with the average rating of above 8.

-- It's ok if RANK() or DENSE_RANK() is used too
-- Dream Warrior Pictures or National Theatre Live production houss have produced the most number of hit movies (average rating > 8).

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */

SELECT genre,
       Count(M.id) AS MOVIE_COUNT
FROM   movie AS M
       INNER JOIN genre AS G
               ON G.movie_id = M.id
       INNER JOIN ratings AS R
               ON R.movie_id = M.id
WHERE  year = 2017
       AND Month(date_published) = 3
       AND country LIKE '%USA%'
       AND total_votes > 1000
GROUP  BY genre
ORDER  BY movie_count DESC; 

-- 24 Drama movies were released during March 2017 in the USA and had more than 1,000 votes
-- Top 3 genres are drama, comedy and action.
 

-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/

SELECT title, avg_rating, genre
FROM movie AS m
	INNER JOIN ratings AS r ON r.movie_id=m.id
	INNER JOIN genre AS g ON g.movie_id=m.id
WHERE title LIKE 'THE%' AND avg_rating>8
GROUP BY title
ORDER BY avg_rating DESC;



-- There are 8 movies with begin with 'The' and having average rating greater than 8.

-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?

SELECT COUNT(title) AS movie_count_between_givendates
FROM movie AS m
	INNER JOIN ratings AS r ON m.id=r.movie_id
WHERE median_rating=8
	AND date_published BETWEEN "2018-04-01" AND "2019-04-01"
ORDER BY date_published;

-- 361 movies have released between 1 April 2018 and 1 April 2019 with a median rating of 8

-- Q17. Do German movies get more votes than Italian movies? 

SELECT country, sum(total_votes) as total_votes_between_germany_italy
FROM movie AS m
	INNER JOIN ratings as r ON m.id=r.movie_id
WHERE country = 'Germany' or country = 'Italy'
GROUP BY country;

-- Answer is Yes

-- Q18. Which columns in the names table have null values??
/*
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/

SELECT SUM(CASE WHEN name IS NULL THEN 1 ELSE 0 END) as name_nullable_values, 
	SUM(CASE WHEN height IS NULL THEN 1 ELSE 0 END) as height_nullable_values, 
	SUM(CASE WHEN date_of_birth IS NULL THEN 1 ELSE 0 END) as date_of_birth_nullable_values, 
	SUM(CASE WHEN known_for_movies IS NULL THEN 1 ELSE 0 END) as known_for_movies_nullable_values 
FROM names;

-- Height, date_of_birth, known_for_movies columns contain NULLABLE VALUES 

/* Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */

WITH top_3_genres AS
(
           SELECT     genre,
                      Count(m.id)                            AS movie_count ,
                      Rank() OVER(ORDER BY Count(m.id) DESC) AS genre_rank
           FROM       movie                                  AS m
           INNER JOIN genre                                  AS g
           ON         g.movie_id = m.id
           INNER JOIN ratings AS r
           ON         r.movie_id = m.id
           WHERE      avg_rating > 8
           GROUP BY   genre limit 3 )
SELECT     n.NAME            AS director_name ,
           Count(d.movie_id) AS movie_count
FROM       director_mapping  AS d
INNER JOIN genre G
using     (movie_id)
INNER JOIN names AS n
ON         n.id = d.name_id
INNER JOIN top_3_genres
using     (genre)
INNER JOIN ratings
using      (movie_id)
WHERE      avg_rating > 8
GROUP BY   NAME
ORDER BY   movie_count DESC limit 3 ;

-- James Mangold , Anthony Russo and Soubin Shahir are top three directors in the top three genres whose movies have an average rating > 8

/* James Mangold can be hired as the director for RSVP's next project.
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */

WITH actor_ranking_basedon_medianrating AS(
SELECT name AS actor_name, COUNT(r.movie_id) AS no_of_movies,
	RANK() OVER(ORDER BY COUNT(r.movie_id) DESC) AS actor_rank_on_rating
FROM names AS n
	INNER JOIN role_mapping AS rm ON rm.name_id= n.id
	INNER JOIN ratings AS r ON r.movie_id= rm.movie_id
WHERE median_rating>=8
GROUP BY name
ORDER BY no_of_movies DESC)
SELECT actor_name, no_of_movies
FROM actor_ranking_basedon_medianrating
WHERE actor_rank_on_rating<3;

-- Mammootty and Mohanlal are actor with more number of movies.


/* RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/

WITH ranking AS(
SELECT production_company, sum(total_votes) AS vote_count,
	RANK() OVER(ORDER BY SUM(total_votes) DESC) AS prod_comp_rank
FROM movie AS m
	INNER JOIN ratings AS r ON r.movie_id=m.id
GROUP BY production_company)
SELECT production_company, vote_count, prod_comp_rank
FROM ranking
WHERE prod_comp_rank<4;

--  Marvel Studios, Twentieth Century Fox and Warner Bros are top three productoihs house with most number of votes.

/* Since RSVP Movies is based out of Mumbai, India it also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

WITH actor_summary
     AS (SELECT N.NAME                                                     AS
                actor_name
                ,
                total_votes,
                Count(R.movie_id)                                          AS
                   movie_count,
                Round(Sum(avg_rating * total_votes) / Sum(total_votes), 2) AS
                   actor_avg_rating
         FROM   movie AS M
                INNER JOIN ratings AS R
                        ON M.id = R.movie_id
                INNER JOIN role_mapping AS RM
                        ON M.id = RM.movie_id
                INNER JOIN names AS N
                        ON RM.name_id = N.id
         WHERE  category = 'ACTOR'
                AND country = "india"
         GROUP  BY NAME
         HAVING movie_count >= 5)
SELECT *,
       Rank()
         OVER(
           ORDER BY actor_avg_rating DESC) AS actor_rank
FROM   actor_summary;

-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

WITH actress_summary AS(
SELECT name AS actress_name, SUM(total_votes) AS total_votes, COUNT(m.id) AS movie_count, 
	ROUND(SUM(avg_rating*total_votes)/SUM(total_votes),2) AS actress_avg_rating, 
	RANK() OVER(ORDER BY SUM(avg_rating*total_votes)/SUM(total_votes) DESC) AS actress_rank
FROM movie AS m 
	INNER JOIN ratings AS r ON m.id=r.movie_id 
	INNER JOIN role_mapping AS rm ON m.id=rm.movie_id 
	INNER JOIN names AS n ON rm.name_id=n.id
WHERE category='actress' AND country= 'india' AND languages= 'hindi'
GROUP BY name
HAVING COUNT(m.id)>=3)
SELECT *
FROM actress_summary
WHERE actress_rank<=5;


/* Taapsee Pannu tops with average rating 7.74 and maximum number of votes. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/

WITH thriller_movies AS(
SELECT title, avg_rating
FROM genre as g 
	INNER JOIN movie AS m ON g.movie_id= m.id 
	INNER JOIN ratings AS r ON m.id= r.movie_id
WHERE genre= 'thriller')
SELECT *,
		(CASE
        WHEN avg_rating >=8 THEN 'Superhit movie'
        WHEN avg_rating >=7 AND avg_rating <8 THEN 'Hit movie'
        WHEN avg_rating >=5.0 AND avg_rating < 7 THEN 'One-time-watch movie'
        WHEN avg_rating <5.0 THEN 'Flop movie'END) AS Class
FROM thriller_movies
ORDER BY title;

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 

/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/

SELECT genre, ROUND(AVG(duration),2) AS avg_duration,
	SUM(AVG(duration)) OVER(ORDER BY genre ROWS UNBOUNDED PRECEDING) AS running_total_duration,
	AVG(AVG(duration)) OVER(ORDER BY genre ROWS 13 PRECEDING) AS moving_avg_duration
FROM movie AS m 
	INNER JOIN genre AS g ON m.id= g.movie_id
GROUP BY genre
ORDER BY genre;

-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

WITH genre_selection_high_grossing AS(
WITH top_genre AS(
SELECT genre, COUNT(title) AS movie_count,
	RANK() OVER(ORDER BY COUNT(title) DESC) AS genre_rank
FROM movie AS m
	INNER JOIN ratings AS r ON r.movie_id=m.id
	INNER JOIN genre AS g ON g.movie_id=m.id
GROUP BY genre)
SELECT genre
FROM top_genre
WHERE genre_rank<4),
top_five AS(
SELECT genre, year, title AS movie_name, worlwide_gross_income,
	RANK() OVER (PARTITION BY YEAR ORDER BY worlwide_gross_income DESC) AS movie_rank
FROM movie AS m 
	INNER JOIN genre AS g ON m.id= g.movie_id
WHERE genre IN (SELECT genre FROM genre_selection_high_grossing))
SELECT *
FROM top_five
WHERE movie_rank<=5;

-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits 
-- among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among 
-- multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/

WITH production_company_summary AS(
SELECT production_company, COUNT(m.id) AS movie_count,
	RANK() OVER(ORDER BY COUNT(id) DESC) AS prod_comp_rank
FROM movie AS m 
	INNER JOIN ratings AS r ON m.id=r.movie_id
WHERE median_rating>=8 AND production_company IS NOT NULL AND POSITION(',' IN languages)>0
GROUP BY production_company)
SELECT *
FROM production_company_summary
WHERE prod_comp_rank<3;


-- Star Cinema and Twentieth Century Fox are the top two production houses that have produced the highest number of hits among multilingual movies.

-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

WITH actress_summary AS
(
           SELECT     n.NAME AS actress_name,
                      SUM(total_votes) AS total_votes,
                      Count(r.movie_id)                                     AS movie_count,
                      Round(Sum(avg_rating*total_votes)/Sum(total_votes),2) AS actress_avg_rating
           FROM       movie                                                 AS m
           INNER JOIN ratings                                               AS r
           ON         m.id=r.movie_id
           INNER JOIN role_mapping AS rm
           ON         m.id = rm.movie_id
           INNER JOIN names AS n
           ON         rm.name_id = n.id
           INNER JOIN GENRE AS g
           ON g.movie_id = m.id
           WHERE      category = 'ACTRESS'
           AND        avg_rating>8
           AND genre = "Drama"
           GROUP BY   NAME )
SELECT   *,
         Rank() OVER(ORDER BY movie_count DESC) AS actress_rank
FROM     actress_summary LIMIT 3;

/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/


WITH top_directors_basedon_number_movies AS
(
SELECT name_id AS director_id, name AS director_name, dir.movie_id, duration,
	   avg_rating AS avg_rating, total_votes AS total_votes, avg_rating * total_votes AS rating_count,
	   date_published,
       LEAD(date_published, 1) OVER (PARTITION BY name ORDER BY date_published, name) AS next_publish_date
FROM director_mapping AS dir
INNER JOIN names AS nm ON dir.name_id = nm.id
INNER JOIN movie AS mov ON dir.movie_id = mov.id 
INNER JOIN ratings AS rt ON mov.id = rt.movie_id)

SELECT director_id, director_name,
        COUNT(movie_id) AS number_of_movies,
        CAST(SUM(rating_count)/SUM(total_votes)AS DECIMAL(4,2)) AS avg_rating,
        ROUND(SUM(DATEDIFF(Next_publish_date, date_published))/(COUNT(movie_id)-1)) AS avg_inter_movie_days,
        SUM(total_votes) AS total_votes, MIN(avg_rating) AS min_rating, MAX(avg_Rating) AS max_rating,
        SUM(duration) AS total_duration
FROM top_directors_basedon_number_movies
GROUP BY director_id
ORDER BY number_of_movies DESC
LIMIT 9;
