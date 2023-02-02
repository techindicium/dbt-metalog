# dbt-metalog: Your metadata's catalog
Create customizable models from your metadata.

Easily create models for:
* **Business rules**
* **Business questions**
* **Tech owners**
* **Requesting areas/persons**
* **Date the model was created**
* **ToDo's**
* **Any metadata you want**

Choose your metadata by:
* **metadata name**
* **resource type**
* **resource path**
* **resource name**

# Contents
* [create_metadata_model](#create_metadata_model-source)

# Requirements
dbt version
* ```dbt version >= 1.0.0```

Supported adapters

:white_check_mark: ```dbt-bigquery```
:white_check_mark: ```dbt-databricks```
:white_check_mark: ```dbt-postgres```
:white_check_mark: ```dbt-redshift```
:white_check_mark: ```dbt-snowflake```

# Package installation

New to dbt packages? Read more about them [here](https://docs.getdbt.com/docs/building-a-dbt-project/package-management/).

1. Include this package in your `packages.yml` file.
```yaml
packages:
  - git: "https://github.com/techindicium/dbt-metalog.git"
```

2. Run `dbt deps` to install the package.



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


## Arguments
  - ```metadata``` (required): A ```list``` of the metadata which will be the columns of your model.
  - ```granularity``` (optional) (default = ```[]```): A ```list``` of th metadata which must be separated in different rows. They must be wrote in the meta config as lists.
  - ```resource_type``` (optional) (default = ```['model']```): A ```list``` of the resource types you want to read the metadata from. Options:
    - model
    - source
    - seed
    - snapshot
    - tests
    - analysis
    - macros
  - ```undefined``` (optional) (default = ```'Undefined'```): A ```string``` which overrides the default string shown when the metadata is not found for that model.
  - ```undefined_as_null``` (optional) (default = ```'False'```): A ```booelan```, when True undefined metadata will be displayed as null.
  - ```show_resource_type```(optional) (default = ```True```): A ```boolean``` to show or hide the ```resource_type``` column in your resulting model.
  - ```resource_path```(optional) (default = []): A ```list``` of folder paths. The macro will only look for resources in these folders.
  - ```resource_name_contains```(optional) (default = []): A ```list``` strings. The macro will only look for resources which contains at least one of the provided strings in their names.

## Usage

### Define the metadata in your nodes
So, for example take a look at the [dummy_model_1](https://github.com/techindicium/dbt-metalog/blob/feature/adding_tests/integration_tests/models/dummy_models/dummy_model_1.sql) inside the ```integration_tests``` folder

```sql
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
        , 'todos': [
            'change to incremental'
            ]
    }
)}}

select 1 as dummy
```

### Create a model which uses the ```create_metadata_model``` macro.

Use the ```create_metadata_model``` macro passing as argument a list of the metadata you want to include in your model. Let's create a model named ```metadata_view``` (you can choose any name) as example:
```sql
{{ metalog.create_metadata_model(
        metadata = [
            "main_subject"
            , "owner"
            , "business_questions"
            , "business_rules"
            , "todos"
        ]
)}}
```

> **Note**: **The default materialization for dbt models is view. If you want to change to table, change the [```materialized``` configuration property ](https://docs.getdbt.com/docs/build/materializations).**

### Run your model
Just run it!
```shell
dbt run -s metadata_view
```

> **Note** Suppose we have the following nodes in our project: [dummy_model_1](https://github.com/techindicium/dbt-metalog/blob/feature/adding_tests/integration_tests/models/dummy_models/dummy_model_1.sql), [dummy_model_2](https://github.com/techindicium/dbt-metalog/blob/feature/adding_tests/integration_tests/models/dummy_models/dummy_model_2.sql) and [dummy_seed](https://github.com/techindicium/dbt-metalog/blob/feature/adding_tests/integration_tests/seeds/dummy_seed.csv)


The output view, using the meta defined in our nodes will be:

|resource_name    |resource_type|main_subject|owner|business_questions                                         |business_rules                                                                |todos                    |
|-------------|-------------|------------|-----|-----------------------------------------------------------|------------------------------------------------------------------------------|-------------------------|
|dummy_model_1|model        |sales       |Alice|['How many stores of type ...?', 'How many stores in ...?']|['Stores of type A receive code B ...', 'Consider only stores open after ...']|['change to incremental']|
|dummy_model_2|model        |people      |Bob  |['How many employees ...?']                                |Undefined                                                                     |Undefined                |
|metadata_view|model |Undefined    |Undefined   |Undefined|Undefined                                                  |Undefined                                                                     |                         |


# Additional customization

## granularity

**If you want to break a metadata into different rows, you can use the ```granularity_list``` argument. For example, if you want to break the ```business_questions``` meta into different lines, change your model to:**

```sql
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
        ]
)}}
```

Now you have only a business question per row.

|resource_name    |resource_type|main_subject|owner|business_questions                                         |business_rules                                                                |todos                    |
|-------------|-------------|------------|-----|-----------------------------------------------------------|------------------------------------------------------------------------------|-------------------------|
|dummy_model_1|model        |sales       |Alice|How many stores of type ...?                               |['Stores of type A receive code B ...', 'Consider only stores open after ...']|['change to incremental']|
|dummy_model_1|model        |sales       |Alice|How many stores in ...?                                    |['Stores of type A receive code B ...', 'Consider only stores open after ...']|['change to incremental']|
|dummy_model_2|model        |people      |Bob  |How many employees ...?                                    |Undefined                                                                     |Undefined                |
|metadata_view|model |Undefined    |Undefined   |Undefined|Undefined                                                  |Undefined                                                                     |                         |


You can pass more than one metadata to the ```granularity_list```, for example:
```sql
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
)}}
```

Now each row have a unique business question, business rule and a todo.

|resource_name    |resource_type|main_subject|owner|business_questions                                         |business_rules                                                                |todos                    |
|-------------|-------------|------------|-----|-----------------------------------------------------------|------------------------------------------------------------------------------|-------------------------|
|dummy_model_1|model        |sales       |Alice|How many stores of type ...?                               |Stores of type A receive code B ...                                           |change to incremental    |
|dummy_model_1|model        |sales       |Alice|How many stores of type ...?                               |Consider only stores open after ...                                           |change to incremental    |
|dummy_model_1|model        |sales       |Alice|How many stores in ...?                                    |Stores of type A receive code B ...                                           |change to incremental    |
|dummy_model_1|model        |sales       |Alice|How many stores in ...?                                    |Consider only stores open after ...                                           |change to incremental    |
|dummy_model_2|model        |people      |Bob  |How many employees ...?                                    |Undefined                                                                     |Undefined                |
|metadata_view|model |Undefined    |Undefined   |Undefined|Undefined                                                  |Undefined                                                                     |                         |


## resource_type
You can ask the macro to include metadata of more resource types with the ```resource_type```argument. Let's include ```seeds``` along with models.

```sql
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
        ]
)}}
```

Now you can see also the metadata from the ```dummy_seed```.
|resource_name    |resource_type|main_subject|owner|business_questions                                         |business_rules                                                                |todos                    |
|-------------|-------------|------------|-----|-----------------------------------------------------------|------------------------------------------------------------------------------|-------------------------|
|dummy_model_1|model        |sales       |Alice|How many stores of type ...?                               |Stores of type A receive code B ...                                           |change to incremental    |
|dummy_model_1|model        |sales       |Alice|How many stores of type ...?                               |Consider only stores open after ...                                           |change to incremental    |
|dummy_model_1|model        |sales       |Alice|How many stores in ...?                                    |Stores of type A receive code B ...                                           |change to incremental    |
|dummy_model_1|model        |sales       |Alice|How many stores in ...?                                    |Consider only stores open after ...                                           |change to incremental    |
|dummy_model_2|model        |people      |Bob  |How many employees ...?                                    |Undefined                                                                     |Undefined                |
|dummy_seed   |seed         |sales       |Carl |Undefined                                                  |Undefined                                                                     |Undefined                |
|metadata_view|model |Undefined    |Undefined   |Undefined|Undefined                                                  |Undefined                                                                     |                         |

## show_resource_type

You can hide the ```resource_type``` column passing the argument ```show_resource_type=False```
```sql
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
        ]
        , show_resource_type = False
)}}
```

The ```resource_type``` column was removed

|resource_name    |main_subject|owner |business_questions|business_rules                                             |todos                                                                         |
|-------------|------------|------|------------------|-----------------------------------------------------------|------------------------------------------------------------------------------|
|dummy_model_1|sales       |Alice |How many stores of type ...?|Stores of type A receive code B ...                        |change to incremental                                                         |
|dummy_model_1|sales       |Alice |How many stores of type ...?|Consider only stores open after ...                        |change to incremental                                                         |
|dummy_model_1|sales       |Alice |How many stores in ...?|Stores of type A receive code B ...                        |change to incremental                                                         |
|dummy_model_1|sales       |Alice |How many stores in ...?|Consider only stores open after ...                        |change to incremental                                                         |
|dummy_model_2|people      |Bob   |How many employees ...?|Undefined                                                  |Undefined                                                                     |
|dummy_seed   |sales       |Carl  |Undefined         |Undefined                                                  |Undefined                                                                     |
|metadata_view|Undefined    |Undefined   |Undefined|Undefined                                                  |Undefined                                                                     |                         |

## undefined
You can override the default 'Undefined' string with ```undefined```.

```sql
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
        ]
        , show_resource_type = True
        , undefined = "Not defined"
)}}
```

The undefined metadata are displayed as 'Not defined'.
|resource_name    |resource_type|main_subject|owner|business_questions                                         |business_rules                                                                |todos                |
|-------------|-------------|------------|-----|-----------------------------------------------------------|------------------------------------------------------------------------------|---------------------|
|dummy_model_1|model        |sales       |Alice|How many stores of type ...?                               |Stores of type A receive code B ...                                           |change to incremental|
|dummy_model_1|model        |sales       |Alice|How many stores of type ...?                               |Consider only stores open after ...                                           |change to incremental|
|dummy_model_1|model        |sales       |Alice|How many stores in ...?                                    |Stores of type A receive code B ...                                           |change to incremental|
|dummy_model_1|model        |sales       |Alice|How many stores in ...?                                    |Consider only stores open after ...                                           |change to incremental|
|dummy_model_2|model        |people      |Bob  |How many employees ...?                                    |Not defined                                                                   |Not defined          |
|dummy_seed   |seed         |sales       |Carl |Not defined                                                |Not defined                                                                   |Not defined          |
|metadata_view|model |Not defined    |Not defined   |Not defined|Not defined                                                  |Not defined                                                                     |                         |

## undefined_as_null
You can also set the undefined metadata to appear as null values with ```undefined_as_null````
```sql
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
        ]
        , show_resource_type = True
        , undefined = "Not defined"
        , undefined_as_null = True
)}}
```

The undefined metadata are displayed as null.

|resource_name    |resource_type|main_subject|owner|business_questions                                         |business_rules                                                                |todos                |
|-------------|-------------|------------|-----|-----------------------------------------------------------|------------------------------------------------------------------------------|---------------------|
|dummy_model_1|model        |sales       |Alice|How many stores of type ...?                               |Stores of type A receive code B ...                                           |change to incremental|
|dummy_model_1|model        |sales       |Alice|How many stores of type ...?                               |Consider only stores open after ...                                           |change to incremental|
|dummy_model_1|model        |sales       |Alice|How many stores in ...?                                    |Stores of type A receive code B ...                                           |change to incremental|
|dummy_model_1|model        |sales       |Alice|How many stores in ...?                                    |Consider only stores open after ...                                           |change to incremental|
|dummy_model_2|model        |people      |Bob  |How many employees ...?                                    |                                                                              |                     |
|dummy_seed   |seed         |sales       |Carl |                                                           |                                                                              |                     |
|metadata_view|model |    |   ||                                                  |                                                                     |                         |

## resource_path
You can select the resources which you can include the metadata by their paths with the ```resource_path```argument, such as
```sql
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
        ]
        , show_resource_type = True
        , undefined = "Not defined"
        , undefined_as_null = True
        , contains_resource_path[
            "models/dummy_models/"
            , "seeds/"
        ]
)}}
```
Now the metadata_view was removed because it is not in the provided paths.
| node_name     | resource_type | main_subject | owner | business_questions           | business_rules                      | todos                 |
|---------------|---------------|--------------|-------|------------------------------|-------------------------------------|-----------------------|
| dummy_model_1 | model         | sales        | Alice | How many stores of type ...? | Stores of type A receive code B ... | change to incremental |
| dummy_model_1 | model         | sales        | Alice | How many stores of type ...? | Consider only stores open after ... | change to incremental |
| dummy_model_1 | model         | sales        | Alice | How many stores in ...?      | Stores of type A receive code B ... | change to incremental |
| dummy_model_1 | model         | sales        | Alice | How many stores in ...?      | Consider only stores open after ... | change to incremental |
| dummy_model_2 | model         | people       | Bob   | How many employees ...?      |                                     |                       |
| dummy_seed    | seed          | sales        | Carl  |                              |                                     |                       |


## resource_name_contains
You can select the resources which contains in their names at least one of the strings provided in the ```resource_name_contains```argument, such as
```sql
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
        ]
        , show_resource_type = True
        , undefined = "Not defined"
        , undefined_as_null = True
        , resource_name_contains = [
            '1'
            , 'seed'
        ]
)}}
```
Now the metadata_view was removed because it is not in the provided paths.
| resource_name | resource_type | main_subject | owner | business_questions           | business_rules                      | todos                 |
|---------------|---------------|--------------|-------|------------------------------|-------------------------------------|-----------------------|
| dummy_model_1 | model         | sales        | Alice | How many stores of type ...? | Stores of type A receive code B ... | change to incremental |
| dummy_model_1 | model         | sales        | Alice | How many stores of type ...? | Consider only stores open after ... | change to incremental |
| dummy_model_1 | model         | sales        | Alice | How many stores in ...?      | Stores of type A receive code B ... | change to incremental |
| dummy_model_1 | model         | sales        | Alice | How many stores in ...?      | Consider only stores open after ... | change to incremental |
| dummy_seed    | seed          | sales        | Carl  |                              |                                     |                       |

# ToDos
* Implement CI
* Create PR template
