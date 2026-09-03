select 
    *, 
    {{dbt_utils.generate_surrogate_key(['src.storeid'])}} as store_hk,
    current_timestamp() as load_ts, 
    'Snowflake' as report_source
from {{source('sleekdata','STORES')}} src