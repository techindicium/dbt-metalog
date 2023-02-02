{% macro create_description_model(
    resource_type=['model']
    , show_resource_type=True
    , resource_path=[]
    , resource_name_contains=[]
    , exclude_resource_path=[]
    , exclude_resource_name_contains=[]
) %}

    {% if execute %}

        {% set rows_list = metalog.get_rows(resource_type, resource_path, resource_name_contains, exclude_resource_path, exclude_resource_name_contains) %}

        {% if rows_list | length == 0 %}

            {{ exceptions.raise_compiler_error("No description found for the provided parameters\nPlease check the descriptions of your resources") }}

        {% endif %}

        {% for row in rows_list %}

            select

                {{ metalog.array_offset(row, 0) }} as resource_name

            {% if show_resource_type %}
                , {{ metalog.array_offset(row, 1) }} as resource_type
            {% endif %}

                , {{ metalog.array_offset(row, 2) }} as resource_description
                , {{ metalog.array_offset(row, 3) }} as column_name
                , {{ metalog.array_offset(row, 4) }} as columns_description

            {% if not loop.last %}
                union all
            {% endif %}

        {% endfor %}

    {% endif %}

{% endmacro %}


{% macro get_rows(
    resource_type_list
    , resource_path_list
    , resource_name_contains_list
    , exclude_resource_path_list
    , exclude_resource_name_contains_list
) %}

    {% set rows_list = [] %}

    {% for node in graph.nodes.values() if node.resource_type in resource_type_list %}

        {# 'Check if node is in the provided resource_paths' #}
        {% if resource_path_list %}
            {% set is_resource_path = [] %}
            {% for item in resource_path_list if node.original_file_path.startswith(item) %}
                {% if exclude_resource_path_list %}
                    {% for item_exclude in exclude_resource_path_list if not node.original_file_path.startswith(item_exclude) %}
                        {{ is_resource_path.append(1) }}
                    {% endfor %}
                {% else %}
                    {{ is_resource_path.append(1) }}
                {% endif %}
            {% endfor %}
        {% else %}
            {% set is_resource_path = True %}
        {% endif %}

        {# 'Check if node name contains at least one of the provided strings' #}
        {% if resource_name_contains_list %}
            {% set is_name = [] %}
            {% for item in resource_name_contains_list if item in node.unique_id.split('.')[2] %}
                {% if exclude_resource_name_contains_list %}
                    {% for item_exclude in exclude_resource_name_contains_list if not item_exclude in node.unique_id.split('.')[2] %}
                        {{ is_name.append(1) }}
                    {% endfor %}
                {% else %}
                    {{ is_name.append(1) }}
                {% endif %}
            {% endfor %}
        {% else %}
            {% set is_name = True %}
        {% endif %}

        {% if is_resource_path and is_name %}

            {% for column in node.columns.values() %}

                {% set node_columns_list = [] %}
                {{ node_columns_list.append(node.unique_id.split('.')[2]) }}
                {{ node_columns_list.append(node.resource_type) }}
                {{ node_columns_list.append(node.description) }}
                {{ node_columns_list.append(column.name) }}
                {{ node_columns_list.append(column.description) }}

                {{ rows_list.append(node_columns_list) }}

            {% endfor %}

        {% endif %}

    {% endfor %}

    {{ return(rows_list) }}

{% endmacro %}