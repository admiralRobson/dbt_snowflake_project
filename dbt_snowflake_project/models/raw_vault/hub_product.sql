{{ config(
    materialized='incremental',
    unique_key='product_hk'
) }}

with staging_data as (
    select 
        product_id, 
        product_hk, 
        load_ts, 
        record_source
    from {{ref('stg_products')}}
)
select 
    distinct
        product_hk, 
        product_id, 
        load_ts, 
        record_source
from staging_data
{% if is_incremental() %}
    -- W trybie inkrementalnym ładujemy tylko nowe klucze biznesowe
    WHERE product_hk NOT IN (SELECT product_hk FROM {{ this }})
{% endif %}

