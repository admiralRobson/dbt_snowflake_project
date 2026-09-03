{{config(materialized = 'view')}}

WITH latest_order_sat AS (
    -- Just only actual order lines from satelite
    SELECT 
        order_hk,
        order_line_hk, 
        order_status,
        order_date,
        unit_price, 
        quantity
    FROM {{ ref('sat_orders_lines') }}
    QUALIFY ROW_NUMBER() OVER (PARTITION BY order_line_hk ORDER BY load_ts DESC) = 1
)

SELECT 
    h_ord.order_id,
    h_cust.customer_id,
    h_prod.product_id,
    so_sat.order_status,
    so_sat.order_date,
    so_sat.quantity,
    so_sat.unit_price,
    (so_sat.quantity * so_sat.unit_price) AS total_amount
FROM {{ ref('link_order_line') }} lnk
JOIN {{ ref('hub_order_lines') }} h_ord ON lnk.order_hk = h_ord.order_hk
JOIN {{ ref('hub_customer') }} h_cust ON lnk.customer_hk = h_cust.customer_hk
JOIN {{ ref('hub_product') }} h_prod ON lnk.product_hk = h_prod.product_hk
LEFT JOIN latest_order_sat so_sat ON lnk.order_hk = so_sat.order_hk
