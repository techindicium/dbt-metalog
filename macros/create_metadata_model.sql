{%- macro create_metadata_model(
    metadata
    , granularity=[]
    , resource_type=["model"]
    , show_resource_type=True
    , undefined="Undefined"
    , undefined_as_null=False
    , files=[]
    , exclude_files=[]
) -%}
    {%- if execute -%}

        {%- set rows_list = metalog.get_metadata(metadata, granularity, resource_type, undefined, files, exclude_files) -%}

        {%- if rows_list | length == 0 -%}
            {{ exceptions.raise_compiler_error("No metadata found for the provided parameters\nPlease check the metadata and resource type provided") }}
        {%- endif -%}

        {%- for row in rows_list -%}

            select "{{ row[0] }}" as resource_name

            {%- if show_resource_type -%}
                , "{{ row[1] }}" as resource_type
            {%- endif -%}

            {%- for i in range(metadata | length) -%}

                {%- if undefined_as_null and row[i+2] == undefined -%}
                    , null as {{metadata[i]}}
                {%- else -%}
                    , "{{ row[i+2] }}" as {{metadata[i]}}
                {%- endif -%}

            {%- endfor -%}

            {% if not loop.last %}
                union all
            {% endif %}

        {%- endfor -%}

    {%- endif -%}

{%- endmacro -%}


{%- macro get_metadata(
    metadata_list
    , granularity_list
    , resource_type_list
    , undefined
    , files_list
    , exclude_files_list
) -%}

    {% set re = modules.re %}

    {%- set rows_list = [] -%}

    {%- for node in graph.nodes.values() if node.resource_type in resource_type_list -%}

        {# "Check if node is in the provided files" #}
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

            {%- set granularity_values_list = [] -%}

            {%- for metadata in granularity_list -%}

                {%- set values_list = [] -%}

                {# "If the provided metadata in granularity is a string" #}
                {# "just append the string into values_list" #}
                {%- if node.meta[metadata] is string -%}
                    {{ values_list.append(node.meta[metadata]) }}

                {# "If the provided metadata in granularity is a list" #}
                {# "then append each value into values_list" #}
                {%- else -%}
                    {%- for item in node.meta[metadata] -%}
                        {{ values_list.append(item) }}
                    {%- endfor -%}

                {%- endif -%}

                {# "If the model has no metadata from the granularity list" #}
                {# "append the undefined argument string" #}
                {%- if values_list == [] -%}
                    {%- set values_list = [undefined] -%}
                {%- endif -%}

                {{ granularity_values_list.append(values_list) }}

            {%- endfor -%}

            {%- set all_combinations = metalog.combinations(granularity_values_list) -%}

            {# "The if block below is used to get a length of 1 for all_combinations
            if there is none combination" #}
            {%- if all_combinations == [] -%}
                {%- set all_combinations = [[]] -%}
            {%- endif -%}

            {%- for c in range(all_combinations | length) -%}

                {%- set node_row = [] -%}

                {%- set unique_id_splitted = node.unique_id.split(".") -%}

                {{ node_row.append(unique_id_splitted[2]) }}
                {{ node_row.append(node.resource_type) }}

                {%- for metadata in metadata_list -%}

                    {%- if not node.meta[metadata] or not node.meta -%}
                        {{ node_row.append(undefined) }}
                    {%- else -%}

                        {%- if metadata not in granularity_list -%}
                                {{ node_row.append(node.meta[metadata] | string) }}
                        {%- else -%}
                            {%- set idx = granularity_list.index(metadata) -%}
                            {{ node_row.append(all_combinations[c][idx] | string) }}
                        {%- endif -%}

                    {%- endif -%}

                {%- endfor -%}

                {{ rows_list.append(node_row) }}

            {%- endfor -%}

        {%- endif -%}

    {%- endfor -%}

    {%- for source in graph.sources.values() if source.resource_type in resource_type_list -%}

        {# "Check if source is in the provided files" #}
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

            {%- set granularity_values_list = [] -%}

            {%- for metadata in granularity_list -%}

                {%- set values_list = [] -%}

                {# "If the provided metadata in granularity is a string" #}
                {# "just append the string into values_list" #}
                {%- if source.meta[metadata] is string -%}
                    {{ values_list.append(source.meta[metadata]) }}

                {# "If the provided metadata in granularity is a list" #}
                {# "then append each value into values_list" #}
                {%- else -%}
                    {%- for item in source.meta[metadata] -%}
                        {{ values_list.append(item) }}
                    {%- endfor -%}

                {%- endif -%}

                {# "If the model has no metadata from the granularity list" #}
                {# "append the undefined argument string" #}
                {%- if values_list == [] -%}
                    {%- set values_list = [undefined] -%}
                {%- endif -%}

                {{ granularity_values_list.append(values_list) }}

            {%- endfor -%}

            {%- set all_combinations = metalog.combinations(granularity_values_list) -%}

            {# "The if block below is used to get a length of 1 for all_combinations
            if there is none combination" #}
            {%- if all_combinations == [] -%}
                {%- set all_combinations = [[]] -%}
            {%- endif -%}

            {%- for c in range(all_combinations | length) -%}

                {%- set source_row = [] -%}

                {%- set unique_id_splitted = source.unique_id.split(".") -%}

                {{ source_row.append(unique_id_splitted[2]) }}
                {{ source_row.append(source.resource_type) }}

                {%- for metadata in metadata_list -%}

                    {%- if not source.meta[metadata] or not source.meta -%}
                        {{ source_row.append(undefined) }}
                    {%- else -%}

                        {%- if metadata not in granularity_list -%}
                                {{ source_row.append(source.meta[metadata] | string) }}
                        {%- else -%}
                            {%- set idx = granularity_list.index(metadata) -%}
                            {{ source_row.append(all_combinations[c][idx] | string) }}
                        {%- endif -%}

                    {%- endif -%}

                {%- endfor -%}

                {{ rows_list.append(source_row) }}

            {%- endfor -%}

        {%- endif -%}

    {%- endfor -%}

    {{ return(rows_list) }}

{%- endmacro -%}