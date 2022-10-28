{{ config( 
        materialized='incremental',
        unique_key='unique_key'
) }}

{%- set schema_name, table_name = 'adroll_raw', 'adroll_insights' -%}

{%- set exclude_fields = [
   "created_date",
   "start_date",
   "updated_date",
   "channel",
   "currency"
]
-%}

{%- set fields = adapter.get_columns_in_relation(source(schema_name, table_name))
                    |map(attribute="name")
                    |reject("in",exclude_fields)
                    -%}  

WITH insights AS 
    (SELECT 
        {%- for field in fields %}
        {{ get_adroll_clean_field(table_name, field) }}
        {%- if not loop.last %},{%- endif %}
        {%- endfor %}
    FROM {{ source(schema_name, table_name) }}
    )

SELECT *,
    MAX(_fivetran_synced) over () as last_updated,
    campaign_id||'_'||date as unique_key
FROM insights
{% if is_incremental() -%}

  -- this filter will only be applied on an incremental run
where date >= (select max(date)-30 from {{ this }})

{% endif %}
