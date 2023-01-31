{% macro create_metadata_model(
    metadata
    , granularity=[]
    , resource_type=['model']
    , show_resource_type=True
    , undefined='Undefined'
    , undefined_as_null=False
    , path=[]
) %}

    {% if execute %}

        {% set nodes_list = metalog.get_metadata(metadata, granularity, resource_type, undefined, path) %}

        {% if nodes_list | length == 0 %}

            {{ exceptions.raise_compiler_error("No metadata found for the provided parameters\nPlease check the metadata and resource type provided") }}

        {% endif %}

        {% for node in nodes_list %}

            select

                {{ metalog.array_offset(node, 0) }} as node_name

            {% if show_resource_type %}
                , {{ metalog.array_offset(node, 1) }} as resource_type
            {% endif %}


            {% for i in range(metadata | length) %}
                {% if undefined_as_null and node[i+2] == undefined %}
                    , null as {{metadata[i]}}
                {% else %}
                    , {{ metalog.array_offset(node, i+2) }} as {{metadata[i]}}
                {% endif %}
            {% endfor %}

            {% if not loop.last %}
                union all
            {% endif %}

        {% endfor %}

    {% endif %}

{% endmacro %}


{% macro get_metadata(
    metadata_list
    , granularity_list
    , resource_type_list
    , undefined
    , path_list
) %}

    {% set nodes_list = [] %}

    {% for node in graph.nodes.values() if node.resource_type in resource_type_list %}

        {% if path_list %}
            {% set is_path = [] %}
            {% for item in path_list if item in node.original_file_path %}
                {{ is_path.append(1) }}
            {% endfor %}
        {% else %}
            {% set is_path = True %}
        {% endif %}

        {% if is_path %}

            {% set granularity_values_list = [] %}

            {% for metadata in granularity_list %}

                {% set values_list = [] %}

                {% for item in node.meta[metadata] %}
                    {{ values_list.append(item) }}
                {% endfor %}

                {% if values_list == [] %}
                    {% set values_list = [undefined] %}
                {% endif %}

                {{ granularity_values_list.append(values_list) }}

            {% endfor %}

            {% set all_combinations = metalog.combinations(granularity_values_list) %}

            {% if all_combinations == [] %}
                {% set all_combinations = [[]] %}
            {% endif %}

            {% for c in range(all_combinations | length) %}

                {% set node_row = [] %}

                {% set unique_id_splitted = node.unique_id.split('.') %}

                {{ node_row.append(unique_id_splitted[2]) }}
                {{ node_row.append(node.resource_type) }}

                {% for metadata in metadata_list %}

                    {% if not node.meta[metadata] or not node.meta %}
                        {{ node_row.append(undefined) }}
                    {% else %}

                        {% if metadata not in granularity_list %}
                                {{ node_row.append(node.meta[metadata] | string) }}
                        {% else %}
                            {% set idx = granularity_list.index(metadata) %}
                            {{ node_row.append(all_combinations[c][idx] | string) }}
                        {% endif %}

                    {% endif %}

                {% endfor %}

                {{ nodes_list.append(node_row) }}

            {% endfor %}

        {% endif %}

    {% endfor %}

    {{ return(nodes_list) }}

{% endmacro %}