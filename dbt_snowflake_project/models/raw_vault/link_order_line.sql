
{{ config(
    materialized='incremental',
    unique_key='link_order_line_hk'
) }}

WITH source_data AS (
    SELECT 
        link_order_line_hk,
        order_line_hk,
        order_hk,
        customer_hk,
        product_hk,
        employee_hk,
        store_hk,
        load_ts,
        record_source
    FROM {{ ref('stg_orders') }}
)

SELECT DISTINCT
        link_order_line_hk,
        order_line_hk,
        order_hk,
        customer_hk,
        product_hk,
        employee_hk,
        store_hk,
        load_ts,
        record_source
FROM source_data

{% if is_incremental() %}
    WHERE link_order_line_hk NOT IN (SELECT link_order_line_hk FROM {{ this }})
{% endif %}
