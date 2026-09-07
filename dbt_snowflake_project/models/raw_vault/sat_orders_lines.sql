{{ config(
    materialized='incremental'
) }}

WITH source_data AS (
    SELECT 
        order_hk,
        order_line_hk,
        order_sat_hash_diff AS hash_diff,
        order_status,
        order_date,
        unit_price, 
        quantity, 
        load_ts,
        record_source
    FROM {{ ref('stg_orders') }}
)

SELECT 
    s.order_hk,
    s.order_line_hk,
    s.hash_diff,
    s.order_status,
    s.order_date,
    s.unit_price,
    s.quantity,
    s.load_ts,
    s.record_source
FROM source_data s

{% if is_incremental() %}
    -- Wygrywanie zmian: wstawiamy rekord tylko jeśli nie istnieje 
    -- lub jeśli zmieniono dane kontekstowe (inny hash_diff od ostatnio opublikowanego)
    LEFT JOIN (
        SELECT order_hk, hash_diff
        FROM {{ this }}
        QUALIFY ROW_NUMBER() OVER (PARTITION BY order_hk ORDER BY load_ts DESC) = 1
    ) current_sat 
    ON s.order_hk = current_sat.order_hk
    WHERE current_sat.order_hk IS NULL 
       OR s.hash_diff != current_sat.hash_diff
{% endif %}