-- 90-Day Customer Lifetime Value by Cohort
-- Calculates average revenue per customer within 90 days of first order

with Delivered_orders as

(select
  customer_id,date(order_date) as order_date,net_revenue
   from  `vaulted-epigram-475613-g4.food_delivery.orders`
  where order_status = 'Delivered'
),

first_order as 
 (select customer_id,min(order_date) as first_order_date
   from Delivered_orders
  group by customer_id
 ),

customer_ltv as 
  (select d.customer_id,sum(net_revenue) as ltv_90
   from Delivered_orders d 
  join first_order f 
  using (customer_id)
where date_diff(d.order_date,f.first_order_date,DAY) BETWEEN 0 AND 90
group by d.customer_id
),

cohort_ltv as 
 (select l.customer_id,l.ltv_90,
 date_trunc(f.first_order_date,MONTH) as cohort_month
 from customer_ltv l
join first_order f
using (customer_id)
),

max_date as 
 (select max(order_date) as max_order_date
 from Delivered_orders
 )

select cohort_month,
       count(distinct customer_id) as customers,
       round(avg(ltv_90),2) as AVG_LTV_90
    from cohort_ltv,max_date
  where date_diff(max_order_date,cohort_month,DAY)>=90
  group by cohort_ltv.cohort_month
