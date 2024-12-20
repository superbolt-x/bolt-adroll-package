{{ config (
    alias = target.database + '_adroll_performance_by_campaign'
)}}

{%- set date_granularity_list = ['day','week','month','quarter','year'] -%}
{%- set exclude_fields = ['date','day','week','month','quarter','year','last_updated','unique_key','kpi_metric','source','kpi_currency','kpi_goal'] -%}
{%- set dimensions = ['account_id','account_name','campaign_id','campaign_name','campaign_status','campaign_type','campaign_budget'] -%}
{%- set measures = adapter.get_columns_in_relation(ref('adroll_campaigns_insights'))
                    |map(attribute="name")
                    |reject("in",exclude_fields)
                    |reject("in",dimensions)
                    |list
                    -%}  

WITH 
    {%- for date_granularity in date_granularity_list %}

    performance_{{date_granularity}} AS 
    (SELECT 
        '{{date_granularity}}' as date_granularity,
        {{date_granularity}} as date,
        {%- for dimension in dimensions %}
        {{ dimension }},
        {%- endfor %}
        {% for measure in measures -%}
        COALESCE(SUM("{{ measure }}"),0) as "{{ measure }}"
        {%- if not loop.last %},{%- endif %}
        {% endfor %}
    FROM {{ ref('adroll_campaigns_insights') }}
    GROUP BY {{ range(1, dimensions|length +2 +1)|list|join(',') }})
    {%- if not loop.last %},{%- endif %}
    {%- endfor %}

SELECT *
FROM 
    ({% for date_granularity in date_granularity_list -%}
    SELECT *
    FROM performance_{{date_granularity}}
    {% if not loop.last %}UNION ALL
    {% endif %}
    {%- endfor %}
    )
