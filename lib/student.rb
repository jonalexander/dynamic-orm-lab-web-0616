require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
  self.column_names.each { |column_name| attr_accessor column_name.to_sym }
end
