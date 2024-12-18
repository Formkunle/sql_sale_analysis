--The first step in this project is importing csv data downloaded from kaggle into postgreSQL.
--Right click on Database and select CREATE TABLE OR
CREATE TABLE retail_sale
(transactions_id INTEGER, 
	sale_date DATE, 
	sale_time TIME, 
	customer_id INTEGER,
	genter VARCHAR(10),
	age INTEGER,
	category VARCHAR(30),
	quantity INTEGER ,
	price_per_unit REAL,
	cogs INTEGER,
	total_sale INTEGER);

/* After successfully created the table, the next thing is to import the Retail_sales csv dataset into the postgrSQL.
To import the dataset. Right click on the table you created and select import/Export Dataset.  Select your data where you save it and click ok
Make sure the data type of each column is correct, Hence you will not be able to import your data. */ 

--View the first 10 rows of the entire dataset.
SELECT *
FROM retail_sale
LIMIT (10);

--Count total number of dataset
SELECT COUNT (*) AS total_number_of_dataset
FROM retail_sale;

--DATA CLEANING
--(1). Check for NULL value
SELECT *
FROM retail_sale
WHERE transaction_id IS NULL;

SELECT *
FROM retail_sale
WHERE sale_date IS NULL;

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
--(2). View the number of null in age column
SELECT COUNT (*)
FROM retail_sale
WHERE age IS NULL;

--Delete all the null value 
DELETE FROM retail_sale
WHERE 
	transaction_id IS NULL
	OR
	sale_date IS NULL
	OR
	sale_time IS NULL
	OR
	customer_id IS NULL
	OR
	gender IS NULL
	OR
	age IS NULL
	OR
	category IS NULL
	OR 
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL 
	OR 
	total_sale IS NULL;

--(3). Check for DUPLICATE value.
SELECT transaction_id, COUNT(*)
FROM retail_sale
GROUP BY transaction_id
HAVING COUNT(*) > 1;

--(4). Check for OUTLIERS using Interuartlies range (IGR) 
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

--(5). Check the total number of dataset
SELECT COUNT (*) AS total_number_of_dataset
FROM retail_sale;

--DATA EXPLORATION
--(a). What is the total sales?
SELECT COUNT(*) AS total_sale
FROM retail_sale;

--(b). How many unique customers did we have?
SELECT COUNT(DISTINCT customer_id) AS total_number_of_customers
FROM retail_sale;

--(c). How many male customers did we have in the dataset?
SELECT COUNT (*) AS male_customers
FROM retail_sale
WHERE gender = 'Male';

--(d). How many female customers we have in the dataset?
SELECT COUNT (*) AS female_customers
FROM retail_sale
WHERE gender = 'Female';

--(e). What is the percentage of male customers?
SELECT COUNT(CASE WHEN gender = 'Male' THEN 1 END) AS male_count, 
	COUNT (*) AS total_count,
	(COUNT(CASE WHEN gender = 'Male'THEN 1 END)*100.0 / COUNT (*)) 
	AS Male_percentage
	FROM retail_sale;

--(f). What is the percentage of female customers in the dataset?
SELECT COUNT(CASE WHEN gender = 'Female'THEN 1 END) AS female_count, 
	COUNT (*) AS total_count,
	(COUNT(CASE WHEN gender = 'Female'THEN 1 END)*100.0 / COUNT (*)) AS Female_percentage
	FROM retail_sale;

--(g). What is the Minimum age of the customers in the dataset?
SELECT MIN(age) AS minimum_age
FROM retail_sale;

--(h). What is the maximum age of the customers in the dataset?
SELECT MAX(age) AS maximum_age
FROM retail_sale;

--(i). What is the average age of the customers in whole number?
SELECT ROUND(AVG(age), 0) AS Average_age
FROM retail_sale;

--(j). How many category of the product did we have?
SELECT DISTINCT category AS product_cateory
FROM retail_sale;

--Data Analysis  and Business Problems and Solution

--Q.1 Write SQL query to retrieve total sales, total transaction and all sales made on both 2022-02-03 and 2022-02-05?

SELECT SUM(total_sale)
FROM retail_sale;

SELECT SUM(transaction_id) AS total_transaction
FROM retail_sale;
FROM retail_sale
WHERE sale_date = '2022-02-03' OR sale_date = '2022-02-05'
ORDER BY sale_date, age ASC;

/* Q.2 Write a query to retrieve all transactions where the category 
is Beauty and the Quantity sold is more than 2 in the month of July. 2022 */
SELECT *
FROM retail_sale
WHERE category = 'Beauty'
AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-07'
AND quantity >= 2; 

--Q.3 Writ a SQL query to calculate the total sales (total_sales) for each category
SELECT category, COUNT(*) AS Total_Orders, 
SUM(total_sale) AS Total_sales_for_each_category
FROM retail_sale
GROUP BY category;

--Q.4 Writ the query to find the average age of customers who purchased items from the 'Beauty' category
SELECT category, ROUND(AVG(age),4) AS Beauty_average_age
FROM retail_sale
GROUP BY category
HAVING category = 'Beauty';

--Q.5 Write the query to find the average sales per each age group and obtain the number of quantity sold per age group.
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
	
--Q.6 Write a SQL query to find all transactions where the total_sale is greater than 1000.  
SELECT COUNT(total_sale) AS Transaction_greater_1000
FROM retail_sale
WHERE total_sale > 1000;

--Q.7 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
SELECT category, gender, COUNT(transaction_id) AS Total_sale_by_gender_for_each_category
FROM retail_sale
GROUP BY category, gender
ORDER BY 1;

--Q.8 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year:
SELECT
EXTRACT(YEAR from sale_date) AS Year,
EXTRACT(MONTH FROM sale_date) AS Month,
AVG(total_sale) AS Average_sales
FROM retail_sale
GROUP BY 1,2
ORDER BY 3 DESC;

--Q.9 Determine the top 5 customers who contributed to total sales and calculate their contribution percentage

-- Calculate total sales by all customers
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

--Q.10 Write a SQL query to find the number of unique customers who purchased items from each category.
SELECT category, 
COUNT(DISTINCT(customer_id)) AS count_unique_customer
FROM retail_sale
GROUP BY 1
ORDER BY 2 DESC;

--Q.11 Write an SQL query to calculate the average age for each category product
SELECT 
    category, 
    ROUND(AVG(age), 2) AS average_age
FROM retail_sale
GROUP BY category
ORDER BY average_age DESC;

--Q.12	Write a SQL query to create each shift and number of orders (Example Morning < 12, Afternoon Between 12 & 17, Evening >17)
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

--END OF THE PROJECT;