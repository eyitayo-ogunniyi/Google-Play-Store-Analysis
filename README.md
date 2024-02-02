## Google Play Store Analysis 

### Background
In this project, I work for a finance company closely eyeing the Android market before it launches its new app into Google Play. 
I have been asked to present an analysis of Google Play apps so that the team gets a comprehensive overview of different categories of apps, their ratings, and other metrics.

### About the dataset
The dataset used for my analysis was scraped from the Google Play Store in September 2018 and published on [Kaggle](https://www.kaggle.com/datasets/lava18/google-play-store-apps). 
This data has enormous potential to facilitate data-driven decisions and insights for businesses. 
I will analyze the Android app market by comparing ~10k apps in Google Play across different categories and also use the user reviews to draw a qualitative comparison between the apps.

### Business Questions
After carefully reviewing the business task and the data, I came up with four important questions for my analysis:
1.	What are the number of apps, average price, rating, and total installations in each category?
2.	What are the top 10 free Finance apps with the highest average sentiment score?
3.	What are the customers saying about the top finance apps?  
4.	What are the top 10 pain points for Finance apps by sentiment score? 

### Data Preparation
The dataset has two tables. The first is the `googleplaystore` table which contains different app features. 
The table consists of 10,841 rows and 13 Columns, but I imported the 9 columns I needed for my analysis. This table was imported as the `apps` table'.
I checked the tables first in Excel and noticed some inconsistencies, so I imported all fields as text since they contained typos and text

```SQL
CREATE TABLE IF NOT EXISTS apps (
	App TEXT,
	Category TEXT,	
	Rating TEXT,
	Reviews TEXT,
	Size TEXT,	
	Installs TEXT,
	Type TEXT,	
	Price TEXT,
	Last_Updated TEXT
)
```
The second table `user_review` consists of 64295 rows and 4 columns and shows users’ reviews with sentiment score. I imported this table into PostgreSQL as well.
My queries have been documented [here](https://github.com/eyitayo22/Google-Play-Store-Analysis/blob/main/Google%20Play%20Store%20Analysis%20Script.sql)

### Data Cleaning
I investigated my dataset for missing data, duplicate values, and inconsistent features. This is the summary of my cleaning process:

In the `apps` table:
1. There were no missing app names.
2. There were 9600 distinct apps but since Play Store permits two apps to have the same name, I checked for duplicates by grouping multiple columns and creating a unique ID on each row. 1062 duplicate rows were found and removed. I also dropped two rows with inconsistent app names like '#NAME?' and '/u/app'
3. I discovered a row with inconsistent multiple features and dropped it
4. Replaced all underscore in the category column with space, then updated the column from upper to proper case and changed the data type.
5. I also replaced the rating with ‘Nan’ to null so I could perform calculations on the column and altered the type to decimal.
6. I noticed the app size is in both kilobytes and megabytes. I updated all sizes to megabytes and altered the type to decimal.
7. Filled the missing type with free because the price for that row is 0 and altered data type to varchar.
8. Trimmed out '+' and '$' from the `installs` and `price` columns respectively.
9. Changed the date format for the app update and altered the column to a date type.
10. Finally, I dropped the ID column I created initially. My cleaned data now has 9776 rows and 9 columns

In the `user_reviews` table:
1. 26863 rows were without review. I wanted to drop them but that’s about 40% of the data, so I replaced missing reviews with ‘no review’ and excluded them from my statistical analysis.
2. Then, I updated the sentiment score column to null when there were no reviews so I could perform calculations on the column
3. I also altered the sentiment score column type to a numeric

### Analysis and Visualization
To answer the business questions, I used `GROUP BY` to aggregate each category by the number of apps, the average price, the average rating, and total installations. 
I also used CTE and inner join to get the top 10 finance apps based on the sentiment scores using both tables. 
My queries are documented [here](https://github.com/eyitayo22/Google-Play-Store-Analysis/blob/main/Google%20Play%20Store%20Analysis%20Script.sql).

I exported my cleaned CSV to Tableau and developed a dashboard to display my findings and communicate my analysis.

![Google Play Store Dashboard](Google-Play-Store-Dashboard.png)

### Insights
Here are the major insights from my analysis:
1. The total number of apps in the finance category is 349, out of which 95.05% is free. The average rating is 4.12 while the average price is $8.38 and the total installation is 460.35 million.
2. The finance category is one of the top 10 categories by the number of apps. It also has the highest average price, it has just 17 paid apps which could have influenced this result
3. The top finance app by average sentiment score is BBVA Spain, followed by Associated Credit Union Mobile.
4. The word **Easy** is one of the most frequent words for the top 10 finance apps.
5. 4 out of the top 10 customer pain points are user interface-related.

### Recommendations
With the findings above, here are a few recommendations that could help in launching a successful app:
- The app should be free, easy to navigate, and have a user-friendly interface. A well-designed user interface can be the determining factor in choosing what apps to use or not.
- The app should have features that make deposits and payments easier and faster. There should be a customer support feature that offers responsive support to address user issues promptly
- Provide security features that work like biometric authentication.
- The developers and UX/UI designers could examine some of the top 10 finance apps to see common features

**After the launch**
- Analyse app launch performance to see how well the launch is performing and areas for improvement
- Frequently gather user feedback to monitor performance, and make user-driven enhancements. By taking track of reviews, retention rate, and the number of downloads, we will get a robust background for necessary updates. 
- Regularly update the app with bug fixes, performance boosts, and new features.

### Limitation
This dataset was last updated in 2018, so it is not suitable for current business decisions.
