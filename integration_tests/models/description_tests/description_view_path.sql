{{ metalog.create_description_model(
        resource_type = [
                "model"
                , "seed"
        ]
        , show_resource_type = True
        , resource_path_contains = [
            "models/"
            , "seeds/"
        ]
        , exclude_resource_path_contains = [
            'models/metadata_tests'
            'models/description_tests'
        ]
)}}