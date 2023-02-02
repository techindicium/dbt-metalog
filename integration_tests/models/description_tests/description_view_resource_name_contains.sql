{{ metalog.create_description_model(
        resource_type = [
                "model"
                , "seed"
        ]
        , show_resource_type = True
        , resource_path = [
            "models/"
            , "seeds/"
        ]
        , resource_name_contains = [
            'dummy'
        ]
        , exclude_resource_name_contains = [
            'seed'
        ]
)}}