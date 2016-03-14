require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject
  def self.columns
    @columns ||= DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        '#{table_name}'
    SQL
    @columns.first.map { |column| column.to_sym  }
  end

  def self.finalize!
    self.columns.each do |attr|
        define_method("#{attr}") do
          self.attributes[attr]
        end
        define_method("#{attr}=") do |value|
          self.attributes[attr] = value
        end
    end
  end

  def self.table_name=(table_name)
     @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.underscore.pluralize
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
    SELECT
      *
    FROM
      '#{table_name}'
    SQL
    self.parse_all(results)
  end

  def self.parse_all(results)
    objs = []
    results.each do |row|
      objs << self.new(row)
    end
    objs
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
    SELECT
      *
    FROM
      '#{table_name}'
    WHERE
      id = :id
    LIMIT 1
    SQL
    return nil if result.empty?
    self.new(result.first)
  end

  def initialize(params = {})
    params.each do |key, value|
      raise "unknown attribute '#{key}'" unless self.class.columns.include?(key.to_sym)
    end
    self.class.finalize!
    params.each do |key, value|
      self.send("#{key}=".to_sym, value)
    end

  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.attributes.values
  end

  def insert
    col_names = self.class.columns.drop(1).join(",")
    question_marks = (["?"] * self.attributes.count).join(",")

    DBConnection.execute(<<-SQL, *attribute_values)
    INSERT INTO
      '#{self.class.table_name}' (#{col_names})
    VALUES
      (#{question_marks})
    SQL
    self.attributes[:id] = DBConnection.last_insert_row_id
  end

  def update
    col_names = self.class.columns.drop(1).map{|val| val.to_s + "=?"}.join(",")
    update_vals = attribute_values
    id = update_vals.shift

    DBConnection.execute(<<-SQL, *update_vals, id)
    UPDATE
      '#{self.class.table_name}'
    SET
      #{col_names}
    WHERE
      id = :id
    SQL

  end

  def save
    self.id.nil? ? self.insert : self.update
  end
end
