-- 1 question to display product name in BOGOF with base price more than 500
SELECT E.product_code, product_name, base_price, E.promo_type FROM retail_events_db.fact_events E
Left Join retail_events_db.dim_products P on P.product_code = E.product_code
where base_price>500 and promo_type='BOGOF';

-- 2 question to display city wise store count in desc order
SELECT S.city, Count(S.store_id) as Store_count FROM retail_events_db.fact_events E
Left Join retail_events_db.dim_stores S on S.store_id = E.store_id
Group by S.city
order by Store_count desc;


-- 3 Question write query to display total revenue before and after campaign
SELECT distinct(C.campaign_name) as Campaign, 
concat(round(sum(e.base_price * E.`quantity_sold(before_promo)`)/1000000,2),' ', 'M') as total_revenue_before,
concat(round(sum(e.base_price * E.`quantity_sold(after_promo)`)/1000000,2),' ', 'M') as total_revenue_after
FROM retail_events_db.fact_events E
Left Join retail_events_db.dim_campaigns C on E.campaign_id = C.campaign_id
group by campaign
order by campaign asc;

-- 4 Question calculate ISQ% for each product category in Diwali sales and rank as per ISQ% for product category
SELECT P.category,
((sum(E.`quantity_sold(after_promo)`) - sum(E.`quantity_sold(before_promo)`))/sum(E.`quantity_sold(before_promo)`))*100 As ISQ_percentage,
Rank()
OVER (ORDER BY ((sum(E.`quantity_sold(after_promo)`) - sum(E.`quantity_sold(before_promo)`))/sum(E.`quantity_sold(before_promo)`)*100) desc) As Rank_order
FROM retail_events_db.fact_events E
left join retail_events_db.dim_products P on P.product_code = E.product_code
-- left join retail_events_db.dim_campaigns C on E.campaign_id = C.campaign_id (this would take memory)
-- where C.campaign_name = 'Diwali'
where E.campaign_id = 'CAMP_DIW_01'
group by P.category
order by ISQ_percentage desc;

-- 5 Question top 5 producst ranked as per IR% across all caompaigns

SELECT P.product_name, P.category,

round((
		(sum(e.base_price * E.`quantity_sold(after_promo)`) - sum(e.base_price * E.`quantity_sold(before_promo)`))/
		sum(e.base_price * E.`quantity_sold(before_promo)`)
        )*100,2) as IR_Percentage
FROM fact_events E
left join dim_products P on P.product_code = E.product_code
group by P.product_name, P.category
order by IR_percentage desc
Limit 5;



