{% test not_negative(model, column_name, lesser_column_name) -%}

-- Test to check if any value break business rules.
-- Check is column is greater than other column.
with validation as (
    select
        {{ column_name }} as column_name,
        {{ lesser_column_name}} as lesser_column_name
    from {{ model }}
)

select
    {{ column_name }} as column_name,
    {{ lesser_column_name}} as lesser_column_name
from {{ model }}
where {{ column_name }} > {{ lesser_column_name}} 
{%- endtest %}