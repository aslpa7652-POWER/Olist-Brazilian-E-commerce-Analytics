create database olist_e_commerce;
use olist_e_commerce;

select count(*) from olist;

describe olist;

select * from olist;
#   Category 1: Revenue & Sales
# total revenue

select round(sum(payment_value),2) total_revenue
from olist;
# 20187928.7

# Total Profit - jo hamne khud se estimate profit bnaya tha python me 20%

select round(sum(estimated_profit),2) total_profit
from olist;
# 2705417.96


# Average Order Value (AOV) - yani ki har product per avg kitni cost aayi hai

select round((sum(payment_value)) / count(distinct(order_id)),2) as average_order_value
from olist;

# 206.18 per product per karch hua hai 


# Year-over-Year (YoY) Growth

with yoy_growth as (
select order_purchase_year , round(sum(payment_value),2) as total_sales
from olist 
group by order_purchase_year
)
select order_purchase_year ,round(total_sales) as total_sales,
round((total_sales - lag(total_sales) over (order by order_purchase_year))/ lag(total_sales) over(order by order_purchase_year)*100 ,2) as yoy_growth
from yoy_growth;
# 2016	
# 2017	12318.94
# 2018	21.15



# yearly total revenue

select order_purchase_year, round(sum(payment_value),2) as total_revenue
from olist
group by order_purchase_year
order by total_revenue;
/*
2016	73238.88
2017	9095490.37
2018	11019199.45
*/


#monthly total revenue

select order_purchase_month, round(sum(payment_value),2) as total_revenue
from olist
group by order_purchase_month
order by total_revenue;


# Month-over-Month (MoM) Growth

with mom_growth as (
select order_purchase_year ,order_purchase_month , round(sum(payment_value),2) as total_revenue
from olist 
group by order_purchase_year ,order_purchase_month
)
select order_purchase_year ,order_purchase_month , round(total_revenue) as total_revenue,
round((total_revenue - lag(total_revenue) over (order by order_purchase_year ,order_purchase_month))/ lag(total_revenue) over (order by order_purchase_year ,order_purchase_month)*100 , 2) as growth
from mom_growth;


select * from olist;

# total discount

select round(sum(distcount_amount)) as total_discount
from olist ;
# 117

# best performance month

select order_purchase_year,order_purchase_month , round(sum(payment_value),2) as total_sales
from olist
group by order_purchase_year,order_purchase_month
order by total_sales desc;

# 2017 ke nov(11) month me 1579407.32  sabse jyada sales hui hai isliye best month hua

#  8  How do Weekend sales compare to Weekday sales (log chhutti ke din zyada khareedari karte hain ya working days par)

select 
      case
          when dayname(order_purchase_dates) in ("saturday","sunday") then "weekend"
          else "weekday"
	  end as day_type,
      round(sum(payment_value),2) as total_sales
from olist
group by day_type
order by total_sales desc;

# yha hamare pass weekdays me sabse jyada revenue ho rha hai
/*
weekday	15780692.04
weekend	4407236.66
*/

/*
9. What is the Average Revenue Per User (ARPU)(Ek unique customer life-time me average kitna revenue deta hai?)
*/
select round(sum(payment_value) / count(distinct(customer_id)),2) as ARPU
from olist;
# ARPU 206.18
# 10. What is the Discount to Revenue Ratio (Total revenue ka kitna percentage hissa discount me chala gaya?)

select round(sum(distcount_amount) / sum(payment_value)*100 , 2) as discount_to_revinew_ratio
from olist;

# Category 2: Product & Category Analytics

# 11 What are the Top 10 categories by revenue

select product_category_name , round(sum(payment_value),2) as total_revenue
from olist
group by product_category_name
order by total_revenue desc
limit 10;
# 12. What are the Top 10 categories by sales volume (quantity) (Wo products jo saste ho sakte hain par sabse zyada quantity me bik rahe hain?)
select product_category_name , count(order_item_id) as total_item_sold
from olist
group by product_category_name
order by total_item_sold desc
limit 10;

# 13. What are the Top 10 most profitable categories (Kin categories me profit margin sabse zyada nikla?)

select product_category_name , round(sum(estimated_profit),2) as total_profit
from olist
group by product_category_name
order by total_profit desc
limit 10;
# beleza_saude	250453.98 sabse jyada profit de rha hai 

# 14. What are the Bottom 5 worst-performing categories by revenue (Wo products jo bilkul nahi bik rahe aur unhe stock se hatana chahiye)
select product_category_name, round(sum(payment_value),2) as total_revenue
from olist
group by product_category_name
order by total_revenue 
limit 5 ;


# 15 Which categories receive the highest amount of discount(Kis category me product bechne ke liye sabse zyada discount dena padta hai)

select product_category_name , round(sum(distcount_amount),2) as total_discount
from olist
group by product_category_name
order by total_discount desc
limit 5;

# 16. What is the average number of items purchased per order (Log ek baar me average kitne items order karte hain)

select round(count(order_item_id)/count(distinct(order_id)),2) as avg_item_per_order
from olist ;

# 1.15
# 17. What are the top 5 highest-rated product categories(Kis category ke products ko average sabse zyada 5-star rating mili hai)

SELECT product_category_name, ROUND(AVG(review_score), 2) AS avg_rating
FROM olist
GROUP BY product_category_name
ORDER BY avg_rating DESC
LIMIT 5;
# 18. What are the bottom 5 worst-rated product categories(Kis category me sabse zyada 1-star reviews aaye hain)
select product_category_name , round(avg(review_score),2) as avg_rating
from olist
group by product_category_name
order by avg_rating 
limit 5;

# 19. How does average price compare with total sales volume for top categories(Kya saste products zyada bikte hain, ya mehange products bhi barabar bik rahe hain)
select product_category_name, round(avg(price),2) as avg_price , count(order_id) as total_order
from olist
group by product_category_name
order by total_order desc
limit 10;

# 20. Which categories have the highest average freight (shipping) cost (Kis category ke products ko bhejney me sabse zyada shipping cost lagti hai)

select product_category_name , round(avg(freight_value),2) as avg_freight_value
from olist  
group by product_category_name
order by avg_freight_value desc
limit 10;



# Category 3: Customer & Geographical Insights

# 21. What are the Top 5 States by Customer Count (Company ke sabse zyada customers kis state se hain)

select customer_state , count(distinct(customer_unique_id)) as total_customer
from olist 
group by customer_state
order by total_customer desc
limit 5;

/*
SP	39727
RJ	12153
MG	11106
RS	5230
PR	4816
*/

# 22. What are the Top 10 Cities by Revenue

select customer_city, round(sum(payment_value),2) as total_revenue
from olist
group by customer_city
order by total_revenue desc
limit 10;

#24. What is the Average Order Value (AOV) by State (Kis state ke log ek order me average sabse zyada paise kharch karte hain)

select customer_state , round(sum(payment_value) / count(distinct(order_id)),2) as average_order_value
from olist 
group by customer_state
order by average_order_value desc;

# 25. Which State generates the highest total profit(Total Revenue nahi, balki Total Profit kis state se sabse zyada hai)

select customer_state , round(sum(estimated_profit),2) as total_profit
from olist 
group by customer_state
order by total_profit desc;

# 26. Which State has the highest number of canceled orders (Kis area se sabse zyada orders cancel hote hain)

select customer_state ,count(order_status) as total_cancel_order
from olist 
where order_status ="canceled"
group by customer_state
order by total_cancel_order desc;

# SP	287

# 27. What is the Average Satisfaction Score (Review Rating) by State (Kis state ke log sabse zyada khush hain)

select customer_state , round(avg(review_score),2) as avg_satisfaction
from olist
group by customer_state
order by avg_satisfaction desc;

# AP	4.22 ke sabse jyada kush hai 

# 28. Which Cities utilize the highest total discount (Kis city me sabse zyada discount wale vouchers use hote hain)

select customer_city , round(sum(distcount_amount),2) as total_discount
from olist 
group by customer_city
order by total_discount desc
limit 5;

/*
sao paulo	24.3
macae	16.5
cacapava	14.99
curitiba	14.95
jundiai	10.39
*/

# 29. Who are the Top 10 VIP Customers based on total spend (Wo unique customers jinhone aaj tak sabse zyada paise kharch kiye hain)

select customer_unique_id , round(sum(payment_value),2) as total_spend
from olist
group by cutomer_unique_id
order by total_spend desc
limit 10;

# 30. What are the lowest-performing states by revenue (Wo states jahan revenue sabse kam hai aur marketing push ki zaroorat hai)

select customer_state, round(sum(payment_value),2) as total_revenue
from olist 
group by customer_state
order by total_revenue asc
limit 5;
/*
RR	12462.21
AP	21572.32
AC	24984.86
AM	34567.86
RO	65836.95
*/

# Category 4: Logistics, Delivery & Customer Satisfaction

# 31. What is the average delivery time in days (Order khareedne se lekar customer tak pahunchne me average kitne din lagte hain)

select round(avg(datediff(order_delivered_date, order_purchase_dates)),1) as avg_delivery_time_in_days
from olist 
where order_delivered_date is not null;
# 12.4 days lag rhe hai 

# 32. What is the average shipping dispatch time (Order place hone ke baad seller item ship/dispatch karne me kitna time leta hai)

select round(avg(datediff(order_shipping_dates, order_purchase_dates)),2) as shipping_dispatch_time
from olist 
where order_shipping_dates is not null;

# 6.74 din lag rhe hai

# 33. Which states have the fastest average delivery time (Kin states me logistics best hai aur delivery sabse jaldi hoti hai)


select customer_state , round(avg(datediff(order_delivered_date , order_purchase_dates)),2) as total_avg_dlvry_time
from olist 
group by customer_state
order by total_avg_dlvry_time 
limit 5;

-- sabse fast sp state ka hai jisme 8.73 days lag rhehai 

-- 34. Which states have the slowest average delivery time (Kin states me logistics bahut kharab hai aur delivery late hoti hai)

select customer_state , avg(datediff(order_delivered_date,order_purchase_dates)) as slowest_order_time
from olist 
where order_delivered_date is not null
group by customer_state
order by slowest_order_time desc
limit 5;
-- ap me sabse jyada din lag rhe hia order ko cutomer taq phuchne me lagbug 28 din 

-- 35. How does delivery time affect the review score (Kya late delivery hone par customer hamesha kam rating deta hai)

select review_score , round(avg(datediff(order_delivered_date,order_purchase_dates)),2) order_time
from olist 
where order_delivered_date is not null
group by review_score
order by order_time 
limit 5;

-- ha ager order customer taq late phuch rha hai to cutomer review krabh de rhe hai 

# 36. What is the overall average customer rating

select round(avg(review_score),2) as overall_rating
from olist ;

-- overall rating 4.03 aa rhi hai



select * from olist
limit 5;


