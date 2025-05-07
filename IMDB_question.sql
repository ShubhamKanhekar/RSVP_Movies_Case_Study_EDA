USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/



-- Segment 1:




-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:
SELECT TABLE_NAME, 
	TABLE_ROWS
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'imdb';




-- Q2. Which columns in the movie table have null values?
-- Type your code below:
/*SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA= 'imdb'
	AND TABLE_NAME= 'movie'
;*/

select sum( case when id is null then 1 else 0 end) as null_count_id,
sum( case when title is null then 1 else 0 end) as null_count_title,
sum( case when year is null then 1 else 0 end) as null_count_year,
sum( case when date_published is null then 1 else 0 end) as null_count_date_published,
sum( case when duration is null then 1 else 0 end) as null_count_duration,
sum( case when country is null then 1 else 0 end) as null_count_country,
sum( case when worlwide_gross_income is null then 1 else 0 end) as null_count_worldwide_gross_income,
sum( case when languages is null then 1 else 0 end) as null_count_languages,
sum( case when production_company is null then 1 else 0 end) as null_count_production_company
from 
movie;


-- we got four column_names as output: country, lanquages, production_company and worldwide_gross_income. 
-- these cols contain null values.


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

-- yearwise trend:
SELECT year, count(*) as number_of_movies
FROM movie
GROUP BY year;

-- month wise trend:
SELECT MONTH(date_published),
	count(*)
FROM movie
GROUP BY MONTH(date_published)
ORDER BY MONTH(date_published);




/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

SELECT 'USA' as country, COUNT(*) FROM movie
WHERE country like '%USA%'
	and year = 2019
union all
select 'India' as country, COUNT(*) from movie
where country like '%INDIA%' and year= 2019
;



/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:
SELECT DISTINCT genre FROM genre g;



/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

SELECT genre, count(genre) counts from genre
group by genre 
	having counts = (select max(cs) 
					from (select count(genre) cs 
						from genre 
                        group by genre
                        ) as subquery
					);



/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:
SELECT count(movie_id) 
FROM (
	SELECT movie_id, count(movie_id) from genre g GROUP BY movie_id HAVING count(movie_id)=1
    ) as single_movie_list;
    



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
    g.genre, AVG(m.duration)
FROM
    movie m
        INNER JOIN
    genre g ON m.id = g.movie_id
GROUP BY g.genre
;


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

select 
	g.genre,
    count(g.genre) as movie_count,
	rank() over w as genre_rank
from genre g
group by g.genre
window w as (order by count(g.genre) DESC);

-- thriller rank: 3




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
SELECT 
    MIN(avg_rating) AS min_avg_rating,
    MAX(avg_rating) AS max_avg_rating,
    MIN(total_votes) AS min_total_votes,
    MAX(total_votes) AS max_total_votes,
    MIN(median_rating) AS min_median_rating,
    MAX(median_rating) AS max_median_rating
FROM
    ratings;

-- 1.0, 10.0, 100, 725138, 1, 10
    

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
-- Type your code below:
-- Keep in mind that multiple movies can be at the same rank. You only have to find out the top 10 movies (if there are more than one movies at the 10th place, consider them all.)

with rankings as (
SELECT m.title,
	r.avg_rating, 
    rank() over (order by r.avg_rating DESC) as movie_rank
from movie m 
	inner join ratings r on m.id= r.movie_id
)
select title, avg_rating, movie_rank 
from rankings
where movie_rank<=10;





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

SELECT 
    r.median_rating, COUNT(*) AS movie_count
FROM
    movie m
        INNER JOIN
    ratings r ON m.id = r.movie_id
GROUP BY median_rating
ORDER BY median_rating
;



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

select production_company, 
		count(m.title) as movie_count,
		rank() over ( order by count(m.title) DESC) as prod_company_rank
from movie m inner join ratings r on m.id= r.movie_id
where r.avg_rating>8 and production_company is not null
group by m.production_company 
;



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

SELECT 
    g.genre, COUNT(*) AS movie_count
FROM
    movie m
        INNER JOIN
    ratings r ON m.id = r.movie_id
        INNER JOIN
    genre g ON m.id = g.movie_id
WHERE
    r.total_votes > 1000 AND m.year = 2017
        AND MONTH(m.date_published) = 03
GROUP BY g.genre;






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

select m.title, r.avg_rating, g.genre
from movie m
	inner join ratings r on m.id= r.movie_id
    inner join genre g on m.id= g.movie_id
where r.avg_rating>8
	and m.title like 'The%'
;
    



-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:
select count(*) as number_of_movies 
from movie m
	inner join ratings r on m.id=r.movie_id
    inner join genre g on m.id= g.movie_id
where m.date_published between '2018-04-01' AND '2019-04-01'
	AND r.median_rating =8;






-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

SELECT 'GERMANY' AS COUNTRY, SUM(R.total_votes) 
FROM 
MOVIE AS M
LEFT JOIN
RATINGS AS R
ON M.ID = R.MOVIE_ID
WHERE M.COUNTRY LIKE '%GERMANY%'

UNION ALL

SELECT 'ITALY' AS COUNTRY, SUM(R.total_votes) 
FROM 
MOVIE AS M
LEFT JOIN
RATINGS AS R
ON M.ID = R.MOVIE_ID
WHERE M.COUNTRY LIKE '%ITALY%';





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
    SUM(CASE WHEN name IS NULL THEN 1 ELSE 0 END) AS name_nulls,
    SUM(CASE WHEN height IS NULL THEN 1 ELSE 0 END) AS height_nulls,
    SUM(CASE WHEN date_of_birth IS NULL THEN 1 ELSE 0 END) AS date_of_birth_nulls,
    SUM(CASE WHEN known_for_movies IS NULL THEN 1 ELSE 0 END) AS known_for_movies_nulls
FROM names;







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

WITH top_three_genres AS (
    SELECT g.genre 
    FROM movie m 
    INNER JOIN genre g ON m.id = g.movie_id 
    INNER JOIN ratings r ON m.id = r.movie_id 
    WHERE r.avg_rating > 8 
    GROUP BY g.genre 
    ORDER BY COUNT(*) DESC 
    LIMIT 3
)
SELECT n.name AS director_name, COUNT(m.id) AS movie_count
FROM movie m
INNER JOIN genre g ON m.id = g.movie_id
INNER JOIN ratings r ON m.id = r.movie_id
INNER JOIN director_mapping dm ON m.id = dm.movie_id
INNER JOIN names n ON n.id = dm.name_id
WHERE r.avg_rating>8 and g.genre IN (SELECT genre FROM top_three_genres)
GROUP BY n.name
ORDER BY COUNT(*) DESC
LIMIT 3;


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

select n.name as actor_name, count(distinct m.id) as movie_count
from movie m 
	inner join ratings r on m.id= r.movie_id
	inner join role_mapping rm on m.id= rm.movie_id
    inner join names n on rm.name_id= n.id
where r.median_rating >=8
group by n.name
order by movie_count DESC
limit 2
;




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

select m.production_company, sum(r.total_votes) as vote_count,
	rank() over w as prod_comp_rank
from movie m 
	inner join ratings r on m.id= r.movie_id
group by production_company 
window w as (order by sum(r.total_votes) DESC)
limit 3
;





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

select n.name as actor_name, 
	sum(r.total_votes) as total_votes, 
    count(m.id) as movie_count,
    ROUND(SUM(avg_rating*total_votes)/SUM(total_votes),2) AS actor_avg_rating,
    RANK() OVER(ORDER BY  ROUND(SUM(avg_rating*total_votes)/SUM(total_votes),2) DESC) AS actor_rank
from movie m
	inner join role_mapping rm on m.id= rm.movie_id
    inner join names n on n.id= rm.name_id
    inner join ratings r on m.id= r.movie_id
where m.country='India' and rm.category='actor'
group by n.name
	having movie_count>=5
LIMIT 3;







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
    nm.name AS actress_name, 
    SUM(r.total_votes) AS total_votes,
    COUNT(m.id) AS movie_count,
    ROUND(SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes), 2) AS actress_avg_rating,
    RANK() OVER (ORDER BY ROUND(SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes), 2) DESC) AS actress_rank
FROM movie AS m 
INNER JOIN ratings AS r ON m.id = r.movie_id 
INNER JOIN role_mapping AS rm ON m.id = rm.movie_id 
INNER JOIN names AS nm ON rm.name_id = nm.id
WHERE rm.category = 'actress' 
AND m.country LIKE '%India%' 
AND m.languages LIKE '%Hindi%'
GROUP BY nm.name
HAVING COUNT(*) >= 3 
ORDER BY actress_rank 
LIMIT 5;







/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Consider thriller movies having at least 25,000 votes. Classify them according to their average ratings in
   the following categories:  

			Rating > 8: Superhit
			Rating between 7 and 8: Hit
			Rating between 5 and 7: One-time-watch
			Rating < 5: Flop
	
    Note: Sort the output by average ratings (desc).
--------------------------------------------------------------------------------------------*/
/* Output format:
+---------------+-------------------+
| movie_name	|	movie_category	|
+---------------+-------------------+
|	Get Out		|			Hit		|
|		.		|			.		|
|		.		|			.		|
+---------------+-------------------+*/

-- Type your code below:

select m.title,
	case 
		when r.avg_rating>=8 then 'Superhit'
        when r.avg_rating>=7 and r.avg_rating<8 then 'Hit'
        when r.avg_rating>=5 and r.avg_rating<7 then 'One-time-watch'
        else 'Flop'
	END AS movie_category
from movie m
	inner join genre g on m.id= g.movie_id
    inner join ratings r on m.id = r.movie_id
where r.total_votes>=25000 and g.genre= 'thriller'
order by r.avg_rating DESC
;




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

WITH genre_avg_duration AS (
    SELECT 
        g.genre,
        round(AVG(m.duration),2) AS avg_duration
    FROM movie AS m
    INNER JOIN genre AS g ON m.id = g.movie_id
    GROUP BY g.genre
)
SELECT 
    genre,
    avg_duration,
    SUM(avg_duration) OVER (ORDER BY genre ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total_duration,
    round(AVG(avg_duration) OVER (ORDER BY genre ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) AS moving_avg_duration
FROM genre_avg_duration
ORDER BY genre;






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

WITH top_three_genres AS (  
    SELECT g.genre
    FROM movie m
    INNER JOIN genre g ON m.id = g.movie_id
    GROUP BY g.genre
    ORDER BY COUNT(m.id) DESC
    LIMIT 3
),
ranked_movies AS (
    SELECT 
        g.genre, 
        m.year,
        m.title AS movie_name,
        m.worlwide_gross_income,
        RANK() OVER (PARTITION BY g.genre, m.year ORDER BY CAST(REPLACE(m.worlwide_gross_income, '$', '') AS DECIMAL) DESC) AS movie_rank
    FROM movie m
    INNER JOIN genre g ON m.id = g.movie_id
    WHERE g.genre IN (SELECT genre FROM top_three_genres)
)
SELECT 
    genre, 
    year, 
    movie_name, 
    worlwide_gross_income as worldwide_gross_income, 
    movie_rank
FROM ranked_movies
WHERE movie_rank <= 5
ORDER BY genre, year, movie_rank;




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

select m.production_company,
	count(m.id) as movie_count,
    rank() over (order by count(m.id) DESC) as prod_comp_rank
from movie m
	inner join ratings r on m.id= r.movie_id
where m.languages like '%,%' and r.median_rating>=8 and m.production_company is not null
group by m.production_company
;






-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on the number of Super Hit movies (Superhit movie: average rating of movie > 8) in 'drama' genre?

-- Note: Consider only superhit movies to calculate the actress average ratings.
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes
-- should act as the tie breaker. If number of votes are same, sort alphabetically by actress name.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	  actress_avg_rating |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.6000		     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

-- Type your code below:
select n.name as actress_name,
	sum(r.total_votes) as total_votes,
    count(m.id) as movie_count,
    avg(r.avg_rating) as actress_avg_rating,
    rank() over (order by count(m.id) DESC) as actress_rank
from movie m
	inner join ratings r on m.id= r.movie_id
    inner join genre g on m.id = g.movie_id
    inner join role_mapping rm on m.id= rm.movie_id
    inner join names n on rm.name_id= n.id
where g.genre= 'drama' and r.avg_rating>8 and rm.category ='actress' 
group by actress_name
order by actress_rank, actress_avg_rating DESC
limit 3
;






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



DELIMITER //

CREATE FUNCTION get_avg_inter_movie_days(director varchar(10))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE avg_days DECIMAL(10,2);

    WITH director_movies AS (
        SELECT 
            m.id AS movie_id,
            m.date_published,
            ROW_NUMBER() OVER (ORDER BY m.date_published) AS movie_rank
        FROM movie m
        INNER JOIN director_mapping dm ON m.id = dm.movie_id
        WHERE dm.name_id = director
    ),
    director_intervals AS (
        SELECT
            DATEDIFF(dm1.date_published, dm2.date_published) AS inter_movie_days
        FROM director_movies dm1
        LEFT JOIN director_movies dm2 ON dm1.movie_rank = dm2.movie_rank + 1
    )
    SELECT AVG(inter_movie_days)
    INTO avg_days
    FROM director_intervals;

    RETURN avg_days;
END //
DELIMITER ;


select dm.name_id as director_id,
	n.name as director_name,
	count(m.id) as number_of_movies,
	get_avg_inter_movie_days(dm.name_id) as avg_inter_movie_days,
	avg(r.avg_rating) as avg_rating,
	sum(r.total_votes) as total_votes,
	min(r.avg_rating) as min_rating,
	max(r.avg_rating) as max_rating,
	sum(m.duration) as total_duration
from movie m
	inner join ratings r on m.id= r.movie_id
	inner join director_mapping dm on m.id= dm.movie_id
	inner join names n on dm.name_id= n.id
	
group by dm.name_id
order by count(m.id) DESC
limit 9;







