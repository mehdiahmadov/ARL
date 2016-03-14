require_relative 'associatable'

module Associatable

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through = self.class.assoc_options[through_name]
      source = through.model_class.assoc_options[source_name]

      through_table = through.table_name
      through_pk = through.primary_key
      through_fk = through.foreign_key

      source_table = source.table_name
      source_pk = source.primary_key
      source_fk = source.foreign_key

      key_val = self.send(through_fk)

      results = DBConnection.execute(<<-SQL, key_val)
      SELECT
        #{source_table}.*
      FROM
        #{through_table}
      JOIN
        #{source_table}
      ON
        #{through_table}.#{source_fk} = #{source_table}.#{source_pk}
      WHERE
        #{through_table}.#{through_pk} = ?
      SQL

      source.model_class.parse_all(results).first
    end
  end
end
