with orders as (
    select 
        * 
    from {{source('sleekdata','ORDERS')}}
), 
orderitems as (
    select 
        * 
    from {{source('sleekdata', 'ORDERITEMS')}}
)
-- orderitems (orderlines)
-- PK (orderid + orderitemid)
-- FK (customerid, employeeid, storeid)
select
    -- bsuiness_keys
    sol.orderid as order_id, -- PK
    concat_ws('|', sol.orderid, sol.orderitemid) as order_line_id, 
    sol.productid as product_id,
    soh.customerid as customer_id, 
    soh.employeeid as employee_id, 
    soh.storeid as store_id,
    
    -- MD5 HashKeys
    {{ dbt_utils.generate_surrogate_key(['sol.orderid', 'sol.orderitemid'])}} as order_line_hk,
    {{ dbt_utils.generate_surrogate_key(['soh.orderid'])}} as order_hk,
    {{ dbt_utils.generate_surrogate_key(['soh.customerid'])}} as customer_hk,
    {{ dbt_utils.generate_surrogate_key(['sol.productid'])}} as product_hk,
    {{ dbt_utils.generate_surrogate_key(['soh.employeeid'])}} as employee_hk,
    {{ dbt_utils.generate_surrogate_key(['soh.storeid'])}} as store_hk,
    -- LINK KEY
    {{ dbt_utils.generate_surrogate_key(['sol.orderid', 'sol.orderitemid','soh.customerid','soh.employeeid', 'soh.storeid', 'sup.supplierid'])}} as link_order_line_hk, 
    -- CHECK STATUS OF ORDERS
    {{dbt_utils.generate_surrogate_key(['soh.orderdate', 'soh.status'])}} as order_sat_hash_diff, 
    -- Attributes
    soh.orderdate as order_date, 
    soh.status as order_status,
    sol.updated_at,
    sol.unitprice as unit_price, -- unitprice
    sol.quantity, -- quantity
    current_timestamp() as load_ts, 
    'Snowflake' as record_source
from L1_LANDING.ORDERITEMS sol
join L1_LANDING.ORDERS soh on sol.orderid = soh.orderid
join L1_LANDING.SUPPLIERS sup on sol.productid = sup.supplierid

