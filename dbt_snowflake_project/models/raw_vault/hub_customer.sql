{{ config(
    materialized='incremental',
    unique_key='customer_hk'
) }}

with staging_data as (
    select 
        stg.customer_id, 
        stg.customer_hk, 
        stg.load_ts, 
        stg.record_source
    from {{ref('stg_customers')}} stg
)
select distinct
    sd.customer_id, 
    sd.customer_hk, 
    sd.load_ts, 
    sd.record_source
from staging_data sd
{% if is_incremental() -%}
    -- W trybie inkrementalnym ładujemy tylko nowe klucze biznesowe
    WHERE customer_hk NOT IN (SELECT customer_hk FROM {{ this }})
{%- endif %}

