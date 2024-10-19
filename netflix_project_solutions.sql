-- Netflix Project

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
show_id	VARCHAR(6),
type VARCHAR(10),
title VARCHAR(150),	
director VARCHAR(208),	
casts VARCHAR(1000),	
country VARCHAR(150),	
date_added VARCHAR(50),	
release_year INT,	
rating VARCHAR(10),	
duration  VARCHAR(15),	
listed_in VARCHAR(100),	
description VARCHAR(250)
);

SELECT COUNT(*) AS total_content
FROM netflix;

SELECT DISTINCT type 
FROM netflix;

SELECT * FROM netflix;


-- 15 Business Problems 

-- 1. Count the Number of Movies vs TV Shows

SELECT 
      type, 
      COUNT(*) as total_content
FROM netflix
GROUP BY type;

-- 2. Find the Most Common Rating for Movies and TV Shows

SELECT type, 
       rating
FROM 	   
(SELECT type, 
       rating, 
       COUNT(*),
       RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
FROM netflix
GROUP BY 1, 2
) AS t1
WHERE ranking = 1;

-- 3. List All Movies Released in a Specific Year (e.g., 2020)

SELECT * 
FROM netflix 
WHERE type = 'Movie'
      AND
	  release_year = 2020;

-- 4. Find the Top 5 Countries with the Most Content on Netflix

SELECT 
      TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) as new_country,
	  COUNT(show_id) as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 5. Identify the Longest Movie

SELECT title, duration
FROM netflix
WHERE 
      type = 'Movie'
      AND 
	  duration IS NOT NULL
ORDER BY CAST(SPLIT_PART(duration, ' ',1) AS INT) DESC
LIMIT 1;

-- 6. Find Content Added in the Last 5 Years

SELECT * 
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

-- 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

SELECT *
FROM
	(SELECT *,
	       UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
	FROM netflix) AS t
WHERE director_name = 'Rajiv Chilaka';

        --OR
		
SELECT * 
FROM netflix 
WHERE director ILIKE '%Rajiv Chilaka%' 

-- 8. List All TV Shows with More Than 5 Seasons

SELECT * 
FROM netflix
WHERE 
	type = 'TV Show'
	AND 
	CAST(SPLIT_PART(duration, ' ',1) AS INT) > 5;

-- 9. Count the Number of Content Items in Each Genre

SELECT 
     UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	 COUNT(show_id) as total_content
FROM netflix
GROUP BY 1;

-- 10. Find each year and the average numbers of content release in India on netflix.
-- return top 5 year with highest avg content release!

SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        CAST(COUNT(show_id) AS INT) /
        CAST((SELECT COUNT(show_id) FROM netflix WHERE country = 'India') AS INT) * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY 1,2
ORDER BY avg_release DESC
LIMIT 5;


SELECT 
    release_year, 
    AVG(content_count) AS avg_content_per_year
FROM (
SELECT 
        release_year, 
        COUNT(*) AS content_count
    FROM 
        netflix
    WHERE 
        country = 'India'
	GROUP BY 
        release_year
) AS yearly_content
GROUP BY 
    release_year
ORDER BY 
    avg_content_per_year DESC
LIMIT 5;

-- 11. List All Movies that are Documentaries

SELECT * FROM netflix
WHERE 
     listed_in ILIKE '%Documentaries%';

-- 12. Find All Content Without a Director

SELECT* 
FROM netflix
WHERE director IS NULL;

-- 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

SELECT * FROM netflix
WHERE 
     casts ILIKE '%Salman Khan%'
	 AND 
	 release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

-- 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

SELECT 
      UNNEST(STRING_TO_ARRAY(casts, ',')) as actors,
	  COUNT(*) as total_content
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords in the description field.
    --Label content containing these keywords as 'Bad' and all other content as 'Good'.
	--Count how many items fall into each category.

	 
WITH CTE AS
(
SELECT *,
	   CASE   
	       WHEN description ILIKE '%Kill%' OR
				description ILIKE '%Violence%' Then 'Bad'
		   ELSE 'Good' 	 
	   END AS category 
 FROM netflix
 )  
 SELECT category, COUNT(*) AS total_content
FROM CTE
GROUP BY 1;





