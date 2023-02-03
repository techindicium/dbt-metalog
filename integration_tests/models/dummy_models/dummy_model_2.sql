{{ config(
    meta={
        'main_subject': 'people'
        , 'owner': 'Bob'
        , 'business_questions': 'How many employees ...?'
    }
)}}

select *
from {{ source('raw', 'dummy_raw') }}