
### Retail Sales Analysis SQL Project
## Project Overview
## Project Title: Retail Sales Analysis

## Database: potfolio_project
This project is designed to demonstrate SQL skills and techniques typically used by data analysts to explore, clean, and analyze sales data. The project involves setting up a sales database, performing exploratory data analysis (EDA), and answering specific business questions via SQL queries. 

###  Objectives
1.	Set up a sales database: Create and populate a sales database with the provided sales data.
2.	Data Cleaning:
   * Identify and remove any records with missing or null value
   * Check for outliers using interquartile range method. And
   * Check for duplicate values and remove them if there is any duplicate values.
4.	Exploratory Data Analysis (EDA): Perform basic exploratory data analysis to understand the dataset.
5.	Business Analysis: Use POASTGRESQL to answer specific business questions and derive insights from the sales data.

### Project Structure
1. Database Setup
•	Database Creation: The project starts by creating a database named potfolio_project.
•	Table Creation: A table named retail_sale is created to store the sales data. The table structure includes columns for transaction_id, sale_date, sale_time, customer_id, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total_sale amount.


```sql
CREATE DATABASE potfolio_project;

CREATE TABLE retail_sale
(
    transactions_id INT PRIMARY KEY,
    sale_date DATE,	
    sale_time TIME,
    customer_id INT,	
    gender VARCHAR(10),
    age INT,
    category VARCHAR(35),
    quantity INT,
    price_per_unit FLOAT,	
    cogs FLOAT,
    total_sale FLOAT
); ```

After the creation of Table, the dataset was imported into postgreSQL.


2. Data Cleaning
Check for Null Value: Check for any null values in the dataset and delete records with missing data.

Check for Duplicate: Check for any duplicate records and remove the duplicate record in the dataset
- Check for Outliers: Check for outliers in the dataset using Interquartile range (IGR) method.
- Check the total number of records remain in the dataset.


(1). Check for NULL value
```sql
SELECT *  
FROM retail_sale 
WHERE transaction_id IS NULL;
SELECT *
FROM retail_sale
WHERE sale_date IS NULL;

```
SELECT *
FROM retail_sale
WHERE sale_time IS NULL;

SELECT *
FROM retail_sale
WHERE gender IS NULL;

SELECT *
FROM retail_sale
WHERE age IS NULL;

--Since age has null 

(2). View the number of null in age column
```
SELECT COUNT (*)
FROM retail_sale
WHERE age IS NULL;

--Delete all the null value 
```sql
DELETE FROM retail_sale
WHERE 
	transaction_id IS NULL OR sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR gender IS NULL OR age IS NULL OR category IS NULL OR  quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL  OR  total_sale IS NULL;

(3). Check for DUPLICATE value.

```
SELECT transaction_id, COUNT(*)
FROM retail_sale
GROUP BY transaction_id
HAVING COUNT(*) > 1;

(4). Check for OUTLIERS using Interuartlies range (IGR) 

```
WITH quartiles AS (SELECT PERCENTILE_CONT(0.25) 
WITHIN GROUP (ORDER BY age) AS Q1,
PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY age) AS Q3
FROM retail_sale),
iqr_calc AS (SELECT Q1,Q3, (Q3 -Q1) AS IQR 
FROM quartiles)
select *
FROM retail_sale
CROSS JOIN iqr_calc
WHERE age < Q1 -1.5 * IQR
OR age > Q3 + 1.5 *IQR;

(5). Check the total number of dataset

```
SELECT COUNT (*) AS total_number_of_dataset
FROM retail_sale;

2. Data Exploration
- View dataset: View the first 10 rows of the entire dataset.
- Record Count: Determine the total number of records in the dataset.
- Customer Count: Find out how many unique customers are in the dataset.
- Category Count: Identify all unique product categories in the dataset.

(a). What is the total sales?

```
SELECT COUNT(*) AS total_sale
FROM retail_sale;

(b). How many unique customers did we have?

```
SELECT COUNT(DISTINCT customer_id) AS total_number_of_customers
FROM retail_sale;

(c). How many male customers did we have in the dataset?

```
SELECT COUNT (*) AS male_customers
FROM retail_sale
WHERE gender = 'Male';

(d). How many female customers we have in the dataset?
```
SELECT COUNT (*) AS female_customers
FROM retail_sale
WHERE gender = 'Female';

(e). What is the percentage of male customers?
```
SELECT COUNT(CASE WHEN gender = 'Male' THEN 1 END) AS male_count, 
	COUNT (*) AS total_count,
	(COUNT(CASE WHEN gender = 'Male'THEN 1 END)*100.0 / COUNT (*)) 
	AS Male_percentage
	FROM retail_sale;

(f). What is the percentage of female customers in the dataset?
```
SELECT COUNT(CASE WHEN gender = 'Female'THEN 1 END) AS female_count, 
	COUNT (*) AS total_count,
	(COUNT(CASE WHEN gender = 'Female'THEN 1 END)*100.0 / COUNT (*)) AS Female_percentage
	FROM retail_sale;

(g). What is the Minimum age of the customers in the dataset?
```
SELECT MIN(age) AS minimum_age
FROM retail_sale;

(h). What is the maximum age of the customers in the dataset?
```
SELECT MAX(age) AS maximum_age
FROM retail_sale;

(i). What is the average age of the customers in whole number?
```
SELECT ROUND(AVG(age), 0) AS Average_age
FROM retail_sale;

(j). How many category of the product did we have?
```
SELECT DISTINCT category AS product_cateory
FROM retail_sale;

3. Data Analysis & Findings

## The following SQL queries were developed to answer specific business questions:

* Q.1 Write SQL query to retrieve total sales, total transaction and all sales made on both 2022-02-03 and 2022-02-05?
```
SELECT SUM(total_sale)
FROM retail_sale; 
```
SELECT SUM(transaction_id)
FROM retail_sale; 
```
SELECT *
FROM retail_sale
WHERE sale_date = '2022-02-03' OR sale_date = '2022-02-05'
ORDER BY sale_date, age ASC;

* Q.2 Write a query to retrieve all transactions where the category is Beauty and the Quantity sold is more than 2 in the month of July. 2022
```
SELECT *
FROM retail_sale
WHERE category = 'Beauty'
AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-07'
AND quantity >= 2; 

* Q.3 Writ a SQL query to calculate the total sales (total_sales) for each category
```
SELECT category, COUNT(*) AS Total_Orders, 
SUM(total_sale) AS Total_sales_for_each_category
FROM retail_sale
GROUP BY category;

* Q.4 Writ the query to find the average age of customers who purchased items from the 'Beauty' category
```
SELECT category, ROUND(AVG(age),4) AS Beauty_average_age
FROM retail_sale
GROUP BY category
HAVING category = 'Beauty';

* Q.5 Write the query to find the average sales per each age group and obtain the number of quantity sold per age group.
```
SELECT 
	CASE 
	WHEN age < 18 THEN 'Under 18'
	WHEN age BETWEEN 18 AND 25 THEN '18-25'
	WHEN age BETWEEN 26 AND 35 THEN '26-35'
	WHEN age BETWEEN 36 AND 50 THEN '36-50'
	ELSE 'Above 50'
	END AS age_group,
	SUM(total_sale) AS total_sale_per_age_group, COUNT(quantity) AS quantity_sold
FROM retail_sale
GROUP BY CASE 
	WHEN age < 18 THEN 'Under 18'
	WHEN age BETWEEN 18 AND 25 THEN '18-25'
	WHEN age BETWEEN 26 AND 35 THEN '26-35'
	WHEN age BETWEEN 36 AND 50 THEN '36-50'
	ELSE 'Above 50' 
	END
	ORDER BY total_sale_per_age_group DESC;

* Q.6 Write a SQL query to find all transactions where the total_sale is greater than 1000.  
```
SELECT COUNT(total_sale) AS Transaction_greater_1000
FROM retail_sale
WHERE total_sale > 1000;

* Q.7 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
```
SELECT category, gender, COUNT(transaction_id) AS Total_sale_by_gender_for_each_category
FROM retail_sale
GROUP BY category, gender
ORDER BY 1;

* Q.8 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year:
```
SELECT
EXTRACT(YEAR from sale_date) AS Year,
EXTRACT(MONTH FROM sale_date) AS Month,
AVG(total_sale) AS Average_sales
FROM retail_sale
GROUP BY 1,2
ORDER BY 3 DESC;

* Q.9 Determine the top 5 customers who contributed to total sales and calculate their contribution percentage
- Calculate total sales by all customers
```
WITH total_sale AS (
    SELECT SUM(total_sale) AS total_sale_amount
    FROM retail_sale
),

-- Calculate sales by each customer

customer_sale AS (
    SELECT customer_id, 
           SUM(total_sale) AS customer_total_sale
    FROM retail_sale
    GROUP BY customer_id
),

-- Rank customers by sales and select the top 5

top_5_customer AS (
    SELECT customer_id, 
           customer_total_sale
    FROM customer_sale
    ORDER BY customer_total_sale DESC
    LIMIT 5
)

-- Calculate the percentage contribution of the top 5 customers
SELECT customer_id,
       customer_total_sale,
       (customer_total_sale / total_sale.total_sale_amount) * 100 AS contribution_percentage
FROM top_5_customer, total_sale
ORDER BY contribution_percentage DESC;

* Q.10 Write a SQL query to find the number of unique customers who purchased items from each category.
```
SELECT category, 
COUNT(DISTINCT(customer_id)) AS count_unique_customer
FROM retail_sale
GROUP BY 1
ORDER BY 2 DESC;

* Q.11 Write an SQL query to calculate the average age for each category product
```
SELECT 
    category, 
    ROUND(AVG(age), 2) AS average_age
FROM retail_sale
GROUP BY category
ORDER BY average_age DESC;

* Q.12	Write a SQL query to create each shift and number of orders (Example Morning < 12, Afternoon Between 12 & 17, Evening >17)
```
WITH hourly_sale
AS
(SELECT *,
	CASE
	WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
	WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
	ELSE 'Evening'
  END AS shift
FROM retail_sale
)
SELECT shift,
COUNT(*) AS total_orders
FROM hourly_sale
GROUP BY shift
ORDER BY 2 DESC;

# Exploratory Data Analysis (EDA)

## Key observations from the cleaned dataset:
1.	Customer Distribution:
*	Total unique customers: [1987].
*	Male customers: There  are 975 Male customers taking over 49.0689% of the entire population of the customers.
*	Female customers: There  are 975 Female customers taking over 50.9311% of the entire population of the customers.

2.	Age Insights:
*	Minimum age: The minimum age of the customer is 18 years.
*	Maximum age: While the maximum age of the customer is 64.
*	Average age: The average age of the customer is 41.

3.	Product Categories:
*	Unique product categories: There are 3 categories of products in the dataset.

# Business Analysis,
*Using SQL, several business questions were answered to derive actionable insights:

1. Total Sales
*	Total transactions:  is 1988020.
*	Total sales amount: is 908230.

2. Customer Insights
*	The Percentage of male is 49.0689%
*	The Percentage of female is 50.9311%

3. Product and Sales Trends
*	Top-selling categories based on total sales is Electronics with total sales of 311445 and order of 678.
*	
 
4. Age Group Analysis
*	The highest spending age group is age_group 36-50 with 279245 total sale
*	Age group contributing most to quantity sold is age_group 36-50 with 625 quantity sold.
 
5. High-Value Transactions
*	Total transactions with sales > 1000: is 306.

6. Time-Based Analysis
*	Best-selling month: The overall best-selling month is July  in year 2022 with average sales of 541.3415 followed by February in year 2023 with the average sales of 535.5319.
 
*	Most orders were placed during the evening shift, with 1062 orders.
 
7. Customer Performance
* Top 5 customers (3, 1, 5, 2, and 4) contributed to total sales with (4.23, 3,39, 3,34, 2.79 and 2.60)%. These customers were identified for loyalty programs.
 
##  Key Insights
1.	Category Insights:
*	The Clothing category has a higher average age of customers compared to other categories, indicating that marketing strategies can target this demographic more effectively.

2.	High-Spending Age Group:
* The 36-50 age group spends the most, making it a primary target for premium product marketing.

3.	Time and Sales Patterns:
* Sales peak during the Evening shift, suggesting potential for targeted promotions or staffing optimizations during this period.

4.	High-Value Transactions:
* 306 of transactions account for significant sales, emphasizing the need to prioritize high-value customer segments.

5.	Seasonality:
July  in year 2022 shows seasonal trends, which can guide inventory and marketing campaigns.

# Conclusion
The analysis highlights patterns in customer demographics, product preferences, and sales trends. These findings can inform strategic decisions in areas such as inventory management, targeted marketing, and customer segmentation. Future work could incorporate predictive analytics and deeper time-series analysis to anticipate sales trends.


Contact
For questions or feedback, feel free to reach out:

Email: formkunle@gmail.com

LinkedIn: linkedIn.com/in/timothyadekunle1992

THANKS. ADEKUNLE TIMOTHY
