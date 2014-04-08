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

For quick boostrapping in the Rails console, you can do this:

    > require 'salesforce_model'
    > SalesforceModel.reflect_models
    Account
    Contact
    Lead

    > Lead.count
    234

