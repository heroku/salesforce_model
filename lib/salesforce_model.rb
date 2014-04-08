require 'active_record'

# Abstract ActiveRecord subclass for easy access to Heroku Connect tables.
# To use, just inherit your model class from this class:
# 
#     require 'salesforce_model' 
#
#     class Account << SalesforceModel
#     end
#
# You must set <tt>HEROKUCONNECT_URL</tt> and <tt>HEROKUCONNNECT_SCHEMA</tt> in your environment
# to point to your Heroku Connect database.
#
# For simple interactive usage, you can call <tt>reflect_models</tt>. This will
# introspect your database and automatically create AR models for the tables
# that it finds.

class SalesforceModel < ActiveRecord::Base
  if ENV['HEROKUCONNECT_URL'].nil?
    raise "Please set HEROKUCONNECT_URL in your environment to use SalesforceModel"
  end
  if ENV['HEROKUCONNECT_SCHEMA'].nil?
    raise "Please set HEROKUCONNECT_SCHEMA in your environment to use SalesforceModel"
  end

  establish_connection ENV['HEROKUCONNECT_URL']

  cattr_accessor :schema_name
  self.schema_name = ENV['HEROKUCONNECT_SCHEMA'] || 'public'
  self.connection.schema_search_path = self.schema_name + ",public"

  self.abstract_class = true

  def self.table_name
    return self.schema_name + '.' + self.name.downcase
  end

  # Introspect tables from the active schema and generate SalesforceModel subclasses
  # for each table. This is meant for quick bootstrapping models at the Rails console.
  def self.reflect_models
  	self.connection.tables.each do |table|
  		next if table.starts_with?("_") || table.starts_with?("c5")
  		next if !self.connection.table_exists?(self.schema_name + "." + table)
  		klass = table.dup
  		klass[0] = klass[0].capitalize
  		if !Object.const_defined?(klass)
  			Object.const_set(klass, Class.new(SalesforceModel))
  			puts klass
  		end
  	end
	nil
  end

end

