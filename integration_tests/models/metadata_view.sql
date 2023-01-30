{{ metalog.create_metadata_model(
        metadata = [
            "system"
            , "table"
            , "business_questions"
            , "joins"
        ]
        , granularity = [
            "business_questions"
            , "joins"
        ]
        , resource_type = [
            'model'
        ]
        , undefined='Undefined'
        , show_resource_type=True
) }}