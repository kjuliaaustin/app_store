CREATE TABLE applestore_description_combined AS

SELECT * FROM appleStore_description1

UNION ALL

SELECT * FROM appleStore_description2

UNION ALL

SELECT * FROM appleStore_description3

UNION ALL

SELECT * FROM appleStore_description4

-- Check the number of unique apps in both tables
SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM AppleStore

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM applestore_description_combined

-- Check for any missing values in key fields

SELECT COUNT(*) AS MissingValues
FROM AppleStore
WHERE track_name IS null or user_rating is null or prime_genre is NULL

SELECT COUNT(*) AS MissingValues
FROM applestore_description_combined
WHERE app_desc is null

-- Find out the number of apps per genre

SELECT prime_genre, Count(*) as NumApps
FRom AppleStore
Group by prime_genre
Order by NumApps DESC

-- Get an overview of the apps' ratings

SELECT Min(user_rating) AS MinRating,
		Max(user_rating) As MaxRating,
        Avg(user_rating) As AvgRating
FROM AppleStore

-- Determine whether paid apps have higher ratings than free apps

SELECT CASE
		WHEN price > 0 THEN 'Paid'
        ELSE 'Free'
      END AS App_Type,
      avg(user_rating) Avg_Rating
 From AppleStore
 Group by App_Type
 
 -- Check if apps with supported languages have higher ratings
 
 SELECT CASE
 		WHEN lang_num < 10 THEN '<10 languages'
        WHEN lang_num BETWEEN 10 AND 30 THEN '10-30 languages'
        ELSE '>30 languages'
     END AS language_bucket,
     avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY language_bucket
ORDER BY Avg_Rating DESC

-- Check genres with low ratings

SELECT prime_genre,
	avg(user_rating) AS Avg_Rating
 From AppleStore
 Group by prime_genre
 Order by Avg_Rating ASC
 Limit 10
 
 -- Check if there is correlation between the length of the app description and the user rating
 
 SELECT CASE
 			WHEN length(b.app_desc) <500 THEN 'Short'
            WHEN length(b.app_desc) BETWEEN 500 AND 1000 THEN 'Medium'
            ELSE 'Long'
          END AS description_length_bucket,
          avg(a.user_rating) AS average_rating
 FROM AppleStore AS a
 Join applestore_description_combined AS b	
 ON a.id = b.id
Group by description_length_bucket   
ORDER BY average_rating DESC

-- Check the top-rated apps for each genre

SELECT
	prime_genre,
    track_name,
    user_rating
FROM (
  	SELECT
  	prime_genre,
 	track_name,
  	user_rating,
    RANK() OVER(PARTITION by prime_genre order by user_rating desc, rating_count_tot DESC) as rank
    FROm AppleStore
   ) AS a
WHERE a.rank = 1

--Results
--1. Paid apps have better ratings. Users who pay for an app may have higher engagement and perceive more value which results in better ratings. If quality of app is good they should charge for their app.
--2. Apps supporting between 10 and 30 languages have better ratings.
--3. Finance and book apps have low ratings. User needs are not met therefore this is a great market opportunity.
--4. Apps with a longer description have better ratings. Users appreciate having a clear understanding of the apps features and capabilities before downloading.
--5. A new app should aim for an average rating above 3.5.
--6. Games and entertainment have high competition. Entering these spaces might be challenging due to high competition. However, it also shows high user demand in this genre.
