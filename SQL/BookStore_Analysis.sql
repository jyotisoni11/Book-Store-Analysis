Create database if not exists bookstore;

use bookstore;

---- import books table
---- C:\JYOTI MYSQL\Project\sql project\books.csv

---- import customers table 
---- C:\JYOTI MYSQL\Project\sql project\Customers.csv

---- import orders table 
---- C:\JYOTI MYSQL\Project\sql project\orders.csv


select * from books 
limit 10 ;

select * from customers
limit 10;

select * from orders
limit 10 ;


-- 1 Find books published after the year 1950:
select * from books 
where Published_Year > 1950;


-- 2 Calculate total orders, units sold, and revenue for each genre, and rank genres by revenue.
with genre_sales as 
(
select b.genre , 
count(o.order_id) as total_orders,
sum(o.quantity) as total_unit_sold ,
sum(total_amount) as total_revenue 
from books b 
join orders o 
on o.book_id = b.book_id 
group by b.genre 
)
select genre , total_orders , total_unit_sold , total_revenue ,
rank() over(order by total_revenue desc) as revenue_rank
from genre_sales
order by revenue_rank;


-- 3 Show orders placed in November 2023:
select * from orders 
where Order_Date between '01-11-2023' and '30-11-2023';


-- 4 Find the top 10 customers by total spending, including their name, country, number of orders, total quantity purchased, and total spending.
select c.customer_id , c.name , c.country , 
count(o.order_id) as number_of_orders ,
sum(o.quantity) as total_quantity,
sum(o.total_amount) as total_spending
from customers c 
join orders o 
on o.customer_id = c.customer_id 
group by c.customer_id , c.name , c.country 
order by total_spending desc 
limit 10;


-- 5 Find the details of the most expensive book:
select * from books
order by Price desc
Limit 1 ;


-- 6 Divide customers into High, Medium, and Low-value customers based on their total spending using CASE.
select c.customer_id , c.name , 
sum(o.total_amount) as total_spending ,
case 
when sum(o.total_amount) >= 1000 then 'High Value'
when  sum(o.total_amount) >= 500 then 'Medium Value'
else 'Low Value'
end as customer_segment
from customers c 
join orders o 
on o.customer_id = c.customer_id 
group by c.customer_id , c.name
order by total_spending desc;


-- 7 Retrieve the total number of books sold for each genre:
select b.Genre , count(o.Quantity) as book_sold
from books b 
join orders o 
on o.book_id = b.book_id 
group by b.Genre;


-- 8 List customers who have placed at least 2 orders:
select Customer_ID , count(Order_ID) as order_count
from orders 
group by Customer_ID
having count(Order_ID) >= 2;


-- 9 Identify customers who have placed more than one order and calculate their total orders, total spending, and average order value.
select c.customer_id , c.name ,
count(o.order_id) as total_orders ,
sum(total_amount) as total_spending,
avg(o.total_amount) as average_order_value
from customers c 
join orders o 
on o.customer_id = c.customer_id 
group by c.customer_id , c.name 
having count(o.order_id) > 1
order by total_spending desc;


-- 10 Find the most frequently ordered book:
select o.Book_ID , b.Title , count(o.Order_ID) as count_order
from books b 
join orders o 
on o.Book_ID = b.Book_ID
group by o.Book_ID , b.Title
order by count_order desc 
limit 1;


-- 11 Calculate monthly revenue and total units sold and identify the months with the highest sales.
select 
year(str_to_date(trim(order_date), '%d-%m-%Y')) as order_year,
month(str_to_date(trim(order_date), '%d-%m-%Y')) as order_month,
sum(quantity) as total_unit_sold,
sum(total_amount) as total_revenue 
from orders 
group by 
year(str_to_date(trim(order_date), '%d-%m-%Y')),
month(str_to_date(trim(order_date), '%d-%m-%Y'))
order by total_revenue desc;


-- 12 Retrieve the total quantity of books sold by each author:
select b.Author , sum(o.Quantity) as total_quantity 
from books b 
join orders o 
on o.Book_ID = b.Book_ID 
group by b.Author;


-- 13 List the cities where customers who spent over $30 are located:
select distinct c.City , o.Total_Amount 
from customers c 
join orders o  
on o.customer_id = c.customer_id 
where Total_Amount > 30;


-- 14 Find the customer who spent the most on orders:
select c.customer_id , c.name , sum(o.total_amount) as total_spent 
from customers c 
join orders o 
on o.customer_id = c.customer_id 
group by c.customer_id , c.name  
order by total_spent desc
limit 1 ; 


-- 15 Calculate the stock remaining after fulfilling all orders:
select b.book_id , b.stock as orginal_stock , 
coalesce(sum(o.quantity),0) as total_ordered, 
b.stock - coalesce(sum(o.quantity),0) as stock_remaining
from books b 
left join orders o 
on o.book_id = b.book_id 
group by b.book_id, b.stock ;


-- 16 find the Top 10 books based on total quantity sold.
select b.title , sum(o.quantity) as total_quantity_sold
from books b 
join orders o 
on o.book_id = b.book_id 
group by b.title 
order by total_quantity_sold desc 
limit 10 ; 


-- 17 calculate the total revenue for each book and then rank the books within their respective genre.
with book_revenue as
(
select 
b.book_id , 
b.title, 
b.genre ,
sum(o.total_amount) as total_revenue 
from books b 
join orders o 
on o.book_id = b.book_id 
group by b.book_id , b.title, b.genre
)
select 
book_id , 
title , 
genre , 
total_revenue ,
rank() over(partition by genre order by total_revenue desc) as revenue_rank
from book_revenue 
order by genre , revenue_rank ;


-- 18 Which book generated the highest revenue within each genre?
with book_revenue as 
(
select 
b.book_id, 
b.title, 
b.genre,
sum(o.total_amount) as total_revenue 
from books b 
join orders o 
on o.book_id = b.book_id
group by b.book_id , b.title , b.genre 
),
ranked_books as (
select 
book_id ,
title,
genre , 
total_revenue ,
rank() over(partition by genre order by total_revenue desc) as revenue_rank
from book_revenue
) 
select
book_id, 
title, 
genre, 
total_revenue
from ranked_books
where revenue_rank = 1 
order by genre;


-- 19 Identify books where stock is lower than the total quantity sold, and calculate the stock-to-sales relationship.
select 
b.book_id,
b.title ,
b.genre ,
b.stock as current_stock ,
sum(o.quantity) as total_quantity,
b.stock / sum(o.quantity) as stock_to_sales_ratio
from books b 
join orders o 
on o.book_id = b.book_id 
group by b.book_id , b.title, b.genre, b.stock
having b.stock < sum(o.quantity)
order by stock_to_sales_ratio asc ;


-- 20 Find books that have high sales but low remaining stock. Define your own business threshold and explain why those books need attention.
select 
b.book_id , 
b.title,
b.stock ,
sum(o.quantity) as total_quantity_sold,
'Needs Attention' as stock_status
from books b 
join orders o 
on o.book_id = b.book_id 
group by b.book_id , b.title, b.stock
having sum(o.quantity) >= 50
and b.stock <= 10
order by total_quantity_sold desc;


-- 21 Find the most frequently purchased genre for each customer using window functions.
with genre_purchases as (
select 
c.customer_id , 
c.name , 
b.genre , 
count(o.order_id) as purchase_count
from customers c 
join orders o 
on o.customer_id = c.customer_id
jOIN books b
on o.book_id = b.book_id
group by c.customer_id , c.name , b.genre
),
ranked_genres as (
select 
customer_id ,
name , 
genre ,
purchase_count,
rank() over(partition by customer_id order by purchase_count desc) as genre_rank
from genre_purchases
)
select customer_id ,
name,
genre,
purchase_count
from ranked_genres
where genre_rank = 1
order by customer_id ;


-- 22 Calculate yearly revenue and compare each year's revenue with the previous year using LAG(). Show the revenue growth percentage.
with yearly_revenue as
(
select 
year(str_to_date(trim(order_date), '%d-%m-%Y')) as order_year,
sum(total_amount) as total_revenue
from orders
group by year(str_to_date(trim(order_date), '%d-%m-%Y'))
),
revenue_comparison as
(
select order_year , total_revenue,
lag(total_revenue) over (order by order_year) as previous_year_revenue
from yearly_revenue
)
select 
order_year ,
total_revenue,
previous_year_revenue ,
(total_revenue - previous_year_revenue) / previous_year_revenue * 100 as revenue_growth_percentage
from revenue_comparison
order by order_year;


-- 23 Calculate the Average Order Value (AOV) for each month and identify the month with the highest AOV.
with monthly_aov as
(
select 
year(str_to_date(trim(order_date), '%d-%m-%Y')) as order_year,
month(str_to_date(trim(order_date), '%d-%m-%Y')) as order_month,
count(order_id) as total_orders ,
sum(total_amount) as total_revenue,
sum(total_amount) / count(order_id) as average_order_value
from orders
group by
year(str_to_date(trim(order_date), '%d-%m-%Y')),
month(str_to_date(trim(order_date), '%d-%m-%Y'))
)
select
order_year ,
order_month,
total_orders,
total_revenue,
average_order_value
from monthly_aov
order by average_order_value desc;


-- 24 Calculate each customer's lifetime spending, number of orders, average order value, and first/last purchase date. Rank customers by lifetime value.
with customer_lifetime as 
(
select 
c.customer_id , 
c.name ,
sum(o.total_amount) as lifetime_spending ,
count(o.order_id) as number_of_orders,
avg(o.total_amount) as average_order_value,
min(str_to_date(trim(o.order_date), '%d-%m-%Y')) as first_purchase_date ,
max(str_to_date(trim(o.order_date), '%d-%m-%Y')) as last_purchase_date 
from customers c 
join orders o 
on o.customer_id = c.customer_id
group by c.customer_id , c.name 
)
select 
customer_id 
name ,
lifetime_spending ,
number_of_orders,
average_order_value,
first_purchase_date ,
last_purchase_date,
rank() over(order by lifetime_spending desc) as lifetime_value_rank
from customer_lifetime
order by lifetime_value_rank;


-- 25 Create a single result containing major KPIs such as:
-- Total Revenue
-- Total Orders
-- Total Books Sold
-- Total Customers
-- Average Order Value
-- Best-Selling Book
-- Best-Performing Genre

with overall_kpis as
(
select
sum(total_amount) as total_revenue,
count(order_id) as total_orders,
sum(quantity) as total_books_sold,
count(distinct customer_id) as total_customers,
avg(total_amount) as average_order_value
from orders
),
best_book as 
(
select b.title as best_selling_book 
from books b
join orders o 
on o.book_id = b.book_id
group by b.book_id , b.title
order by sum(o.quantity) desc
limit 1
),
best_genre as 
(
select b.genre as best_performing_genre
from books b 
join orders o 
on o.book_id = b.book_id 
group by b.genre
order by sum(o.total_amount) desc
limit 1
)
select 
k.total_revenue,
k.total_orders,
k.total_books_sold,
k.total_customers,
k.average_order_value,
b.best_selling_book,
g.best_performing_genre
from overall_kpis k 
cross join best_book b
cross join best_genre g ;







































































