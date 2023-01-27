{% macro create_metadata_table(metadata_list=[], granularity_list=[]) %}

    {% if execute %}

        {% set models_list = metalog.get_metadata(metadata_list, granularity_list) %}

        {% for model in models_list %}

            select

            {{ metalog.array_offset(model, 0) }} as model_unique_id

            {% for i in range(metadata_list | length) %}

                , {{ metalog.array_offset(model, i+1) }} as {{metadata_list[i]}}

            {% endfor %}

            {% if not loop.last %}
                union all
            {% endif %}

        {% endfor %}

    {% endif %}

{% endmacro %}