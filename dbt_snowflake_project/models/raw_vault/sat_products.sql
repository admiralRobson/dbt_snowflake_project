{{
    config(
        materialized = 'incremental'
    )
}}

WITH source_data AS (
    SELECT 
        product_hk,
        product_hash_diff AS hash_diff,
        name as product_name,
        category as product_category,
        RETAILPRICE as retail_price, 
        SUPPLIERPRICE as supplier_price,
        load_ts,
        record_source
    FROM {{ ref('stg_products') }}
)
select 
    s.product_hk, 
    s.hash_diff,
    s.product_name, 
    s.product_category, 
    s.retail_price, 
    s.supplier_price, 
    s.load_ts, 
    s.record_source
from source_data s
{% if is_incremental() -%}
    -- Wygrywanie zmian: wstawiamy rekord tylko jeśli nie istnieje 
    -- lub jeśli zmieniono dane kontekstowe (inny hash_diff od ostatnio opublikowanego)
    LEFT JOIN (
        SELECT product_hk, hash_diff
        FROM {{ this }}
        QUALIFY ROW_NUMBER() OVER (PARTITION BY product_hk ORDER BY load_ts DESC) = 1
    ) current_sat 
    ON s.product_hk = current_sat.product_hk
    WHERE current_sat.product_hk IS NULL 
       OR s.hash_diff != current_sat.hash_diff
{%- endif %}

