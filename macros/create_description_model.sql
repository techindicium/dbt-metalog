{%- macro create_description_model(
    resource_type=['model']
    , show_resource_type=True
    , files=[]
    , exclude_files=[]
) -%}

    {%- if execute -%}

        {%- set rows_list = metalog.get_rows(resource_type, files, exclude_files) -%}

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
    , files_list
    , exclude_files_list
) -%}

    {% set re = modules.re %}

    {%- set rows_list = [] -%}

    {%- for node in graph.nodes.values() if node.resource_type in resource_type_list -%}

        {# 'Check if node is in the provided files' #}
        {%- set valid_files = [] -%}
        {%- if files_list -%}
            {%- for file in files_list if re.match(file, node.original_file_path, re.IGNORECASE) -%}
                {%- if exclude_files_list -%}
                    {%- for file_exclude in exclude_files_list if not re.match(file_exclude, node.original_file_path, re.IGNORECASE) -%}
                        {{ valid_files.append(1) }}
                    {%- endfor -%}
                {%- else -%}
                    {{ valid_files.append(1) }}
                {%- endif -%}
            {%- endfor -%}
        {%- else -%}
            {{ valid_files.append(1) }}
        {%- endif -%}

        {%- if valid_files -%}

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

        {# 'Check if source is in the provided files' #}
        {%- set valid_files = [] -%}
        {%- if files_list -%}
            {%- for file in files_list if re.match(file, source.original_file_path, re.IGNORECASE) -%}
                {%- if exclude_files_list -%}
                    {%- for file_exclude in exclude_files_list if not re.match(file_exclude, source.original_file_path, re.IGNORECASE) -%}
                        {{ valid_files.append(1) }}
                    {%- endfor -%}
                {%- else -%}
                    {{ valid_files.append(1) }}
                {%- endif -%}
            {%- endfor -%}
        {%- else -%}
            {{ valid_files.append(1) }}
        {%- endif -%}

        {%- if valid_files -%}

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