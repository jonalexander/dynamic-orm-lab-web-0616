require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    # call this whenever referencing the table in SQL code
    self.to_s.downcase.pluralize
  end

  def table_name_for_insert
    # instance method - need to grab the name of the class you're working within
    # manipulate to lower case & plural by way of table_name method
    self.class.table_name
    # Student => students
  end
  
  def self.column_names
    DB[:conn].results_as_hash = true

    # 'pragma table_info('students')
    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []

    #iterate over each hash, grab corresponding value for 'name' key
    table_info.each { |row| column_names << row["name"] }
    #remove nil values & return array
    column_names.compact
  end

  def initialize(attributes = {})
    # iterate over the hash and create the instance variables
    # {name: 'bob'} # => Student.new.send("name=", 'bob')
    # => <Student..@name='bob'...>
    attributes.each { |property, value| self.send("#{property}=", value) }
  end

  def self.find_by_name(name)
    #class method, self
    sql = "select * from #{self.table_name} where name = ?;"
    row = DB[:conn].execute(sql, name) # => return [{...}]
  end

  def col_names_for_insert
    self.class.column_names.delete_if { |col_name| col_name == 'id'}.join(', ')
    # iterate over array of col names, remove id
    # join remaining col names as string for insertion into SQL code
  end

  def values_for_insert
    values = []

    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end

    values.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by(attribute)
    DB[:conn].results_as_hash = true
    #attribute = {name: "Susan"}
    attr_key = attribute.keys.first
    # => "name"
    attr_value = attribute.values.first
    # => "Susan"

    # if attr_value is a Fixnum... keep it
    # otherwise alter it for insertion into SQL code

    # attr_value = 1
    if attr_value.class == Fixnum
      attr_value
    else
      attr_value = "'#{attr_value}'"
      # needs extra ''
    end

    sql = "select * from #{self.table_name} WHERE #{attr_key} = #{attr_value};"
    # =>                       students              name           Susan
    # =>                       students              grade          10
    #binding.pry
    row = DB[:conn].execute(sql)


  end
end