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
  cattr_accessor :schema_name
  self.schema_name = ENV['HEROKUCONNECT_SCHEMA'] || 'public'

  self.pluralize_table_names = false
  self.table_name_prefix = self.schema_name + "."


  establish_connection ENV['HEROKUCONNECT_URL']

  self.connection.schema_search_path = self.schema_name + ",public"

  self.abstract_class = true

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

  attr_protected :createddate, :systemmodstamp, :lastmodifieddate

  class TriggerLog < SalesforceModel
    self.table_name = superclass.schema_name + "._trigger_log"

    scope :pending, -> { where("state in ('PENDING','NEW')") }
    scope :completed, -> { where("state in ('SUCCESS','FAILED')") }
  end

  def self.all_errors
    TriggerLog.where(:state => 'FAILED').order("id DESC").all 
  end 

  def self.pending_count
    TriggerLog.where("state in ('PENDING','NEW')").count
  end

  def self.last_trigger_id
    row = SalesforceModel.connection.select_all("select * From _trigger_last_id")[0]
    if row
      row.values[0].to_i
    else
      nil
    end
  end

  def self.pending_changes
    TriggerLog.where("state in ('PENDING','NEW')")
  end

  def self.recent_changes
    TriggerLog.order("id DESC").limit(10).all
  end

  def self.format_trigger_log_rows(rows)
    require 'text-table'

    tables = Hash.new {|hash,key| hash[key] = Text::Table.new}
    rows.each do |tl|
      table = tables[tl.table_name]
      data = eval("{#{tl.values.gsub(/NULL/,'nil')}}")
      header = ['log id', 'state','op','table','rec id']
      row = [tl.id, tl.state, tl.action, tl.table_name, tl.record_id]
      data.keys.sort.each do |key|
        next if key == '_c5_source'
        header.append(key[0,8])
        row.append(data[key])
      end
      header.append('sf_msg')
      row.append(tl.sf_message)

      table.head ||= header
      table.rows.append(row)
    end

    tables.each do |table|
      puts table
      puts
    end

    nil
  end

  def self.recent_updates(table = nil, limit=10)
    self.format_trigger_log_rows(TriggerLog.order("id DESC").limit(limit))
  end

  def pending_updates
    rows = TriggerLog.pending.where(:record_id => self.id)
    SalesforceModel.format_trigger_log_rows(rows)
  end

  def recent_updates
    SalesforceModel.format_trigger_log_rows(TriggerLog.where(:record_id => self.id).order("id DESC").limit(10))
  end

  def salesforce_errors
    TriggerLog.where(:record_id => self.id, :state => 'FAILED').order("id DESC").all 
  end 

  def salesforce_error
    log = TriggerLog.where(:record_id => self.id, :state => 'FAILED').order("id DESC").last
    if !log.nil?
      return log.sf_message
    end
  end 

end

