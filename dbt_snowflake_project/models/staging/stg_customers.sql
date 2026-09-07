select 
    src.customerid as customer_id, 
    src.FIRSTNAME as firstname, 
    src.LASTNAME as lastname, 
    src.EMAIL as email, 
    src.PHONE as phone_number, 
    src.ADDRESS as adress, 
    src.CITY as city, 
    src.STATE as state, 
    src.ZIPCODE as zipcode, 
    src.UPDATED_AT as updated_at,
    {{dbt_utils.generate_surrogate_key(['src.customerid'])}} as customer_hk, 
    CURRENT_TIMESTAMP() as load_ts,
    'SLEEKDATA' as record_source
from {{source('sleekdata','CUSTOMERS')}} src