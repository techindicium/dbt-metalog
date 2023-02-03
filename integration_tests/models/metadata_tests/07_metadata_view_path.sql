{{ metalog.create_metadata_model(
        metadata = [
           "main_subject"
            , "owner"
            , "business_questions"
            , "business_rules"
            , "todos"
        ]
        , granularity = [
            "business_questions"
            , "business_rules"
            , "todos"
        ]
        , resource_type = [
                "model"
                , "seed"
                , "source"
        ]
        , show_resource_type = True
        , undefined = "Not defined"
        , undefined_as_null = True
        , resource_path_contains = [
            "models/"
            , "seeds/"
            , "source.yml"
        ]
        , exclude_resource_path_contains = [
            'models/metadata_tests'
            'models/description_tests'
        ]
)}}