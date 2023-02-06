{%- macro create_description_model(
    resource_type=['model']
    , show_resource_type=True
    , resource_path_contains=[]
    , exclude_resource_path_contains=[]
) -%}

    {%- if execute -%}

        {%- set rows_list = metalog.get_rows(resource_type, resource_path_contains, exclude_resource_path_contains) -%}

        {%- if rows_list | length == 0 -%}

            {{ exceptions.raise_compiler_error("No description found for the provided parameters\nPlease check the descriptions of your resources") }}

        {%- endif -%}

        {%- for row in rows_list -%}

            select '{{ row[0] }}' as resource_name

            {%- if show_resource_type -%}
                , '{{ row[1] }}' as resource_type
            {%- endif -%}
                , '{{ row[2] }}' as resource_description
                , '{{ row[3] }}' as column_name
                , '{{ row[4] }}' as columns_description
            {% if not loop.last %}
                union all
            {% endif %}

        {%- endfor -%}

    {%- endif -%}

{%- endmacro -%}


{%- macro get_rows(
    resource_type_list
    , resource_path_contains_list
    , exclude_resource_path_contains_list
) -%}

    {%- set rows_list = [] -%}

    {%- for node in graph.nodes.values() if node.resource_type in resource_type_list -%}

        {# 'Check if node is in the provided resource_path_contains' #}
        {%- set contains_resource_path = [] -%}
        {%- if resource_path_contains_list -%}
            {%- for item in resource_path_contains_list if item in node.original_file_path -%}
                {%- if exclude_resource_path_contains_list -%}
                    {%- for item_exclude in exclude_resource_path_contains_list if not item_exclude in node.original_file_path -%}
                        {{ contains_resource_path.append(1) }}
                    {%- endfor -%}
                {%- else -%}
                    {{ contains_resource_path.append(1) }}
                {%- endif -%}
            {%- endfor -%}
        {%- else -%}
            {{ contains_resource_path.append(1) }}
        {%- endif -%}

        {%- if contains_resource_path -%}

            {%- for column in node.columns.values() -%}

                {%- set node_columns_list = [] -%}
                {{ node_columns_list.append(node.unique_id.split('.')[2]) }}
                {{ node_columns_list.append(node.resource_type) }}
                {{ node_columns_list.append(node.description) }}
                {{ node_columns_list.append(column.name) }}
                {{ node_columns_list.append(column.description) }}

                {{ rows_list.append(node_columns_list) }}

            {%- endfor -%}

        {%- endif -%}

    {%- endfor -%}

    {%- for source in graph.sources.values() if 'source' in resource_type_list -%}

        {# 'Check if source is in the provided resource_path_contains' #}
        {%- set contains_resource_path = [] -%}
        {%- if resource_path_contains_list -%}
            {%- for item in resource_path_contains_list if item in source.original_file_path -%}
                {%- if exclude_resource_path_contains_list -%}
                    {%- for item_exclude in exclude_resource_path_contains_list if not item_exclude in source.original_file_path -%}
                        {{ contains_resource_path.append(1) }}
                    {%- endfor -%}
                {%- else -%}
                    {{ contains_resource_path.append(1) }}
                {%- endif -%}
            {%- endfor -%}
        {%- else -%}
            {{ contains_resource_path.append(1) }}
        {%- endif -%}

        {%- if contains_resource_path -%}

            {%- for column in source.columns.values() -%}

                {%- set source_columns_list = [] -%}
                {{ source_columns_list.append(source.unique_id.split('.')[2]) }}
                {{ source_columns_list.append(source.resource_type) }}
                {{ source_columns_list.append(source.description) }}
                {{ source_columns_list.append(column.name) }}
                {{ source_columns_list.append(column.description) }}

                {{ rows_list.append(source_columns_list) }}

            {%- endfor -%}

        {%- endif -%}

    {%- endfor -%}

    {{ return(rows_list) }}

{%- endmacro -%}