# dbt-metalog: Your metadata's catalog
Create customizable models from your metadata.

Easily create models for
* **Business rules**
* **Questions the model can answer**
* **Tech responsibles**
* **Requesting areas/persons**
* **Date the model was created**
* **ToDo's**
* **Any metadata you want**

# Contents
* [create_metadata_model](#create_metadata_model-source)

# Installation instructions
New to dbt packages? Read more about them [here](https://docs.getdbt.com/docs/building-a-dbt-project/package-management/).

1. Include this package in your `packages.yml` file.
```yaml
packages:
  - git: "https://github.com/techindicium/dbt-metalog.git"
```

2. Run `dbt deps` to install the package.

## Requirements
* ```dbt version >= 1.0.0```

### Supported adapters
:white_check_mark: ```dbt-bigquery```
:white_check_mark: ```dbt-databricks```
:white_check_mark: ```dbt-postgres```
:white_check_mark: ```dbt-redshift```
:white_check_mark: ```dbt-snowflake```

# Macros
## create_metadata_model ([source](macros/create_metadata_model.sql))

This macro generates SQL for creating **customizable tables or views from the [metadata](https://docs.getdbt.com/reference/resource-configs/meta) of your nodes**. You have the **flexibility to select the specific metadata** you want to include in your table or view. The resulting table or view **will display the chosen metadata for each model within your project**. If a node **does not contain the specified metadata, it will be displayed as "Undefined"**, but you can alter this default text to your preference.


The macro will check the metadata defined in your nodes. If you are new to metadata in dbt, check the documentation [here](https://docs.getdbt.com/reference/configs-and-properties).

Nodes can be:
* Models
* Sources
* Seeds
* Snapshots
* Tests
* Analyses
* Macros

For a model, you can define the ```meta```config in
* Your model, inside the config block.
* A config property, in a ```.yml file```
* The ```dbt_project.yml``` under configs under models.

For others resource types, [check the docs](https://docs.getdbt.com/reference/resource-configs/meta).


> **Warning**: **Currently this package does not supports dicts in the meta config, just single values or lists.**

### Arguments
  - ```metadata``` (required): A ```list``` of the metadata which will be the columns of your model.
  - ```granularity``` (optional) (default = ```[]```) : A ```list``` of th metadata which must be separated in different rows. They must be wrote in the meta config as lists.
  - ```resource_type``` (optional) (default = ```['model']```) : A ```list``` of the resource types you want to read the metadata from. Options:
    - model
    - source
    - seed
    - snapshot
    - tests
    - analysis
    - macros
  - ```undefined``` (optional) (default = ```'Undefined'```) : A ```string``` which overrides the default string showed when the metadata is not found for that model.
  - ```show_resource_type```(optional) (default = ```True```) : A ```boolean``` to show or hide the ```resource_type``` column in your resulting model.

## Usage

### Define the metadata in your nodes
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

### Create a model which uses the ```create_metadata_model``` macro.

Use the ```create_metadata_model``` macro passing as argument a list of the metadata you want to include in your model. Using the [metadata_view](https://github.com/techindicium/dbt-metalog/blob/main/integration_tests/models/metadata_view.sql) as example:
```sql
{{ metalog.create_metadata_model(
        metadata = [
            "system"
            , "table"
            , "business_questions"
            , "joins"
        ]
) }}
```

### Run your model
Just run it!
```shell
dbt run -s metadata_view
```

The output view, using the meta defined in [dummy_model_1](https://github.com/techindicium/dbt-metalog/blob/main/integration_tests/models/dummy_model_1.sql), [dummy_model_2](https://github.com/techindicium/dbt-metalog/blob/main/integration_tests/models/dummy_model_2.sql) and [dummy_model_3](https://github.com/techindicium/dbt-metalog/blob/main/integration_tests/models/dummy_model_3.sql) will be:

|node_name    |resource_type|system    |table                    |business_questions          |joins                                                                                                                                 |
|-------------|-------------|----------|-------------------------|----------------------------|--------------------------------------------------------------------------------------------------------------------------------------|
|dummy_model_1|model        |salesforce|fact_store_opening_status|['How many stores of type ...?', 'How many stores in ...?']|['dim_dates: fact_store_opening_status.date = dim_dates.date', 'dim_stores: fact_store_opening_status.store_sk = dim_stores.store_sk']|
|dummy_model_2|model        |system_2  |table_2                  |['question 2_1', 'question 2_2', 'question 2_3']|Undefined                                                                                                                             |
|dummy_model_3|model        |system_3  |table_3                  |Undefined                   |['join_3_1', 'join_3_2']                                                                                                              |
|metadata_view|model        |Undefined |Undefined                |Undefined                   |Undefined                                                                                                                             |

> **Warning**: **The default materialization for dbt models is view. If you want to change to table, change the [```materialized``` configuration property ](https://docs.getdbt.com/docs/build/materializations).**



**If you want to break a metadata into different rows, you can use the ```granularity_list``` argument. For example, if you want to break the ```business_questions``` meta into different lines, change your model to:**

```sql
{{ metalog.create_metadata_model(
        metadata = [
            "system"
            , "table"
            , "business_questions"
            , "joins"
        ]
        , granularity = [
            "business_questions"
        ]
) }}
```

When you run it, the output will be:
|node_name    |resource_type|system    |table                    |business_questions          |joins                                                                                                                                 |
|-------------|-------------|----------|-------------------------|----------------------------|--------------------------------------------------------------------------------------------------------------------------------------|
|dummy_model_1|model        |salesforce|fact_store_opening_status|How many stores of type ...?|['dim_dates: fact_store_opening_status.date = dim_dates.date', 'dim_stores: fact_store_opening_status.store_sk = dim_stores.store_sk']|
|dummy_model_1|model        |salesforce|fact_store_opening_status|How many stores in ...?     |['dim_dates: fact_store_opening_status.date = dim_dates.date', 'dim_stores: fact_store_opening_status.store_sk = dim_stores.store_sk']|
|dummy_model_2|model        |system_2  |table_2                  |question 2_1                |Undefined                                                                                                                             |
|dummy_model_2|model        |system_2  |table_2                  |question 2_2                |Undefined                                                                                                                             |
|dummy_model_2|model        |system_2  |table_2                  |question 2_3                |Undefined                                                                                                                             |
|dummy_model_3|model        |system_3  |table_3                  |Undefined                   |['join_3_1', 'join_3_2']                                                                                                              |
|metadata_view|model        |Undefined |Undefined                |Undefined                   |Undefined                                                                                                                             |

You can pass more than one metadata into the ```granularity_list```, for example:
```sql
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
) }}
```

Output:
|node_name    |resource_type|system    |table                    |business_questions          |joins                                                                                                                                 |
|-------------|-------------|----------|-------------------------|----------------------------|--------------------------------------------------------------------------------------------------------------------------------------|
|dummy_model_1|model        |salesforce|fact_store_opening_status|How many stores of type ...?|dim_dates: fact_store_opening_status.date = dim_dates.date                                                                            |
|dummy_model_1|model        |salesforce|fact_store_opening_status|How many stores of type ...?|dim_stores: fact_store_opening_status.store_sk = dim_stores.store_sk                                                                  |
|dummy_model_1|model        |salesforce|fact_store_opening_status|How many stores in ...?     |dim_dates: fact_store_opening_status.date = dim_dates.date                                                                            |
|dummy_model_1|model        |salesforce|fact_store_opening_status|How many stores in ...?     |dim_stores: fact_store_opening_status.store_sk = dim_stores.store_sk                                                                  |
|dummy_model_2|model        |system_2  |table_2                  |question 2_1                |Undefined                                                                                                                             |
|dummy_model_2|model        |system_2  |table_2                  |question 2_2                |Undefined                                                                                                                             |
|dummy_model_2|model        |system_2  |table_2                  |question 2_3                |Undefined                                                                                                                             |
|dummy_model_3|model        |system_3  |table_3                  |Undefined                   |join_3_1                                                                                                                              |
|dummy_model_3|model        |system_3  |table_3                  |Undefined                   |join_3_2                                                                                                                              |
|metadata_view|model        |Undefined |Undefined                |Undefined                   |Undefined                                                                                                                             |


You can hide the ```resource_type``` column passing the parameter ```show_resource_type=False```
```sql
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
        , show_resource_type=False
) }}
```

Output:
|node_name    |system|table     |business_questions       |joins                       |
|-------------|------|----------|-------------------------|----------------------------|
|dummy_model_1|salesforce|fact_store_opening_status|How many stores of type ...?|dim_dates: fact_store_opening_status.date = dim_dates.date|
|dummy_model_1|salesforce|fact_store_opening_status|How many stores of type ...?|dim_stores: fact_store_opening_status.store_sk = dim_stores.store_sk|
|dummy_model_1|salesforce|fact_store_opening_status|How many stores in ...?  |dim_dates: fact_store_opening_status.date = dim_dates.date|
|dummy_model_1|salesforce|fact_store_opening_status|How many stores in ...?  |dim_stores: fact_store_opening_status.store_sk = dim_stores.store_sk|
|dummy_model_2|system_2|table_2   |question 2_1             |Undefined                   |
|dummy_model_2|system_2|table_2   |question 2_2             |Undefined                   |
|dummy_model_2|system_2|table_2   |question 2_3             |Undefined                   |
|dummy_model_3|system_3|table_3   |Undefined                |join_3_1                    |
|dummy_model_3|system_3|table_3   |Undefined                |join_3_2                    |
|metadata_view|Undefined|Undefined |Undefined                |Undefined                   |
