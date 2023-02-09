{{ config(
    meta={
        'main_subject': 'sales'
        , 'owner': 'Alice'
        , 'business_questions': [
            'How many stores of type ...?'
            , 'How many stores in ...?'
        ]
        , 'business_rules': [
            'Stores of type A receive code B ...'
            , 'Consider only stores open after ...'
        ]
        , 'todos': 'change to incremental'
    }
)}}

select 1 as dummy