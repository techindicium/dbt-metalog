{% macro recursive_combinations(lists, id, current_combination, all_combinations) %}

    {% if id == lists | length %}
        {{ all_combinations.append(current_combination) }}
    {% endif %}

    {% for item in lists[id] %}
        {{ metalog.recursive_combinations(lists, id + 1, current_combination + [item], all_combinations) }}
    {% endfor %}

{% endmacro %}