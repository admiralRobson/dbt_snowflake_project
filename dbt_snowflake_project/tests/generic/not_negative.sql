{% test not_negative(model, column_name, min_value = 0) -%}

-- Test to check if any value break business rules.
-- Check min_value, default equals 0.
with validation as (
    select
        {{ column_name }} as validate_column
    from {{ model }}
)

select
    validate_column
from validation
where validate_column < {{ min_value }}
   
{%- endtest %}