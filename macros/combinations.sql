{% macro combinations(lists) %}

    {% set all_combinations = [] %}

    {{ metalog.recursive_combinations(lists, 0, [], all_combinations) }}

    {{ return(all_combinations) }}

{% endmacro %}