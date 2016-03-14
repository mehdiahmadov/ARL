require_relative 'db_connection'
require_relative 'sql_object'

module Searchable
  def where(params)
    where_line = params.map{|k, v| k.to_s + "=?"}.join(" AND ")
    attr_values = params.values
    results = DBConnection.execute(<<-SQL, *attr_values)
      SELECT
        *
      FROM
        '#{table_name}'
      WHERE
        #{where_line}
    SQL
    self.parse_all(results)
  end
end

class SQLObject
  extend Searchable
end
