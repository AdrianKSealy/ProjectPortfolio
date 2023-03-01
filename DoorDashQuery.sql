--Cleaning data in SQL querries
Select *
From DoorDash

--Uppercase in store_primary_category
Select store_primary_category, Upper(Left(store_primary_category,1))+ SUBSTRING(store_primary_category,2, len(store_primary_category))
From DoorDash

Update DoorDash
Set store_primary_category =Upper(Left(store_primary_category,1))+ SUBSTRING(store_primary_category,2, len(store_primary_category))

--Changing all Null to NA (Not Available)
Select *
From DoorDash
Where  market_id is null

Update DoorDash
Set total_onshift_dashers = ISNULL(total_onshift_dashers, 0)

Update DoorDash
Set total_busy_dashers = ISNULL(total_busy_dashers, 0)

Update DoorDash
Set total_outstanding_orders = ISNULL(total_outstanding_orders,0)
 
Update DoorDash
Set market_id = ISNULL(Str(market_id),'NA')

--Backup query to complete the cleaning of data
Select market_id, ISNULL(Convert(varchar,market_id),'NA') as market_id, ISNULL(Convert(varchar,order_protocol),'NA') as order_protocol
From DoorDash

--Changing the subtotal,min_item_price and max_item price to dollars
Update DoorDash
 Set subtotal_dollars = CAST(subtotal_dollars / 100 as DECIMAL(10,2))
 
Update DoorDash
 Set min_item_price_dollars = CAST(min_item_price_dollars/ 100 as DECIMAL(10,2))
 
Update DoorDash
 Set max_item_price_dollars = CAST(max_item_price_dollars/ 100 as DECIMAL(10,2))

 --Changing estimated order place and consumer driving duration to mintues

Update DoorDash
Set estimated_order_place_duration_min = FLOOR(estimated_order_place_duration_min/60)

Update DoorDash
 Set estimated_store_to_consumer_driving_duration_min = FLOOR(estimated_store_to_consumer_driving_duration_min/60)
 

-- Looking at distinct stores by Store_id, Market_id, store_primary_category
Select distinct count(Distinct(store_id)) AS Dist_Stores
From DoorDash

Select distinct ISNULL(Convert(varchar,market_id),'NA') as market_id,Count(Distinct(store_id)) As Dist_Stores 
From dbo.DoorDash
Group by market_id
order by market_id 

Select ISNULL(Convert(varchar,order_protocol),'NA') as order_protocol,Count(Distinct(store_id)) As Dist_Stores
From dbo.DoorDash
Group by order_protocol
order by order_protocol

Select distinct store_primary_category
From dbo.DoorDash

--Range of the data
Select Top 1 Datediff(WEEK,'2015/01/21', '2015/02/18') as Weeks,Datediff(DAY,'2015/01/21', '2015/02/18') as Days
From DoorDash

--Amount of money generated in each market , order protocol, Store primary category
Select Cast(Sum(subtotal_dollars) as Decimal(10,0)) as money_gen 
From dbo.DoorDash

Select ISNULL(Convert(varchar,market_id),'NA') as market_id,Cast(Sum(subtotal_dollars) as Decimal(10,2)) as money_gen,  Cast(Avg(subtotal_dollars)as decimal(10,2)) as avg_money_spent,Concat(Convert(float,Count(subtotal_dollars)*100)/197428,'%')  as market_percent 
From dbo.DoorDash
Group by market_id
Order by money_gen desc

Select ISNULL(Convert(varchar,order_protocol),'NA') as order_protocol, Cast(Sum(subtotal_dollars) as Decimal(10,2)) as money_gen,  Cast(Avg(subtotal_dollars) as decimal(10,2)) as avg_money_spent, Concat(Convert(float,Count(subtotal_dollars)*100)/197428,'%')   as market_percent 
From dbo.DoorDash
Group by order_protocol
Order by money_gen desc

Select  store_primary_category, Cast(Sum(subtotal_dollars) as Decimal(10,2)) as money_gen,  Cast(Avg(subtotal_dollars)as DECIMAL(10, 2))   as avg_money_spent,Concat(Convert(float,Count(subtotal_dollars)*100)/197428,'%')  as market_percent 
From dbo.DoorDash
Group by store_primary_category
Order by money_gen desc

--Looking at the Average amount of dashers By market_id
Select ISNULL(Convert(varchar,market_id),'NA') as market_id, Cast(Avg(total_onshift_dashers)as decimal(10,0)) As Avg_onshift_das , Cast(Avg(total_busy_dashers)As decimal(10,0)) As Avg_busy_das, Cast(Avg(total_outstanding_orders)as decimal(10,0)) As Avg_outstanding_ord
From dbo.DoorDash
Group by market_id
Order by Avg_onshift_das desc

--Finding the outliers for delivery_duration
WITH CTE_Times AS (
Select ISNULL(Convert(varchar,market_id),'NA') as market_id,created_at,actual_delivery_time, datediff(MINUTE, created_at,  actual_delivery_time)As delivery_duration
From DoorDash
Where not actual_delivery_time is null
),
CTE_Outlier AS (
Select delivery_duration, AVG(delivery_duration) OVER() as Mean, STDEV(delivery_duration) OVER() AS StandardDeviation
From CTE_Times
),
CTE_ZScore AS (
Select delivery_duration, (delivery_duration - Mean) / StandardDeviation AS ZScore
FROM CTE_Outlier
)
Select delivery_duration
From CTE_ZScore
Where ABS(ZScore) > 2
order by delivery_duration desc

--Getting the AVG amount of minute for delivery without outliers

--market_id
WITH CTE_MarketTimes AS (
Select ISNULL(Convert(varchar,market_id),'NA') as market_id,created_at,actual_delivery_time, datediff(MINUTE, created_at,  actual_delivery_time)As delivery_duration
From DoorDash
Where not actual_delivery_time is null 

)
Select market_id,created_at,actual_delivery_time, delivery_duration, AVG(delivery_duration) OVER()  as MEAN
From CTE_MarketTimes
Where delivery_duration < 726
order by market_id

--Protocol
WITH CTE_Protocol_Times AS (
Select  ISNULL(Convert(varchar,order_protocol),'NA') as order_protocol,created_at,actual_delivery_time, datediff(MINUTE, created_at,  actual_delivery_time)As delivery_duration
From DoorDash
Where not actual_delivery_time is null 
)
Select order_protocol,created_at,actual_delivery_time,delivery_duration, AVG(delivery_duration) OVER()  as MEAN
From CTE_Protocol_Times
Where delivery_duration < 726
Order by order_protocol

--Store_primary_category
WITH CTE_Store_Times AS (
Select  store_primary_category,created_at,actual_delivery_time, datediff(MINUTE, created_at,  actual_delivery_time)As delivery_duration
From DoorDash
Where not actual_delivery_time is null 
)
Select store_primary_category,created_at,actual_delivery_time,delivery_duration, AVG(delivery_duration) OVER()  as MEAN
From CTE_Store_Times
Where delivery_duration < 726
Order by store_primary_category

--Creating a table for a summary in tableau
WITH CTE_Summary AS (
Select total_items,store_id,ISNULL(Convert(varchar,order_protocol),'NA') as order_protocol, ISNULL(Convert(varchar,market_id),'NA') as market_id,store_primary_category,created_at,actual_delivery_time, datediff(MINUTE, created_at,  actual_delivery_time)As delivery_duration
From DoorDash
Where not actual_delivery_time is null 
)
Select ISNULL(Convert(varchar,market_id),'NA') as market_id,ISNULL(Convert(varchar,order_protocol),'NA') as order_protocol, store_id, store_primary_category,total_items,delivery_duration, AVG(delivery_duration) OVER()  as overall_mean
From CTE_Summary
Where delivery_duration < 726


Select *
From DoorDash







