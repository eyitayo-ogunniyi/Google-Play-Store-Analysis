-- creating the table apps 
CREATE TABLE IF NOT EXISTS apps (
	App	TEXT,
	Category TEXT,	
	Rating TEXT,
	Reviews	TEXT,
	Size TEXT,	
	Installs TEXT,
	Type TEXT,	
	Price TEXT,
	Last_Updated TEXT
)

-- imported values through the import/export data option
-- exploring data
SELECT *
FROM apps
LIMIT 10;

-- checking for missing apps
SELECT *
FROM apps
WHERE app IS NULL;

-- checking for distinct apps
SELECT 
	COUNT(DISTINCT app) distinct_app
FROM 
	apps;

-- checking for duplicate apps
SELECT 
	app, 
	count(*) num
FROM 
	apps
GROUP BY 
	app
HAVING 
	count(*) > 1
;

-- investigating some of the duplicates
SELECT *
FROM apps
WHERE app = 'Bubble Shooter';
	
-- checking for duplicates using major field combos
-- 729 duplicates, some rows occured up to 8 times
SELECT 
	app, 
	category, 
	size, 
	last_updated, 
	count(*) num
FROM 
	apps
GROUP BY 
	1,2,3,4
HAVING 
	count(*) > 1
ORDER BY 
	count(*) DESC
;

-- investigating the duplicates further
SELECT 
	*
FROM 
	apps
WHERE 
	app = 'CBS Sports App - Scores, News, Stats & Watch Live'
;

-- creating a unique id for all rows
ALTER TABLE apps
ADD ID serial;

-- dropping duplicate rows
DELETE FROM apps
WHERE id NOT IN
    (
        SELECT MAX(id) as max_id
        FROM apps
        GROUP BY app, category, size, last_updated
	);
	
-- removing inconsistent apps
DELETE FROM apps
WHERE app = '#NAME?';

DELETE FROM apps
WHERE app = '/u/app';

-- checking distinct category
SELECT DISTINCT category
FROM apps;

-- examining the row with category '1.9'
-- this particular row has a lot of inconsistencies
SELECT *
FROM apps
WHERE category = '1.9';

-- removing the above row
DELETE FROM apps
WHERE category = '1.9';

-- cleaning the category column
-- changing category column to a title case
SELECT INITCAP(replace(category, '_', ' '))
FROM apps;

UPDATE apps
SET category = INITCAP(replace(category, '_', ' '));

-- replacing 'And' with 'and'
UPDATE apps
SET category = replace(category, 'And', 'and');

-- changing the category data type
ALTER TABLE apps
ALTER COLUMN category TYPE VARCHAR(50);

-- exploring the ratings
SELECT DISTINCT rating
FROM apps;

SELECT *
FROM apps
WHERE rating = 'NaN';

-- cleaning the rating column
-- updating rating where value is NaN
UPDATE apps
SET rating = CASE WHEN rating = 'NaN'
				  THEN replace(rating, 'NaN', null)
				  ELSE rating
				  END;

-- changing the rating data type
ALTER TABLE apps
ALTER COLUMN rating TYPE DECIMAL(2,1)
USING rating::decimal(2,1);

-- exploring ratings
SELECT 
	min(rating) max_rating,
	avg(rating) avg_rating,
	max(rating) min_rating
FROM 
	apps;
 
-- changing reviews data type to integer
ALTER TABLE apps
ALTER COLUMN reviews TYPE INTEGER
USING reviews::integer;

-- exploring size column
SELECT DISTINCT size
FROM apps;

-- cleaning the size column
-- changing all kbs to mbs
UPDATE apps
SET size = CASE 
				WHEN size LIKE '%k'
				THEN ROUND(
					CAST(TRIM('k' FROM size) as decimal)/1000, 2
					)
				WHEN size LIKE '%M'
				THEN CAST(TRIM('M' FROM size) as decimal)
				ELSE CAST(replace(size, 'Varies with device', null) as decimal)
	       END;

-- changing size data type to decimal
ALTER TABLE apps
ALTER COLUMN size TYPE decimal
USING size::decimal;

-- cleaning the installs column
SELECT 
	TRIM('+' FROM replace(installs, ',',''))
FROM 
	apps;

UPDATE apps
SET installs = TRIM('+' FROM replace(installs, ',',''));

-- changing installs data type to integer
ALTER TABLE apps
ALTER COLUMN installs TYPE INTEGER
USING installs::integer;

-- exploring the type column
-- a row has its type as 'NaN'
SELECT DISTINCT type 
FROM apps;

SELECT *
FROM apps
WHERE type = 'NaN'

-- update type 'NaN' to Free since price is 0
UPDATE apps
SET type = 'Free'
WHERE type = 'NaN';

-- altering type to varchar
ALTER TABLE apps
ALTER COLUMN type TYPE VARCHAR(10);

-- cleaning the price column
-- trimming out the dollar sign
UPDATE apps
SET price = TRIM('$' FROM price);

-- altering price data type
ALTER TABLE apps
ALTER COLUMN price TYPE numeric
USING price::numeric;

-- updating the date format
SELECT 
	TO_DATE(last_updated, 'MONTH DD, YYYY')
FROM 
	apps;

UPDATE apps
SET last_updated = TO_DATE(last_updated, 'MONTH DD, YYYY');

-- altering data type
ALTER TABLE apps
ALTER COLUMN last_updated TYPE DATE
USING last_updated::date;

--dropping the id column 
ALTER TABLE apps
DROP COLUMN id;

SELECT *
FROM apps;

-- Create users' review table
CREATE TABLE IF NOT EXISTS user_reviews
(
	App	TEXT,
	Review TEXT,
	Sentiment_category VARCHAR(10),
	Sentiment_score	TEXT
);

-- exploring user reviews
SELECT *
FROM user_reviews;

-- checking for duplicates
SELECT 
	app, 
	review, 
	Sentiment_category, 
	Sentiment_score,
	count(*) num
FROM 
	user_reviews
GROUP BY 
	1,2,3,4
HAVING 
	count(*) > 1
;

-- investigating some duplicates
SELECT *
FROM user_reviews
WHERE app = 'Candy Crush Saga'
ORDER BY review;

-- replacing empty reviews with "No review"
UPDATE user_reviews
SET review = 'No review'
WHERE review = 'nan';

UPDATE user_reviews
SET review = 'No review'
WHERE review IS NULL;

-- exploring sentiment category
SELECT 
	DISTINCT sentiment_category
FROM 
	user_reviews;

-- updating sentiment category
-- where there is no review
UPDATE user_reviews
SET sentiment_category = null
WHERE review = 'No review';

-- updating sentiment score
-- where there is no review
UPDATE user_reviews
SET sentiment_score = null
WHERE review = 'No review';

-- change data type from text to numeric
-- to ease calculation
ALTER TABLE user_reviews
ALTER COLUMN sentiment_score TYPE DECIMAL(4, 3)
USING sentiment_score::decimal(4, 3)

-- exploring sentiment score
SELECT 
	min(sentiment_score),
	avg(sentiment_score),
	max(sentiment_score)
FROM user_reviews;


-- Data Analysis

-- 1. grouping category on average price, rating and total installation
SELECT 
	category,
	count(app) number_of_apps,
	ROUND(avg(price), 2) avg_price,
	ROUND(avg(rating), 2) avg_rating,
	sum(installs) total_installs
FROM 
	apps
GROUP BY 
	category
ORDER BY 
	avg_rating DESC
;

-- 2. finance apps with its metrics
SELECT 
	COUNT(app) total_fin_app,
	AVG(price) avg_fin_price,
	AVG(rating) avg_fin_rating,
	SUM(installs) avg_fin_installs
FROM 
	apps
WHERE 
	category = 'Finance'
;
	
-- 3. Top 10 financial apps based on sentiment score
WITH app_sentiment_score AS (
	SELECT
		apps.app as finance_app,
		review,
		sentiment_score
	FROM 
		apps
	JOIN 
		user_reviews 
	USING(app)
	WHERE 
		apps.category = 'Finance'
		AND review <> 'No review'
)

SELECT
	finance_app,
	ROUND(avg(sentiment_score), 4) sentiment_score
FROM 
	app_sentiment_score
GROUP BY
	finance_app
ORDER BY 
	sentiment_score DESC
LIMIT 10;


-- 4. Checking reviews for top 5 apps
SELECT
	apps.app as finance_app,
	review
FROM 
	apps
JOIN 
	user_reviews 
USING(app)
WHERE 
	app IN ('BBVA Spain', 'Associated Credit Union Mobile', 
			'BankMobile Vibe App', 'A+ Mobile', 'Current debit card and app made for teens')
	AND review <> 'No review'
ORDER BY 
	sentiment_score DESC
LIMIT 60
;

-- 5. Checking customer pain
SELECT
	apps.app as finance_app,
	review
FROM 
	apps
JOIN 
	user_reviews 
USING(app)
WHERE 
	category = 'Finance'
	AND sentiment_category = 'Negative'
ORDER BY 
	sentiment_score
LIMIT 30
;