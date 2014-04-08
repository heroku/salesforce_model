# SalesforceModel

Utility class to make it easy to use _ActiveRecord_ to access your Herok Connect
tables.

## Installation

    gem install salesforce_model

    export HEROKUCONNECT_URL=<database url>
    export HEROKUCONNET_SCHEMA=<schema name>

## Usage

Just inherit from SalesforceModel naming your class after the sync table:

    require 'salesforce_model'

    class Account < SalesforceModel
    end

For quick boostrapping in the Rails console, use `reflect_models`:

    > require 'salesforce_model'
    > SalesforceModel.reflect_models
    Account
    Contact
    Lead

    > Lead.count
    234

## Useful operations

### Working with the trigger log

A model class `SalesforceModel::TriggerLog` is available for querying records from the
Heroku Connect trigger log table. The `SalesforceModel` base class also includes some
utility functions for working with the data in that table.

> `SaleforceModel.recent_updates` 

Display recent updates recorded in the trigger log in tabular format.

> `SalesforceModel.recent_changes`

Return recent instances of SalesforceModel::TriggerLog

> `SalesforceModel.pending_changes`

Return all unprocessed rows from SalesforceModel::TriggerLog

> `SalesforceModel.pending_count`

Return the count of pending changes from the trigger log.

> `SalesforceModel.all_errors`

Return all errored changes from the trigger log


### Showing per-model change information

> `<model class>.recent_updates`

Print recent trigger log entries for the given record.

> `<model class>.pending_updates`

Print pending trigger log entries for the given record.


> `<model class>.salesforce_error`

Return the last error message marked for a given record.

Example:

<pre>
> c = Contact.create() # no required fields provided
 
> SalesforceModel.pending_changes
[#TriggerLog id:1, table_name="contact", state:"NEW", ...]

> c.pending_updates
| state |   op   | table   | id |
----------------------------------
| NEW   | insert | contact | 1  |

> ...

> c.pending_updates
nil

> c.recent_updates
| state  |   op   | table   | id | sf_msg
----------------------------------
| FAILED | insert | contact | 1  | Salesforce error: 'Required fields are missing: [LastName]'


> c.salesforce_error
=> "Salesforce error: 'Required fields are missing: [LastName]'" 

> c.lastname = "Persinger"
> c.save()

> c.pending_updates
| state |   op   | table   | id | lastname |
---------------------------------------------
| NEW   | update | contact | 1  | Persinger |


> c.reload
> c.sfid
=> "001G000001JkRUiIAN" 
</pre>



