# dbt-metalog
Create customizable models from your metadata.

# Contents
* [create_metadata_model](#create_metadata_model-source)

# Installation instructions
New to dbt packages? Read more about them [here](https://docs.getdbt.com/docs/building-a-dbt-project/package-management/).
1. Include this package in your `packages.yml` file.
```yaml
packages:
  - git: "https://github.com/techindicium/metalog.git"
```

2. Run `dbt deps` to install the package.

# Macros
## create_metadata_model ([source](macros/create_metadata_model.sql))

This macro generates SQL for creating **customizable tables or views from the [metadata](https://docs.getdbt.com/reference/resource-configs/meta) of your models**. You have the **flexibility to select the specific metadata** you want to include in your table or view. The resulting table or view **will display the chosen metadata for each model within your project**. If a model **does not contain the specified metadata, it will be displayed as "Undefined"**, but you can alter this default text to your preference.

### Usage

The macro will check the metadata defined in your models. If you are new to metadata in dbt, check the documentation [here](https://docs.getdbt.com/reference/configs-and-properties).

You can define the ```meta```config in
* Your model, inside the config block.
* A config property, in a ```.yml file```
* The ```dbt_project.yml``` under configs under models.

**WARNING: Currently this package does not supports dicts in the meta config, just single values or lists.**

#### Define the metadata in your models
So, for example take a look at the [dummy_model_1](https://github.com/techindicium/dbt-metalog/blob/main/integration_tests/models/dummy_model_1.sql) inside the ```integration_tests``` folder
```sql
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

select 1 as dummy
```

#### Create a model which uses the ```create_metadata_model``` macro.

Use the ```create_metadata_model``` macro passing as argument a list of the metadata you want to include in your model. Using the [metadata_view](https://github.com/techindicium/dbt-metalog/blob/main/integration_tests/models/metadata_view.sql) as example:
```sql
{{ metalog.create_metadata_table(
        metadata_list = [
            "system"
            , "table"
            , "business_questions"
            , "joins"
        ]
) }}
```

#### Run your model
Just run it!
```shell
dbt run -s metadata_view
```

The output view, using the meta defined in [dummy_model_1](https://github.com/techindicium/dbt-metalog/blob/main/integration_tests/models/dummy_model_1.sql), [dummy_model_2](https://github.com/techindicium/dbt-metalog/blob/main/integration_tests/models/dummy_model_2.sql) and [dummy_model_3](https://github.com/techindicium/dbt-metalog/blob/main/integration_tests/models/dummy_model_3.sql) will be:

|model_unique_id                              |system    |table                    |business_questions          |joins                                                               |
|---------------------------------------------|----------|-------------------------|----------------------------|--------------------------------------------------------------------|
|model.metalog_integration_tests.dummy_model_1|salesforce|fact_store_opening_status|['How many stores of type ...?', 'How many stores in ...?']|['dim_dates: fact_store_opening_status.date = dim_dates.date', 'dim_stores: fact_store_opening_status.store_sk = dim_stores.store_sk']|
|model.metalog_integration_tests.dummy_model_2|system_2  |table_2                  |['question 2_1', 'question 2_2', 'question 2_3']|Undefined                                                           |
|model.metalog_integration_tests.dummy_model_3|system_3  |table_3                  |Undefined                   |['join_3_1', 'join_3_2']                                            |
|model.metalog_integration_tests.metadata_view|Undefined |Undefined                |Undefined                   |Undefined                                                           |


**If you want to break a metadata into different rows, you can use the ```granularity_list``` argument. For example, if you want to break the ```business_questions``` meta into different lines, change your model to:**

```sql
{{ metalog.create_metadata_table(
        metadata_list = [
            "system"
            , "table"
            , "business_questions"
            , "joins"
        ]
        , granularity_list = [
            "business_questions"
        ]

) }}
```

When you run it, the output will be:
|model_unique_id                              |system    |table                    |business_questions          |joins                                                               |
|---------------------------------------------|----------|-------------------------|----------------------------|--------------------------------------------------------------------|
|model.metalog_integration_tests.dummy_model_1|salesforce|fact_store_opening_status|How many stores of type ...?|['dim_dates: fact_store_opening_status.date = dim_dates.date', 'dim_stores: fact_store_opening_status.store_sk = dim_stores.store_sk']|
|model.metalog_integration_tests.dummy_model_1|salesforce|fact_store_opening_status|How many stores in ...?     |['dim_dates: fact_store_opening_status.date = dim_dates.date', 'dim_stores: fact_store_opening_status.store_sk = dim_stores.store_sk']|
|model.metalog_integration_tests.dummy_model_2|system_2  |table_2                  |question 2_1                |Undefined                                                           |
|model.metalog_integration_tests.dummy_model_2|system_2  |table_2                  |question 2_2                |Undefined                                                           |
|model.metalog_integration_tests.dummy_model_2|system_2  |table_2                  |question 2_3                |Undefined                                                           |
|model.metalog_integration_tests.dummy_model_3|system_3  |table_3                  |Undefined                   |['join_3_1', 'join_3_2']                                            |
|model.metalog_integration_tests.metadata_view|Undefined |Undefined                |Undefined                   |Undefined                                                           |


You can pass more than one metadata into the ```granularity_list```, for example:
```sql
{{ metalog.create_metadata_table(
        metadata_list = [
            "system"
            , "table"
            , "business_questions"
            , "joins"
        ]
        , granularity_list = [
            "business_questions"
            , "joins"
        ]

) }}
```

Output:
|model_unique_id                              |system    |table                    |business_questions          |joins                                                               |
|---------------------------------------------|----------|-------------------------|----------------------------|--------------------------------------------------------------------|
|model.metalog_integration_tests.dummy_model_1|salesforce|fact_store_opening_status|How many stores of type ...?|dim_dates: fact_store_opening_status.date = dim_dates.date          |
|model.metalog_integration_tests.dummy_model_1|salesforce|fact_store_opening_status|How many stores of type ...?|dim_stores: fact_store_opening_status.store_sk = dim_stores.store_sk|
|model.metalog_integration_tests.dummy_model_1|salesforce|fact_store_opening_status|How many stores in ...?     |dim_dates: fact_store_opening_status.date = dim_dates.date          |
|model.metalog_integration_tests.dummy_model_1|salesforce|fact_store_opening_status|How many stores in ...?     |dim_stores: fact_store_opening_status.store_sk = dim_stores.store_sk|
|model.metalog_integration_tests.dummy_model_2|system_2  |table_2                  |question 2_1                |Undefined                                                           |
|model.metalog_integration_tests.dummy_model_2|system_2  |table_2                  |question 2_2                |Undefined                                                           |
|model.metalog_integration_tests.dummy_model_2|system_2  |table_2                  |question 2_3                |Undefined                                                           |
|model.metalog_integration_tests.dummy_model_3|system_3  |table_3                  |Undefined                   |join_3_1                                                            |
|model.metalog_integration_tests.dummy_model_3|system_3  |table_3                  |Undefined                   |join_3_2                                                            |
|model.metalog_integration_tests.metadata_view|Undefined |Undefined                |Undefined                   |Undefined                                                           |

### Arguments
* ```metadata_list``` (required): The metadata which will be the columns of your model.
* ```granularity_list``` (optional): Metadata which must be separated in different rows. They must be wrote in the meta config as lists.
* ```undefined``` (optional): Overrides the default string showed when the metadata is not found for that model.

