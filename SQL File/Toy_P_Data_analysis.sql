-- Data Analysis 
-- Lets understand the data and extracting insights, patterns, and trends from the cleaned data to make 
-- informed decisions.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
use Toy_sales_project

---------------------------------------------------------  Sales Trends  ------------------------------------------------------------------------------------------------
--Checking the sale period (1 Yr & 11 Months of sales data)

SELECT 
MIN([date]) AS starting_sale, 
MAX([date]) AS last_sale,
DATEDIFF(YEAR, MIN([date]), MAX([date])) AS years,
DATEDIFF(MONTH, MIN([date]), MAX([date])) % 12  AS months
FROM sales
-- As we get to know the data ranges from last 1.11 months of sales records 

--- over time sales trend

--  lets check the daily unit sold each day from last 1.11 Years 
select Date, sum(units) 'sales_trnd' 
from sales
group by date
order by [Date] 

--  lets check the weekly sale pattern 

SELECT CONCAT('Week: ', DATENAME(MONTH, [Date]), DATENAME(WEEK, [Date])) AS By_week, SUM(units) AS sales_trnd 
FROM  sales 
GROUP BY  DATENAME(YEAR, [Date]), DATENAME(WEEK, [Date]), DATENAME(MONTH, [Date]) 
ORDER BY MIN([Date])

--  lets check the week day sale pattern 

SELECT DATENAME(WEEKDAY, [Date]) as weekday_sale, SUM(units) AS sales_trnd 
FROM  sales 
GROUP BY  DATENAME(WEEKDAY, [Date])
ORDER BY min(date)

--Weekend sale and week day sale and over all

SELECT DATENAME(WEEKDAY, date) AS Sales_week, SUM(units) AS total_sale
FROM sales
WHERE YEAR(date) IN (2022, 2023) AND DATENAME(WEEKDAY, date) IN ('Sunday', 'Saturday')
GROUP BY DATENAME(WEEKDAY, date)/* weekend sale */

union ALL

SELECT DATENAME(weekday, date) AS 'Sales_week', SUM(units) AS 'total_sale'
FROM sales
WHERE YEAR(date) IN (2022, 2023) AND DATENAME(weekday, date) NOT IN ('Sunday', 'Saturday')
GROUP BY DATENAME(weekday, date) /* weekday sale */
ORDER BY 'Sales_week'

-- lets check the Monthly sale pattern

SELECT 
datename(Year, date) + '-' + datename(Month, date) AS 'year_&_month', 
SUM(units) AS 'sales_trnd' 
from sales 
GROUP BY datename(Year, date) + '-' +  datename(Month, date) 
ORDER BY min(date)

-- Year wise sale  

SELECT  DATENAME(YEAR, [Date]) AS Year, SUM(units) AS sales_trnd 
FROM  sales 
GROUP BY DATENAME(YEAR, [Date]) 
ORDER BY Year

-- Quarterly Sales Trend

SELECT DATENAME(QUARTER, [Date]) AS Quarter_sale, SUM(units) AS sales_trnd 
FROM sales 
GROUP BY DATENAME(QUARTER, [Date]) 
ORDER BY Quarter_sale

-- Now we will understand in deepth of 2022 and 2023 data 
-- which year more sale and comparing by Year of month to understand which month having increase in sale 
-- or declining in sale.
-- Comparing by year and diff. in sale and their percentage of growth.

With Sales_trnd As (select datename(month,date) as 'sales_month',
		sum(case when year(date)=2022 then units else 0 end) as 'sales_of_2022',
		sum(case when year(date)=2023 then units else 0 End) as 'Sales_of_2023',
		(sum(case when year(date)=2023 then units else 0 end)- sum(case when year(date)=2022 then units else 0 End)) as 'diff_in_sales'
		from sales
group by  datename(month,date))

Select *,round(cast((100.0* diff_in_sales/sales_of_2022) as float),2 ) as 'Perc_diff_in_sales' 
, case 
    when diff_in_sales <0 then 'Decline_in_sales'
	when diff_in_sales >0 then 'inclined_in_sales'
else 'No change'
end as 'sales_trend'
from sales_trnd

------------------------------------------------Store performance  ------------------------------------------------------------------------------------------------

select * from stores

-- Check Indivisual store performance in terms of sales unit sold

select  store_location ,sum(s.units) as 'total_Sales'
from stores st
join sales s
on st.store_id=s.store_id
group by store_location
order by total_sales desc

-- Check store count by location 

select store_location ,count(st.store_id) as 'store_counts'
from stores st
group by  store_location
order by store_counts desc

-- Now lets combined the above two queries to get an insights of store performance
-- based on locationwise
with store_sales as 
(select store_location as location,
        SUM(units) AS total_sales
        from stores st
        join sales s 
		on st.store_id = s.store_id
        group by store_location),
		 
store_counts as
(select store_location as location,
        count(store_id) as store_counts
		from stores
        group by store_location)

select ss.location,
       ss.total_sales,
       sc.store_counts
       from store_sales ss
       join store_counts sc
	   on ss.location = sc.location
       order by ss.total_sales desc

-- Total Store:
select count(store_id) as 'Total Store ID'from Stores

-- From the above table we can interprate higher the store higher the sales and vice versa
-- with CTE understand the lower sale from airport location and what was the sale from that location.

with 
airport_store_sales as 
(select store_location as location,
        sum(units) as total_sales
        from stores st
    join sales s on st.store_id = s.store_id
    where st.store_location = 'airport'
    group by store_location),

store_counts as
(select store_location as location,
        count(store_id) as store_counts
    from stores
    where store_location = 'airport'
    group by store_location)

select 
    ss.location,
    ss.total_sales,
    sc.store_counts
from airport_store_sales ss
join store_counts sc 
on ss.location = sc.location
order by ss.total_sales desc


------------------------------------------------Inventory performance  ------------------------------------------------------------------------------------------------

Select * from inventory

-- Inventory stock by Product 

select Product_id, 
       sum(stock_on_hand) as stock_by_product
from inventory
group by product_id
order by stock_by_product desc

-- Inventory stock at store

select store_id, sum(stock_on_hand) as stock_by_store
from inventory
group by store_id
order by stock_by_store desc

-- store performance based on Inventory

select st.Store_id, Store_name,sum(i.stock_on_hand) as 'total_inventory'
from stores st
join inventory i 
on st.store_id=i.store_id
group by st.store_id,st.store_name
order by total_inventory desc

--- total units sold in this output

with store_perf as(select st.Store_id, Store_name,sum(i.stock_on_hand) as 'total_inventory'
from stores st
Left join inventory i 
on st.store_id=i.store_id
group by st.store_id,st.store_name


------------------------------------------------ Product Performance Analysis  ------------------------------------------------------------------------------------------------

select * from Products

select 
     Product_category,
     Product_Name, 
     Sum(Product_cost) as 'Costof Price', 
     Sum(product_price) as'Sale Price'
     from products
group by Product_Category,Product_name

-- Lets check the sales performance by product category and product name 

select Product_category, Product_name, sum(units) as 'Total_unit_sold' 
from products P 
join sales s 
on p. product_id=s.product_id 
group by product_category, product_name 
order by product_category, product_name

-- from the above interpretation its clear about art and craft category having high demand 
-- and interms of product sale and playdoh having high in demand 

-- Lets understand high demand product category art and crafts more in details 
-- understnd which product is performing well.

select product_category, product_name, sum(units) as total_unit_sold
from products p
join sales s on p.product_id = s.product_id
where product_category = 'Art & Crafts'
group by product_category, product_name
order by total_unit_sold desc

-- as per our previous interpretation art and crafts is the most demanding category playdoh is highest 
--  contributing product for art and crafts catagory followed by Barrel O' Slime and lowest performing 
-- is playfoam.

--- After getting top performing product category now also its important to undertsnd top product of 
-- other category also lets dive into top selling product in each category.

with 
top_product_bycategory as 
(select Product_category, 
        Product_name, 
		sum(units) as 'Total_un_sold',
		Row_number() 
		        over (partition by Product_category order by(select null)) as row_num		
from products P
join sales s
on p.product_id=s.product_id
group by product_category, product_name)

select * from top_product_bycategory
where row_num=1

----------------------------------------------Profit Analysis----------------------------------------------------------------------------------------------------------------------------

-- Revenue analysis
-- Product performance based on profitiblity (Revenue analysis)
--> Revenue = (units) * (product_price)
--> Profit  = (Product_price) - (Product_cost)

-- Lets understand the Profit,Profit percentage, Revenue, per unit sold cost and sales by product.

select 
  P.product_id, 
  P.Product_name, 
  sum(S.units) as 'Total_units_sold',
  sum(S.units * Product_price) as Revenue, 
  Sum(S.units * (product_price - product_cost)) as 'Profit',
  (sum(S.units * (P.Product_price - P.Product_cost)) / sum(S.units)) as per_unit_cost,
  (sum(S.units * (P.Product_price - P.Product_cost)) / sum(S.units * P.Product_price)) * 100 as 'Profit_%'
from products P
join sales s
on p.product_id=s.product_id
group by p.product_id,P.product_name
order by 'Profit_%' desc

-- In analyzing product profitability, products with higher prices make more money, but not always
-- Even if a cheaper product sells the most, it might not bring in the most profit. So, it's important 
-- to know how unit cost affects profit to do well in business.

-- Lets undestand the Sale and Revenue,Profits contribution By Locationwise.
-->total units sold and total revenue, profits generated by the Location.

select * from stores
select * from Products
select * from Sales

select st. store_location, 
       sum(s.units) as total_unit_sold, 
	   sum(units * p. product_price) as Revenue,
	   (sum(S.units * (P.Product_price - P.Product_cost)) / sum(S.units * P.Product_price)) * 100 as 'Profit_%'
from stores st
join sales s
on st.store_id=s. store_id
join products P    
on s. product_id=p. product_id
group by st. store_location

-- fromthe above interpretation, despite the lower number of units sold at airports compared to other locations,
-- their higher sales are significant due to the premium prices and culture of purchasing premium products in 
-- airport, simply it impliese more margin company getting from Airport location.

--> Total Revenue achived from all store location (sum of all store location)
--> For futhur calculation.

with loca_per as
(select st.store_location, 
sum(s.units) as Total_unit_sold, 
sum(units * p.product_price) as Revenue
from stores st
join sales s
on st.store_id=s.store_id
join products P
on s.product_id=p.product_id
group by st.store_location)

select sum(revenue) as 'Total Revenue' from loca_per

-- Total Revenue achived from all store location: 14444572.35/- 

-- Lets understand what's the revenue contribution of each store location wrt Total_Revenue which we get
-- i.e, 14444572.35.

 

-- from this scenario we can get an insights about the store location performace that, the airport 
-- location appears to underperform compared to others by revenue percentage,but with just 3 store 
-- in airport location it contributing the highst profitable store location, but also need to understand 
-- the costing and expense of airport location store then we can finally conclude whether its profitable or not.


--------------------------------------------------- Periodic Sale Perfermance -----------------------------------------------------------------------------------------------------------------------------------

--Performing The Periodic Sales performance- It will helps the sales performance of historical sales and also seasonality sales too.

-- Lets analyse the last six months sales performance from the last updated sales
---> the last date recorded in sales table is ("2023-12-09")


select max(date) as 'Last sale date'FROM sales

--> Extract the exact last 6 months date from last updated sale date from the sale table.
--> i.e, [2023-06-09] to [2023-12-09]
select dateadd(Month,-6,(select max(date) from sales)) as 'Last 6 months date'

--> Need to check the sales performance between [2023-06-09] to [2023-12-09]
--> Daily wise sales Reports between [2023-06-09] to [2023-12-09] 
select 
    s.store_id, 
    s.Date, 
    st.store_name, 
    sum(s.units) as 'Total_units_sold', 
    sum(s.units * p.product_price) as 'total_revenue'
from sales s 
join stores st
on s.store_id=st.store_id
join products p
on s.product_id=p.product_id
where s.date between 
     dateadd(Month,-6,(select max(date) from sales)) And  
     (select max(date) from sales)
group by s.store_id, s.Date, st.store_name
order by min(month(s.date))

--> Monthly sales Report between [2023-06-09] to [2023-12-09]  

select 
    s.store_id, 
    datename(month, s.date) as sales_month,
    year(s.date) as sales_year,
    st.store_name, 
    sum(s.units) as total_units_sold, 
    sum(s.units * p.product_price) as total_revenue
from sales s 
join stores st on s.store_id = st.store_id
join products p on s.product_id = p.product_id
where s.date between dateadd(month, -6, (select max(date) from sales)) 
and (select max(date) from sales)
group by 
    s.store_id, 
    datename(month, s.date),
    year(s.date),
    st.store_name
order by  min(date)

--> For more clarity lets understand combined monthly report total revenue by each mnnth

select 
    datename(month, s.date) as sales_month,
    year(s.date) as sales_year,
    sum(s.units) as total_units_sold, 
    sum(s.units * p.product_price) as total_revenue
from sales s 
join stores st on s.store_id = st.store_id
join products p on s.product_id = p.product_id
where s.date between dateadd(month, -6, (select max(date) from sales)) and (select max(date) from sales)
group by datename(month, s.date),year(s.date)
order by min(s.date)

 
-- We can infer that there was a strong demand for the product from June to September, or it may have occurred prior to the 
-- mentioned period but small variation there it might be due to prev qtr. 
-- Lets analyse the sales for these months as same period last year (for 2022 Dates of the same month)
--> i.e, Last 6 months date [2022-12-09]: [2022-06-09] to [2022-12-09] 

select 
    s.store_id, 
    s.Date, 
    st.store_name, 
    sum(s.units) as 'Total_units_sold', 
    sum(s.units * p.product_price) as 'total_revenue'
from sales s
join stores st
on s.store_id=st.store_id
join products p
on s.product_id=p.product_id
where s.date between dateadd(Month,-6,'2022-12-09') and '2022-12-09'
group by s.store_id, s.Date, st.store_name

-- Monthly report of same period i.e, [2022-06-09] to [2022-12-09]

select 
    s.store_id, 
    datename(month, s.date) as sales_month,
    year(s.date) as sales_year,
    st.store_name, 
    sum(s.units) as total_units_sold, 
    sum(s.units * p.product_price) as total_revenue
from sales s 
join stores st on s.store_id = st.store_id
join products p on s.product_id = p.product_id
where s.date between dateadd(Month,-6,'2022-12-09') and '2022-12-09'
group by 
    s.store_id, 
    datename(month, s.date),
    year(s.date),
    st.store_name
order by  min(date)

--> For more clarity lets understand combined monthly report total revenue by each mnnth

select 
    datename(month, s.date) as sales_month,
    year(s.date) as sales_year,
    sum(s.units) as total_units_sold, 
    sum(s.units * p.product_price) as total_revenue
from sales s 
join stores st on s.store_id = st.store_id
join products p on s.product_id = p.product_id
where s.date between dateadd(Month,-6,'2022-12-09') and '2022-12-09'
group by datename(month, s.date),year(s.date)
order by min(s.date)

-- By comparing the reports from 2022 and 2023, we can observe a significant growth in revenue from June to September.
-- During this period, there was a noticeable increase in both revenue and units sold. However, comparing the months from 
-- October to December, there was a substantial decline in sales performance.

-- To understanding this we need to compared in same query so we can come for any conclusion.
-- Lets compare both the time period of 2022 and 2023 performance.
-- To understand the seasonality of sales happening by compared these two time or any specific interpretation from this reports.

-- Lets understand the quarterly sales trend over the store by each product

select * from sales
select * from stores

with 
comp_sales AS 
(select p.product_category, year(s.date) as 'Year_of_sale', datepart(quarter,s.date) as 'Quarterly_sales', 
sum(s.units) as 'Total_unit_sold'
from sales s
join products P
on s.product_id=p.product_id
group by p.product_category, datepart(quarter,s.date), year(s.date) ),

prev_yr_sales AS 
(SELECT product_category, Quarterly_sales, Total_unit_sold AS 'Previous_yr_unitsold'
FROM comp_sales
WHERE [Year_of_sale] = 2022),

current_yr_sales AS 
(SELECT product_category, Quarterly_sales, Total_unit_sold AS 'current_yr_unitsold'
FROM comp_sales
WHERE [Year_of_sale] = 2023)

SELECT c.product_category, c.Quarterly_sales, p.Previous_yr_unitsold, c.current_yr_unitsold,
       (current_yr_unitsold-Previous_yr_unitsold) as 'Sale Diff',
      ROUND(CASE 
               WHEN p.Previous_yr_unitsold = 0 THEN NULL
               ELSE ((c.current_yr_unitsold - p.Previous_yr_unitsold) / CAST(p.Previous_yr_unitsold AS float)) * 100 
           END,
		   2) AS 'Sale_Diff_%'
FROM current_yr_sales c
JOIN prev_yr_sales p
ON c.product_category = p.product_category
AND c.Quarterly_sales = p.Quarterly_sales
ORDER BY c.product_category, c.Quarterly_sales

-- From the above comparison report:

-- Art and Crafts:Good growth until the third quarter (Q3) of 2023,in the fourth quarter (Q4), there was a significant decline in sales.
-- Electronics: Underperformed in 2023 compared to 2022, Sales declined overall.
-- Games: Initially, there was slight growth in sales until the second quarter (Q2) of 2023. 
-- sales declined sharply in the third and fourth quarters (Q3 and Q4).
-- Sports & Outdoors: Saw a slight increase in sales until the third quarter (Q3).Unfortunately, sales declined in the fourth quarter (Q4).
-- Toys: Similar to the Sport, Saw a slight increase in sales until the third quarter (Q3).Unfortunately, sales declined in the fourth quarter (Q4)
-- Important: From above analysis company experiences underperformance or slower growth in sales consistently in the (Q4) compared to other quarters. 
-- This trend suggests a possible pattern of decreased sales performance during this period.

-- Lets Understand the comparison of Week sale pattern for weekday and weekend :
with 
weekend_sales as 
(select p.product_category, 
        year(s.date) as 'year_of_sale', 
        case when datename(dw, s.date) in ('Saturday', 'Sunday') then 'Week*end Sale'
           else 'Week-day Sale'
           end as 'Week_Types',
        sum(s.units) as 'Total_unit_sold'
from sales s  
join products p 
on s.product_id=p.product_id
group by p.product_category, 
	         year(s.date),
             case when datename(dw, s.date) in ('Saturday', 'Sunday') then 'Week*end Sale'
             else 'Week-day Sale'
             end),

prev_yr_sales as 
(select product_category, 
        Week_Types, 
        sum(Total_unit_sold) as 'previous_yr_unitsold'
from weekend_sales
where [year_of_sale] = 2022
group by product_category, Week_Types),


current_yr_sales as (
    select product_category, 
           Week_Types, 
           sum(total_unit_sold) as 'current_yr_unitsold'
from weekend_sales
where [year_of_sale] = 2023
group by product_category, Week_Types)

select c.product_category, 
       c.Week_Types,
       p.previous_yr_unitsold, 
       c.current_yr_unitsold,
       (c.current_yr_unitsold - p.previous_yr_unitsold) as 'sale-diff',
       round(case when p.previous_yr_unitsold = 0 then null
                 else ((c.current_yr_unitsold - p.previous_yr_unitsold) / cast(p.previous_yr_unitsold as float)) * 100 
             end,
             2) as '%_Diff'
from current_yr_sales c
join prev_yr_sales p
on c.product_category = p.product_category
and c.Week_Types = p.Week_Types
order by c.product_category, c.Week_Types

--Based on the comparison of weekday and weekend sales, we can interpret:

--> Weekday Dominance: 
--The analysis indicates that most sales occur on weekdays rather than weekends. This suggests that the business's sales performance
--is primarily driven by activities during the standard workweek.

--> Limited Weekend Impact: 
--Despite the potential for increased consumer leisure time or holidays during weekends, sales performance remains relatively unaffected, 
--suggesting that the business's offerings may not strongly align with weekend consumer behaviors.

--> Weekday Sales Growth: Comparing weekday and weekend sales percentages highlights a significant growth trend in weekday sales,
--with a growth rate surpassing 100% + . This underscores the substantial contribution of weekday sales to the business's overall 
--performance and revenue generation.

--------------------------------------------------------- Inventory Turnover Ratio --------------------------------------------------------------------------------------------

--> Lets Understand the Inventory turnover ratio (in/out flow) between 2022 and 2023
-- The inventory turnover ratio measures how quickly company sells its inventory: Higher ratio means faster sales,
-- while a lower ratio suggests slower sales or excess inventory. 
-- Comparing the ratio between 2022 and 2023 can show changes in sales performance.

-- Inventory flow helps track sales and make strategic decisions.

select * from Inventory


 select product_cost from products
 where product_cost=0
 
 with sales_category as
 (select p.Product_Category, 
		sum(case when year(s.date)=2022 then s.units*p.product_cost else 0 end) as COGS_2022,
		sum(case when year(s.date)=2023 then s.units * p.product_cost else 0 end) as COGS_2023
	from  Sales S
	join products p
	on s.product_id=p.product_id
	group by p.Product_Category),


avg_inventory as 
(Select p.Product_Category, 
        avg(case when year(s.date)=2022 then i.stock_on_hand else 0 end) as Avg_inventory_2022,
		avg(case when year(s.date)=2023 then i.stock_on_hand else 0 end) as Avg_inventory_2023
	from inventory i
	join products p
	on i.product_id=p.product_id
	join sales s
	on i.product_id=s.product_id
	group by p.product_category)


select sc.product_category,
       sc.COGS_2022,
	   ai.Avg_inventory_2022,
	   sc.COGS_2023,
	   ai.Avg_inventory_2023,
	   (Avg_inventory_2023-Avg_inventory_2022) as 'Inv.Diff'
from sales_category sc
join avg_inventory ai
on sc.product_category=ai.product_category

-- Most categories show a decrease in average inventory, except for Art and Crafts, where it's increased.
-- This might indicate either increased demand or declining sales performance. To make strategic decisions, understanding the
-- inventory turnover ratio is crucial for efficient inventory management. (Inv turnover ratio= COGS/avg_inv)


with sales_category as 
(select p.product_category, 
        sum(case when year(s.date) = 2022 then s.units * p.product_cost else 0 end) as COGS_2022,
        sum(case when year(s.date) = 2023 then s.units * p.product_cost else 0 end) as COGS_2023
    from sales s
    join products p on s.product_id = p.product_id
    group by p.Product_Category),


avg_inventory as
(select p.product_category, 
        avg(case when year(s.date) = 2022 then i.stock_on_hand else 0 end) as Avg_inventory_2022,
        avg(case when year(s.date) = 2023 then i.stock_on_hand else 0 end) as Avg_inventory_2023
    from inventory i
    join products p on i.product_id = p.product_id
    join sales s on i.product_id = s.product_id
    group by p.product_category)


select sc.product_category,
       sc.cogs_2022,
       ai.avg_inventory_2022,
       case when ai.avg_inventory_2022 = 0 then null else (sc.cogs_2022 / ai.avg_inventory_2022) end as Inv_Turn_Ratio_2022,
       sc.cogs_2023,
       ai.avg_inventory_2023,
       case when ai.avg_inventory_2023 = 0 then null else (sc.cogs_2023 / ai.avg_inventory_2023) end as Inv_Turn_Ratio_2023
from sales_category sc
join avg_inventory ai 
on sc.product_category = ai.product_category



-- Lets understand the analysis of individual products insights into inventory management, by understanding inventory 
-- trends at the product level, we can pinpoint areas for improvement and optimize our inventory strategies more effectively.

 with sales_category as
 (select p.product_name, 
		 sum(case when year(s.date)=2022 then s.units*p.product_cost else 0 end) as COGS_2022,
		 sum(case when year(s.date)=2023 then s.units * p.product_cost else 0 end) as COGS_2023
		from  Sales S
		join products p
		on s.product_id=p.product_id
		group by p.product_name),

avg_inventory as 
(Select p.product_name, 
        avg(case when year(s.date)=2022 then i.stock_on_hand else 0 end) as Avg_inventory_2022,
		Avg(case when year(s.date)=2023 then i.stock_on_hand else 0 end) as Avg_inventory_2023
	from inventory i
	join products p
	on i.product_id=p.product_id
	join sales s
	on i.product_id=s.product_id
	group by p.product_name)

select sc.product_name, 
       sc.COGS_2022,
	   ai.Avg_inventory_2022, 
	   case when ai.Avg_inventory_2022=0 then Null Else (sc.cogs_2022/ai.avg_inventory_2022) End as Inv_turn_ratio_2022,
       sc.COGS_2023,ai.Avg_inventory_2023,
       case when ai.Avg_inventory_2023=0 then Null Else (sc.cogs_2023/ai.avg_inventory_2023) End as Inv_turn_ratio_2023
from sales_category sc
join avg_inventory Ai
on sc.product_name=ai.product_name



SELECT DISTINCT PRODUCT_NAME FROM PRODUCTS
WHERE PRODUCT_CATEGORY='Games'

select product_id, avg(stock_on_hand) 
from inventory
group by product_id
