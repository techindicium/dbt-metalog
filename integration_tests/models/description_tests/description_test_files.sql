{{ metalog.create_description_model(
        resource_type = [
            "model"
            , "seed"
            , "source"
        ]
        , show_resource_type = True
        , files = [
            '.*.sql'
        ]
        , exclude_files = [
            'models/metadata.*'
        ]
)}}