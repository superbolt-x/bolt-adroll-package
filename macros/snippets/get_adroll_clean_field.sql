{%- macro get_adroll_clean_field(table_name, column_name) %}
    {%- if table_name == 'adroll_insights' -%}
        {%- if column_name == 'eid' -%}
        {{column_name}} as campaign_id

        {%- elif column_name == 'cost' -%}
        {{column_name}} as spend

        {%- elif '_throughs' in column_name -%}
        {{column_name}} as {{column_name|replace('_throughs','_through_conversions')}}

         {%- elif column_name in ('click_revenue','view_revenue') -%}
        {{column_name}} as {{column_name|replace('_revenue','_through_revenue')}}

        {%- elif column_name in ('type','name','status','budget') -%}
        {{column_name}} as campaign_{{column_name}}

        {%- elif column_name == 'advertisable' -%}
        {{column_name}} as account_id

        {%- elif column_name == 'advertisable_name' -%}
        {{column_name}} as account_name

        {%- else -%}
        {{column_name}}
        
        {%- endif -%}

    {%- else -%}
    
       {{column_name}}

    {%- endif -%}

{% endmacro -%}
