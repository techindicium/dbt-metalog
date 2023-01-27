{% macro get_metadata(metadata_list, granularity_list) %}

    {% set models_list = [] %}

    {% for model in graph.nodes.values() | selectattr("resource_type", "equalto", "model") %}

        {% set granularity_values_list = [] %}

        {% for metadata in granularity_list %}

            {% set values_list = [] %}

            {% for item in model.meta[metadata] %}
                {{ values_list.append(item) }}
            {% endfor %}

            {{ granularity_values_list.append(values_list) }}

        {% endfor %}

        {% set all_combinations = metalog.combinations(granularity_values_list) %}

        {% if all_combinations == [] %}
            {% set all_combinations = [[]] %}
        {% endif %}

        {% for c in range(all_combinations | length) %}

            {% set model_row = [] %}

            {{ model_row.append(model.unique_id) }}

            {% for metadata in metadata_list %}

                {% if not model.meta[metadata] or not model.meta %}
                    {{ model_row.append('Undefined') }}
                {% else %}

                    {% if metadata not in granularity_list %}
                            {{ model_row.append(model.meta[metadata]) }}
                    {% else %}
                        {% set idx = granularity_list.index(metadata) %}
                        {{ model_row.append(all_combinations[c][idx]) }}
                    {% endif %}

                {% endif %}

            {% endfor %}

            {{ models_list.append(model_row) }}

        {% endfor %}

    {% endfor %}

    {{ return(models_list) }}

{% endmacro %}