{{ config(
    materialized='incremental',
    unique_key='order_hk',
    cluster_by=['order_hk']
) }}

WITH source_data AS (
    SELECT 
        order_hk,
        order_line_hk, 
        order_line_id,
        order_id,
        load_ts,
        'Snowflake' as record_source
    FROM {{ ref('stg_orders') }}
)

SELECT DISTINCT
    order_hk,
    order_id,
    order_line_hk, 
    order_line_id, 
    load_ts,
    record_source
FROM source_data

{% if is_incremental() %}
    -- W trybie inkrementalnym ładujemy tylko nowe klucze biznesowe
    WHERE order_hk NOT IN (SELECT order_hk FROM {{ this }})
{% endif %}