{{ config(
    meta={
        'system': 'salesforce'
        , 'table': 'fact_store_opening_status'
        , 'area': 'sales'
        , 'category': 'fact'
        , 'main_subject': 'sales'
        , 'secondary_subject': 'store openings'
        , 'granularity': 'Each row represents ...'
        , 'business_questions': [
            'How many stores of type ...?'
            , 'How many stores in ...?'
        ]
        , 'business_rules' : [
            'Stores of type A receive code B ...'
            , 'Consider only stores open after ...'
        ]
        , 'joins': [
            'dim_dates: fact_store_opening_status.date = dim_dates.date'
            , 'dim_stores: fact_store_opening_status.store_sk = dim_stores.store_sk'
        ]
    }
)}}

select 3 as dummy
