USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/

-- Segment 1:

-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:

SELECT table_name, table_rows
FROM INFORMATION_SCHEMA.tables
WHERE
TABLE_SCHEMA = "imdb";

-- Output
-- director_mapping table have 3867 row, genre have 14662 row, movie table have 9512 row
-- names table have 27011 row, ratings table have 8230 row, role_mapping have 15571 row

-- ---------------------------------------------------------------------------------------
 
-- Q2. Which columns in the movie table have null values?
-- Type your code below: 
  
SELECT	
    SUM(title IS NULL) AS title_null,
    SUM(year IS NULL) AS year_null,
    SUM(date_published IS NULL) AS datepublished_null,
    SUM(duration IS NULL) AS duration_null,
    SUM(country IS NULL) AS country_null,
    SUM(worlwide_gross_income IS NULL) AS worlwidegrossincome_null,
    SUM(languages IS NULL) AS languages_null,
    SUM(production_company IS NULL) AS production_company_null
FROM 
	movie;
    
-- Output
-- four columns have null value
-- country column have 20 null, worldwide_gross_income have 3724 null
-- languages column have 194 null, production_company have 528 null

-- ---------------------------------------------------------------------------------------

-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
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
-- Type your code below:

SELECT year, count(year) as number_of_movies
FROM movie
GROUP BY year;

-- Output
-- Lowest movies released in year 2019  however the higest movies released in year 2017

SELECT
	MONTH(date_published) AS month_num, COUNT(id) AS number_of_movies
FROM movie
GROUP BY MONTH(date_published)
ORDER BY MONTH(date_published);

-- Output
-- Lowest movies released in dec month however the higest movies released in Mar month

-- ---------------------------------------------------------------------------------------

/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

SELECT year,
  COUNT(DISTINCT id) AS movie_count
FROM movie
WHERE  
	year = 2019 AND (country LIKE '%INDIA%' OR country LIKE '%USA%');

-- Output
-- in 2019 India and USA has produced 1059 movies

-- ---------------------------------------------------------------------------------------

/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:

SELECT DISTINCT genre
FROM genre;

-- Output
-- There are 13 unique genre in genre table

-- ---------------------------------------------------------------------------------------

/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

SELECT
	g.genre, COUNT(m.id) AS num_of_movie
FROM genre g
INNER JOIN movie m ON g.movie_id = m.id
GROUP BY g.genre
ORDER BY COUNT(m.id) DESC;

-- Output
-- Last year higest 'drama' movies produced however 'others' movie produced the lowest number of movies in 2019

-- ---------------------------------------------------------------------------------------

/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:

SELECT COUNT(*) AS movies_single_genre
FROM (
    SELECT movie_id
    FROM genre
    GROUP BY movie_id
    HAVING COUNT(*) = 1
) AS single_genre_movies;

-- Output
-- 3289 movie have single genre

-- ---------------------------------------------------------------------------------------

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
-- Type your code below:

SELECT 
	g.genre, ROUND(avg(m.duration)) AS avg_duration
FROM movie m
LEFT JOIN genre g 
ON m.id = g.movie_id
GROUP BY g.genre
ORDER BY avg_duration DESC;

-- Output
-- Action movie duration is higest however horror movie duration is low

-- ---------------------------------------------------------------------------------------

/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)

/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

WITH genre_rank AS
(
SELECT
	genre, COUNT(movie_id),
	RANK() OVER(ORDER BY COUNT(movie_id) DESC) genre_rank
FROM genre
GROUP BY genre
)
SELECT * FROM genre_rank
WHERE genre="thriller";

-- Output
-- Thriller movies have RANK 3 and 1484 number of movies produced

-- ---------------------------------------------------------------------------------------

/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/

-- Segment 2:


-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:

SELECT MIN(avg_rating) AS min_avg_rating,
	MAX(avg_rating) AS max_avg_rating,
    MIN(total_votes) AS min_total_votes,
    MAX(total_votes) AS max_total_votes,
    MIN(median_rating) AS min_median_rating,
    MAX(median_rating) AS max_median_rating
FROM ratings;

-- Output
-- min avg rating is 1 and maxis 10, min votes are 100 and max votes are 725138, min median rating is 1 and max median rating is 10
    
-- ---------------------------------------------------------------------------------------
    
/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average ratings?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too

WITH movie_ratings AS 
(
    SELECT m.title, r.avg_rating,
           DENSE_RANK() OVER (ORDER BY r.avg_rating DESC) AS movie_rank
    FROM movie m
    LEFT JOIN ratings r ON r.movie_id = m.id
)
SELECT title, avg_rating, movie_rank
FROM movie_ratings
WHERE movie_rank <= 10;

-- Output
-- Krket Rank is 1st based on avg_rating h

-- ---------------------------------------------------------------------------------------

/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have

SELECT median_rating, 
	COUNT(movie_id) AS movie_count
FROM ratings
GROUP BY median_rating
ORDER BY median_rating;

-- Output
-- Higest movie have median_rating as 7 however 94 movie have lowest median rating

-- ---------------------------------------------------------------------------------------

/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:
SELECT production_company, 
       COUNT(id) AS movie_count,
       DENSE_RANK() OVER (ORDER BY COUNT(id) DESC) AS prod_company_rank
FROM movie AS m
INNER JOIN ratings r ON m.id = r.movie_id
WHERE avg_rating > 8 AND production_company IS NOT NULL
GROUP BY production_company
ORDER BY movie_count DESC;

-- output
-- Dream Warrior Pictures and Nitional Theatre live have produced 3 movies

-- ---------------------------------------------------------------------------------------

-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT g.genre, 
	COUNT(g.movie_id) AS movie_count
FROM genre g
LEFT JOIN ratings r 
ON g.movie_id = r.movie_id
LEFT JOIN movie m
ON m.id = g.movie_id
WHERE MONTH(date_published) = 3 AND year = 2017 AND m.country = 'USA' AND r.total_votes > 1000
GROUP BY g.genre
ORDER BY movie_count DESC;

-- Output
-- Drama movie in Mar 2017 have heigest movie count however Family movie have very less count

-- ---------------------------------------------------------------------------------------

-- Lets try to analyse with a unique problem statement.
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
-- Type your code below:

SELECT m.title, r.avg_rating, g.genre
FROM imdb.movie m
INNER JOIN imdb.ratings r ON m.id = r.movie_id
INNER JOIN imdb.genre g ON m.id = g.movie_id
WHERE m.title LIKE 'The%' AND r.avg_rating > 8
ORDER BY r.avg_rating DESC;

-- Output
-- THe Brighton miracle genre Drama have highest avg rating

-- ---------------------------------------------------------------------------------------

-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:

SELECT COUNT(r.movie_id) AS movie_count
FROM movie m
INNER JOIN ratings r
ON m.id = r.movie_id
WHERE r.median_rating = 8
AND m.date_published BETWEEN '2018-04-01' AND '2019-04-01';

-- Output
-- There are 361 movie whose rating is 8 and released between 1-apr-2018 to 1-Apr-2019

-- ---------------------------------------------------------------------------------------

-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

SELECT country, sum(total_votes) AS votes_count
FROM movie as m
INNER JOIN ratings as r
ON r.movie_id=m.id
WHERE country = 'germany' OR country = 'italy'
GROUP BY country;

-- Output
-- German lanurages are getting more votes than the italian votes

-- ---------------------------------------------------------------------------------------

-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/

-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

SELECT	
    SUM(name IS NULL) AS name_nulls,
    SUM(height IS NULL) AS height_nulls,
    SUM(date_of_birth IS NULL) AS date_of_birth_nulls,
    SUM(known_for_movies IS NULL) AS known_for_movies_nulls
FROM 
	names;

-- Output
-- Except names column each columns is having null value

-- ---------------------------------------------------------------------------------------

/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

WITH top_genre AS
(
	SELECT g.genre, COUNT(g.movie_id) AS movie_count
	FROM genre g
	INNER JOIN ratings r ON g.movie_id = r.movie_id
	WHERE avg_rating > 8
    GROUP BY genre
    ORDER BY movie_count DESC
    LIMIT 3
),

top_director AS
(
	SELECT n.name AS director_name,
		   COUNT(g.movie_id) AS movie_count,
		   ROW_NUMBER() OVER(ORDER BY COUNT(g.movie_id) DESC) AS director_rank
	FROM names n 
	INNER JOIN director_mapping d ON n.id = d.name_id 
	INNER JOIN genre g ON d.movie_id = g.movie_id 
	INNER JOIN ratings r ON r.movie_id = g.movie_id,
	top_genre
	WHERE g.genre IN (top_genre.genre) AND avg_rating > 8
	GROUP BY director_name
	ORDER BY movie_count DESC
)
SELECT director_name,movie_count
FROM top_director
WHERE director_rank <= 3;

-- Output
-- James Mangold, Soubin Shahir, Joe Russo are the top 3 greater than 8 rating directors

-- ---------------------------------------------------------------------------------------

/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT n.name AS actor_name, COUNT(r.movie_id) AS movie_count
FROM ratings r
INNER JOIN role_mapping rm ON rm.movie_id = r.movie_id
INNER JOIN names n ON rm.name_id = n.id
WHERE median_rating >= 8 AND category = 'actor'
GROUP BY n.name
ORDER BY movie_count DESC
LIMIT 2;

-- Output
-- Mammootty and Mohnlal are the to 2 actor whose rating is >=8

-- ---------------------------------------------------------------------------------------


/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
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
-- Type your code below:

WITH prod_house_ranked AS 
(
    SELECT m.production_company,
           SUM(r.total_votes) AS vote_count,
           RANK() OVER (ORDER BY SUM(r.total_votes) DESC) AS prod_comp_rank
    FROM movie AS m
    INNER JOIN ratings AS r ON m.id = r.movie_id
    GROUP BY m.production_company
)
SELECT  *
FROM prod_house_ranked
ORDER BY prod_comp_rank
LIMIT 3;

-- Output
-- Marvel Studios, Twentieth Century Fox, Warner Bros are the top 3 rank production house based on the votes

-- ---------------------------------------------------------------------------------------

/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

SELECT actor_name, total_votes, movie_count,
       ROUND(weighted_sum / total_votes_sum, 2) AS actor_avg_rating,
       RANK() OVER (ORDER BY weighted_sum / total_votes_sum DESC) AS actor_rank
FROM 
(
    SELECT n.name AS actor_name, 
           SUM(r.total_votes) AS total_votes,
           COUNT(m.id) AS movie_count,
           SUM(r.avg_rating * r.total_votes) AS weighted_sum,
           SUM(r.total_votes) AS total_votes_sum
    FROM movie m 
    INNER JOIN ratings r ON m.id = r.movie_id 
    INNER JOIN role_mapping rm ON m.id = rm.movie_id 
    INNER JOIN names n ON rm.name_id = n.id
    WHERE category = 'actor' AND country = 'India'
    GROUP BY actor_name
    HAVING COUNT(m.id) >= 5
) AS actor_stats
ORDER BY actor_avg_rating DESC
LIMIT 1;

-- Output
-- Based on the avg rating movie released in india top actor is Vijay Sethupathi

-- ---------------------------------------------------------------------------------------

-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

SELECT
    n.name AS actress_name,
    SUM(r.total_votes) AS total_votes,
    COUNT(m.id) AS movie_count,
    ROUND(SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes),2) AS actress_avg_rating,
    RANK() OVER (ORDER BY ROUND(SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes), 2) DESC) AS actress_rank
FROM
    names n
INNER JOIN role_mapping rm ON n.id = rm.name_id
INNER JOIN movie m ON rm.movie_id = m.id
INNER JOIN ratings r ON m.id = r.movie_id
WHERE
    rm.category = "ACTRESS" AND m.languages LIKE "%Hindi%" AND m.country = "INDIA"
GROUP BY
    n.name
HAVING
    COUNT(m.id) >= 3
LIMIT 5;

-- Output
-- Top 5 Actress based on avg rating and votes are Taapsee Pannu, Raashi Khanna, Manju Warrier, Nayanthara, Sonam Bajwa

-- ---------------------------------------------------------------------------------------

/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:

SELECT title,avg_rating,
			(CASE
			WHEN avg_rating > 8 THEN 'Superhit movies'
			WHEN avg_rating between 7 and 8 THEN 'Hit movies'
			WHEN avg_rating between 5 and 7 THEN 'One-time-watch movies'
			ELSE 'Flop movies'
			END) AS movies_avg_rating
FROM movie m
INNER JOIN genre g ON m.id = g.movie_id
INNER JOIN ratings r ON g.movie_id = r.movie_id
WHERE genre = 'Thriller';

-- Output
-- with above code movies are classified as per requirements

-- ---------------------------------------------------------------------------------------

/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

SELECT genre,
    ROUND(AVG(duration)) AS average_duration,
    ROUND(SUM(AVG(duration)) OVER (PARTITION BY genre ORDER BY genre), 2) AS running_total_duration,
    ROUND(AVG(AVG(duration)) OVER (PARTITION BY genre ORDER BY genre ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS moving_avg_duration
FROM movie
INNER JOIN genre ON movie.id = genre.movie_id
GROUP BY genre;

-- ---------------------------------------------------------------------------------------
-- Round is good to have and not a must have; Same thing applies to sorting

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
-- Type your code below:

-- Top 3 Genres based on most number of movies
WITH top_genres AS 
(
    SELECT
        genre,
        COUNT(m.id) AS movie_count,
        RANK() OVER(ORDER BY COUNT(m.id) DESC) AS genre_rank
    FROM
        movie AS m
    INNER JOIN genre g ON g.movie_id = m.id
    INNER JOIN ratings r ON r.movie_id = m.id
    WHERE
        avg_rating > 8
    GROUP BY
        genre
    ORDER BY
        movie_count DESC
    LIMIT 3
),
movie_summary AS (
    SELECT
        genre,
        year,
        title AS movie_name,
        worlwide_gross_income,
        DENSE_RANK() OVER (PARTITION BY year ORDER BY CAST(REPLACE(REPLACE(IFNULL(worlwide_gross_income, '0'), 'INR', ''), '$', '') AS DECIMAL(10)) DESC) AS movie_rank
    FROM
        movie AS m
    INNER JOIN genre g ON m.id = g.movie_id
    WHERE
        genre IN (SELECT genre FROM top_genres)
)
SELECT *
FROM movie_summary
WHERE movie_rank <= 5
ORDER BY year;

-- Output
-- Top 5 Grossing income movies are Star Wars: Episode VIII - The Last Jedi,The Fate of the Furious,Despicable Me3, Jumanji: Welcome to the Jungle are the top 5 highest grossing movies.

-- ---------------------------------------------------------------------------------------

-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

SELECT production_company, COUNT(m.id) AS movie_count,
	   DENSE_RANK() OVER(ORDER BY count(id) DESC) AS prod_comp_rank
FROM movie m 
INNER JOIN ratings r ON m.id = r.movie_id
WHERE median_rating >= 8 
AND production_company IS NOT NULL 
AND POSITION(',' IN languages) > 0
GROUP BY production_company
LIMIT 2;

-- Output
-- Top 2 production company is Star Cinema and Twentieth Century fox based on hit movie rank

-- ---------------------------------------------------------------------------------------

-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

WITH super_hit_actresses AS 
(
    SELECT n.name AS actress_name,
           SUM(r.total_votes) AS total_votes,
           COUNT(m.id) AS movie_count,
           ROUND(AVG(r.avg_rating), 2) AS actress_avg_rating,
           RANK() OVER (ORDER BY COUNT(*) DESC) AS actress_rank
    FROM movie m
    LEFT JOIN ratings r ON m.id = r.movie_id
    LEFT JOIN role_mapping rm ON m.id = rm.movie_id
    LEFT JOIN names n ON rm.name_id = n.id
    LEFT JOIN genre g ON m.id = g.movie_id
    WHERE r.avg_rating > 8 AND g.genre = 'Drama' AND rm.category = 'actress'
    GROUP BY actress_name
)
SELECT actress_name, total_votes, movie_count, actress_avg_rating, actress_rank
FROM super_hit_actresses
WHERE actress_rank <= 3
ORDER BY actress_rank;

-- Output
-- Top 3 actress are Parvathy Thiruvothu, Susan Brown,Amanda Lawrence based on super hit movie and ranking

-- ---------------------------------------------------------------------------------------

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
-- Type you code below:

WITH director_details AS 
(
    SELECT name_id AS director_id,
           name AS director_name,
           dm.movie_id,
           m.title,
           m.date_published,
           r.avg_rating,
           r.total_votes,
           m.duration
    FROM director_mapping dm
    INNER JOIN names n ON dm.name_id = n.id
    INNER JOIN movie m ON dm.movie_id = m.id
    INNER JOIN ratings r ON dm.movie_id = r.movie_id
),
next_date_published AS (
    SELECT *,
           LEAD(date_published, 1) OVER (PARTITION BY director_id ORDER BY date_published, movie_id) AS next_date_published
    FROM director_details
),
diff_in_date_published_in_days AS (
    SELECT *,
           DATEDIFF(next_date_published, date_published) AS inter_movie_duration
    FROM next_date_published
),
directors_ranked AS (
    SELECT director_id,
           director_name,
           COUNT(movie_id) AS number_of_movies,
           AVG(inter_movie_duration) AS avg_inter_movie_days,
           AVG(avg_rating) AS avg_rating,
           SUM(total_votes) AS total_votes,
           MIN(avg_rating) AS min_rating,
           MAX(avg_rating) AS max_rating,
           SUM(duration) AS total_duration,
           ROW_NUMBER() OVER(ORDER BY COUNT(movie_id) DESC, AVG(avg_rating) DESC) AS rank_of_director
    FROM diff_in_date_published_in_days
    GROUP BY director_id, director_name
)
SELECT director_id,
       director_name,
       number_of_movies,
       avg_inter_movie_days,
       avg_rating,
       total_votes,
       min_rating,
       max_rating,
       total_duration
FROM directors_ranked
WHERE rank_of_director <= 9;

-- Oputput
-- With above code we can get the top 9 director based on number of movies

-- ---------------------------------------------------------------------------------------