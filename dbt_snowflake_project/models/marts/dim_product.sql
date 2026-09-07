{{config(materialized = 'view')}}

with latest_product as (
   -- Just only actual products from satelite
    select 
        product_hk,
        product_name, 
        product_category,
        retail_price,
        supplier_price
    from {{ ref('sat_products') }}
    qualify ROW_NUMBER() OVER (PARTITION BY product_hk ORDER BY load_ts DESC) = 1
),

select 
    hb.product_hk,
    hb.product_id,
    lp.product_name, 
    lp.product_category, 
    lp.retail_price, 
    lp.supplier_price
from {{ref('hub_product')}} hb 
inner join latest_product lp ON lp.product_hk = hb.product_hk 
