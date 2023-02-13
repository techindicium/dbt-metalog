# :notebook: dbt-metalog: Your metadata's catalog

Have you ever found yourself jotting down essential business rules, questions, technical owners, or ToDos in a **separate Excel sheet  - far from your code -, only to forget about them later?**

Do you **struggle to keep track of all the metadata** that's critical for effective data management and analysis?

Worry no more! We have a solution - dbt-metalog.

**Create light customizable models from your metadata.**

**Easily create models for:**

:white_check_mark: Business rules.

:white_check_mark: Business questions.

:white_check_mark: Tech owners.

:white_check_mark: Requesting areas/persons.

:white_check_mark: Date the model was created.

:white_check_mark: ToDo's.

:white_check_mark: Any metadata you want...

**Choose your metadata by:**

:white_check_mark: name.

:white_check_mark: resource type.

:white_check_mark: file.

# :mag_right: Content
* :running: [Quickstart](#running-quickstart)
* * [Requirements](#requirements)
* * [Installation](#installation)
* * [Package Limitations](#package-limitations)
* :gear: [Macros](#gear-macros)
* * [{{ create_metadata_model( ) }}](#create_metadata_model-source)
* * [{{ create_description_model( ) }}](#create_description_model-source)
* :wrench: [Troubleshooting](#wrench-troubleshooting)
* :writing_hand: [ToDos](#writing_hand-todos)



# :running: Quickstart

New to dbt packages? Read more about them [here](https://docs.getdbt.com/docs/building-a-dbt-project/package-management/).

## Requirements
dbt version
* ```dbt version >= 1.0.0```

## Installation

1. Include this package in your `packages.yml` file.
```yaml
packages:
  - package: techindicium/dbt-metalog
    version: 1.0.0
```

2. Run `dbt deps` to install the package.

## Package Limitations
> **Warning** If your project is too large (too many models with too many metadata), there is a chance the generated SQL by the macros exceed the query length limit of your DW. Then you will get an error.




# :gear: Macros
## create_metadata_model ([source](macros/create_metadata_model.sql))

This macro generates SQL for creating **customizable tables or views from the [metadata](https://docs.getdbt.com/reference/resource-configs/meta) of your nodes and sources**. You have the **flexibility to select the specific metadata** you want to include in your table or view. If a node **does not contain the specified metadata, it will be displayed as "Undefined"**, but you can alter this default text to your preference.

> **Note** For this README, every time you see "node" consider also "sources"

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
  - ```files```(optional) (default = []): A ```list``` of regex specifying the files to include, e.g. If you want to include all files in models, then ```files=['models/.*']```.
  - ```exclude_files```(optional) (default = []): A ```list``` of regex specifying the files to exclude, e.g. If you want to exclude all staging files, then ```files=['.*stg_.*']```.

### Usage

#### Define the metadata in your nodes
So, for example take a look at the [dummy_model_1](https://github.com/techindicium/dbt-metalog/blob/main/integration_tests/models/dummy_models/dummy_model_1.sql) inside the ```integration_tests``` folder

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
        , 'todos': 'change to incremental'
    }
)}}

select 1 as dummy
```

#### Create a model which uses the ```create_metadata_model``` macro.

Use the ```create_metadata_model``` macro passing as argument a list of the metadata you want to include in your model. Let's see the [01_metadata_test](https://github.com/techindicium/dbt-metalog/blob/main/integration_tests/models/metadata_tests/01_metadata_test.sql) model (You can create a model with any name you want) as an example:
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

#### Run your model
Just run it!
```shell
dbt run -s metadata_view
```

> **Note** Suppose we have the following nodes in our project: [dummy_model_1](https://github.com/techindicium/dbt-metalog/blob/main/integration_tests/models/dummy_models/dummy_model_1.sql), [dummy_model_2](https://github.com/techindicium/dbt-metalog/blob/main/integration_tests/models/dummy_models/dummy_model_2.sql) and [dummy_seed](https://github.com/techindicium/dbt-metalog/blob/main/integration_tests/seeds/dummy_seed.csv)


The output view, using the meta defined in our nodes will be:

| **resource_name** | **resource_type** | **main_subject** | **owner** | **business_questions**                                        | **business_rules**                                                               | **todos**             |
|-------------------|-------------------|------------------|-----------|---------------------------------------------------------------|----------------------------------------------------------------------------------|-----------------------|
| dummy_model_1     | model             | sales            | Alice     | "['How many stores of type ...?', 'How many stores in ...?']" | "['Stores of type A receive code B ...', 'Consider only stores open after ...']" | change to incremental |
| dummy_model_2     | model             | people           | Bob       | How many employees ...?                                       | Undefined                                                                        | Undefined             |



## Additional customization

### granularity

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

| **resource_name** | **resource_type** | **main_subject** | **owner** | **business_questions**       | **business_rules**                                                               | **todos**             |
|-------------------|-------------------|------------------|-----------|------------------------------|----------------------------------------------------------------------------------|-----------------------|
| dummy_model_1     | model             | sales            | Alice     | How many stores of type ...? | "['Stores of type A receive code B ...', 'Consider only stores open after ...']" | change to incremental |
| dummy_model_1     | model             | sales            | Alice     | How many stores in ...?      | "['Stores of type A receive code B ...', 'Consider only stores open after ...']" | change to incremental |
| dummy_model_2     | model             | people           | Bob       | How many employees ...?      | Undefined                                                                        | Undefined             |



You can pass more than one metadata to the ```granularity_list```, for example:

[02_metadata_test_with_granularity](https://github.com/techindicium/dbt-metalog/blob/main/integration_tests/models/metadata_tests/02_metadata_test_with_granularity.sql)
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

| **resource_name** | **resource_type** | **main_subject** | **owner** | **business_questions**       | **business_rules**                  | **todos**             |
|-------------------|-------------------|------------------|-----------|------------------------------|-------------------------------------|-----------------------|
| dummy_model_1     | model             | sales            | Alice     | How many stores of type ...? | Stores of type A receive code B ... | change to incremental |
| dummy_model_1     | model             | sales            | Alice     | How many stores of type ...? | Consider only stores open after ... | change to incremental |
| dummy_model_1     | model             | sales            | Alice     | How many stores in ...?      | Stores of type A receive code B ... | change to incremental |
| dummy_model_1     | model             | sales            | Alice     | How many stores in ...?      | Consider only stores open after ... | change to incremental |
| dummy_model_2     | model             | people           | Bob       | How many employees ...?      | Undefined                           | Undefined             |



### resource_type
You can ask the macro to include metadata of more resource types with the ```resource_type```argument. Let's include ```seeds``` along with models.

[03_metadata_test_resource_type](https://github.com/techindicium/dbt-metalog/blob/main/integration_tests/models/metadata_tests/03_metadata_test_resource_type.sql)
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
| **resource_name** | **resource_type** | **main_subject** | **owner** | **business_questions**       | **business_rules**                  | **todos**             |
|-------------------|-------------------|------------------|-----------|------------------------------|-------------------------------------|-----------------------|
| dummy_model_1     | model             | sales            | Alice     | How many stores of type ...? | Stores of type A receive code B ... | change to incremental |
| dummy_model_1     | model             | sales            | Alice     | How many stores of type ...? | Consider only stores open after ... | change to incremental |
| dummy_model_1     | model             | sales            | Alice     | How many stores in ...?      | Stores of type A receive code B ... | change to incremental |
| dummy_model_1     | model             | sales            | Alice     | How many stores in ...?      | Consider only stores open after ... | change to incremental |
| dummy_model_2     | model             | people           | Bob       | How many employees ...?      | Undefined                           | Undefined             |
| dummy_seed        | seed              | sales            | Carl      | Undefined                    | Undefined                           | Undefined             |


### show_resource_type

You can hide the ```resource_type``` column passing the argument ```show_resource_type=False```

[04_metadata_test_show_resource_type](https://github.com/techindicium/dbt-metalog/blob/main/integration_tests/models/metadata_tests/04_metadata_test_show_resource_type.sql)
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

| **resource_name** | **main_subject** | **owner** | **business_questions**       | **business_rules**                  | **todos**             |
|-------------------|------------------|-----------|------------------------------|-------------------------------------|-----------------------|
| dummy_model_1     | sales            | Alice     | How many stores of type ...? | Stores of type A receive code B ... | change to incremental |
| dummy_model_1     | sales            | Alice     | How many stores of type ...? | Consider only stores open after ... | change to incremental |
| dummy_model_1     | sales            | Alice     | How many stores in ...?      | Stores of type A receive code B ... | change to incremental |
| dummy_model_1     | sales            | Alice     | How many stores in ...?      | Consider only stores open after ... | change to incremental |
| dummy_model_2     | people           | Bob       | How many employees ...?      | Undefined                           | Undefined             |
| dummy_seed        | sales            | Carl      | Undefined                    | Undefined                           | Undefined             |


### undefined
You can override the default 'Undefined' string with ```undefined```.

[05_metadata_test_undefined](https://github.com/techindicium/dbt-metalog/blob/main/integration_tests/models/metadata_tests/05_metadata_test_undefined.sql)
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
| **resource_name** | **resource_type** | **main_subject** | **owner** | **business_questions**       | **business_rules**                  | **todos**             |
|-------------------|-------------------|------------------|-----------|------------------------------|-------------------------------------|-----------------------|
| dummy_model_1     | model             | sales            | Alice     | How many stores of type ...? | Stores of type A receive code B ... | change to incremental |
| dummy_model_1     | model             | sales            | Alice     | How many stores of type ...? | Consider only stores open after ... | change to incremental |
| dummy_model_1     | model             | sales            | Alice     | How many stores in ...?      | Stores of type A receive code B ... | change to incremental |
| dummy_model_1     | model             | sales            | Alice     | How many stores in ...?      | Consider only stores open after ... | change to incremental |
| dummy_model_2     | model             | people           | Bob       | How many employees ...?      | Not defined                         | Not defined           |
| dummy_seed        | seed              | sales            | Carl      | Not defined                  | Not defined                         | Not defined           |


### undefined_as_null
You can also set the undefined metadata to appear as null values with ```undefined_as_null```

[06_metadata_test_undefined_as_null](https://github.com/techindicium/dbt-metalog/blob/main/integration_tests/models/metadata_tests/06_metadata_test_undefined_as_null.sql)
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

| **resource_name** | **resource_type** | **main_subject** | **owner** | **business_questions**       | **business_rules**                  | **todos**             |
|-------------------|-------------------|------------------|-----------|------------------------------|-------------------------------------|-----------------------|
| dummy_model_1     | model             | sales            | Alice     | How many stores of type ...? | Stores of type A receive code B ... | change to incremental |
| dummy_model_1     | model             | sales            | Alice     | How many stores of type ...? | Consider only stores open after ... | change to incremental |
| dummy_model_1     | model             | sales            | Alice     | How many stores in ...?      | Stores of type A receive code B ... | change to incremental |
| dummy_model_1     | model             | sales            | Alice     | How many stores in ...?      | Consider only stores open after ... | change to incremental |
| dummy_model_2     | model             | people           | Bob       | How many employees ...?      |                                     |                       |
| dummy_seed        | seed              | sales            | Carl      |                              |                                     |                       |


### files
You can select the files you want to include (```files```) or to exclude (```exclude_files```)

[07_metadata_test_files](https://github.com/techindicium/dbt-metalog/blob/main/integration_tests/models/metadata_tests/07_metadata_test_files.sql)
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
                , "source"
        ]
        , show_resource_type = True
        , undefined = "Not defined"
        , undefined_as_null = True
        , files = [
            "models/.*"
            , "seeds/.*"
            , ".*/source.yml"
        ]
        , exclude_files = [
            'models/metadata_tests/.*'
            'models/description_tests/.*'
        ]
)}}
```
| **resource_name** | **resource_type** | **main_subject** | **owner** | **business_questions**       | **business_rules**                  | **todos**             |
|-------------------|-------------------|------------------|-----------|------------------------------|-------------------------------------|-----------------------|
| dummy_model_1     | model             | sales            | Alice     | How many stores of type ...? | Stores of type A receive code B ... | change to incremental |
| dummy_model_1     | model             | sales            | Alice     | How many stores of type ...? | Consider only stores open after ... | change to incremental |
| dummy_model_1     | model             | sales            | Alice     | How many stores in ...?      | Stores of type A receive code B ... | change to incremental |
| dummy_model_1     | model             | sales            | Alice     | How many stores in ...?      | Consider only stores open after ... | change to incremental |
| dummy_model_2     | model             | people           | Bob       | How many employees ...?      |                                     |                       |
| dummy_seed        | seed              | sales            | Carl      |                              |                                     |                       |
| raw               | source            |                  |           |                              |                                     |                       |


## create_description_model ([source](macros/create_description_model.sql))

This macro generates SQL for creating **tables or views from the description of your nodes and its columns**. You have the **flexibility to select the specific files** you want to include in your table or view.

The macro will check the description defined in your nodes. 

Nodes can be:
* Models
* Sources
* Seeds
* Snapshots
* Tests
* Analyses
* Macros

### Arguments
  - ```resource_type``` (optional) (default = ```['model']```): A ```list``` of the resource types you want to read the metadata from. Options:
    - model
    - source
    - seed
    - snapshot
    - tests
    - analysis
    - macros
  - ```show_resource_type```(optional) (default = ```True```): A ```boolean``` to show or hide the ```resource_type``` column in your resulting model.
  - ```files```(optional) (default = []): A ```list``` of regex specifying the files to include, e.g. If you want to include all files in models, then ```files=['models/.*']```.
  - ```exclude_files```(optional) (default = []): A ```list``` of regex specifying the files to exclude, e.g. If you want to exclude all staging files, then ```files=['.*stg_.*']```.

### Usage

#### Define the description of your nodes
So, for example take a look at the [dummy_model_2.yml](https://github.com/techindicium/dbt-metalog/blob/main/integration_tests/models/dummy_models/dummy_model_2.yml) inside the ```integration_tests``` folder

```yaml
version: 2

models:
  - name: 'dummy_model_2'
    description: "description of dummy_model_2"

    columns:
      - name: "dummy"
        description: "the description of the dummy column of dummy_model_2"
```

#### Create a model which uses the ```create_description_model``` macro.

Use the ```create_description_model``` macro passing the arguments of your choice

[description_test_files](https://github.com/techindicium/dbt-metalog/blob/main/integration_tests/models/description_tests/description_test_files.sql)
```sql
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
```

> **Note**: **The default materialization for dbt models is view. If you want to change to table, change the [```materialized``` configuration property ](https://docs.getdbt.com/docs/build/materializations).**

#### Run your model
Just run it!
```shell
dbt run -s metadata_view
```

> **Note** Suppose we have the following nodes in our project: [dummy_model_1](https://github.com/techindicium/dbt-metalog/blob/main/integration_tests/models/dummy_models/dummy_model_1.sql), [dummy_model_2](https://github.com/techindicium/dbt-metalog/blob/main/integration_tests/models/dummy_models/dummy_model_2.sql) and [dummy_seed](https://github.com/techindicium/dbt-metalog/blob/main/integration_tests/seeds/dummy_seed.csv)


The output view, using the meta defined in our nodes will be:

| **resource_name** | **resource_type** | **resource_description**     | **column_name** | **columns_description**                              |
|-------------------|-------------------|------------------------------|-----------------|------------------------------------------------------|
| dummy_model_1     | model             |                              | dummy           | the description of the dummy column of dummy_model_1 |
| dummy_model_2     | model             | description of dummy_model_2 | dummy           | the description of the dummy column of dummy_model_2 |


# :wrench: Troubleshooting
### Unclosed string literal
```
Database Error in model description_model (models/metadata_catalog/description_model.sql)
Syntax error: Unclosed string literal at [2473:196]
compiled Code at target/run/marketing_mas/models/metadata_catalog/description_model.sql
```
Check if there is a double quote in any of your descriptions. If so, remove it or replace by single quotes.

### The query is too large
```
Database Error in model description models_ view (models/metadata catalog/description models_ view.sql)
The query is too large. The maximum standard SQL query length is 1024.00K characters, including comments and white space characters.
compiled Code at target/run/marketing_mas/models/metadata_catalog/description_models_view.sql
```
It is a current limitation of the package. As it passes the metadata/descriptions to the SQL query, if there is a massive number of metadata/descriptions there is a chance the query exceeds the limits of your DW.

# :writing_hand: ToDos
* Implement CI
* Create PR template
* Workaround the query limit problem
