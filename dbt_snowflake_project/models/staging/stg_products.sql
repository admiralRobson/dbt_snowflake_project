select 
    *,
    src.productid as product_id,
    {{ dbt_utils.generate_surrogate_key(['src.productid',''src.''])}} as product_hk,
    {{ dbt_utils.generate_surrogate_key(['src.productid' , 'src.retailprice','src.supplierprice'])}} as product_hash_diff,
    CURRENT_TIMESTAMP() as load_ts,
    'Snowflake' as record_source
from {{source('sleekdata','PRODUCTS')}} src