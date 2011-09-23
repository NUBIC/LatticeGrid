#migration_helper.rb
module MigrationHelper

  def add_foreign_key(from_table, from_column, to_table, options = {})
    column_name=options[:column_name] if options[:column_name]
    constraint_name = foreignkey_name(from_table, to_table, column_name)
    column_name ||= foreignkey_column_name(from_table, from_column)

    execute %{alter table #{to_table} add #{column_name} INT not null} if options[:add_column]
  # does not work for PostgreSQL
#    execute %{alter table #{to_table}
#              add constraint #{constraint_name} foreign key
#              #{index_name(column_name)} (#{column_name}) references #{from_table}(#{from_column})
 #             #{ options[:cascade].map{ |cas| " ON #{cas} CASCADE" }.join if options[:cascade] }
#             }
     execute %{alter table #{to_table}
               add constraint #{constraint_name} foreign key
               (#{column_name}) references #{from_table}(#{from_column})
               #{ options[:cascade].map{ |cas| " ON #{cas} CASCADE" }.join if options[:cascade] }
              }
  end

  def drop_foreign_key(from_table, from_column, to_table, options = {})
    column_name=options[:column_name] if options[:column_name]
    constraint_name = foreignkey_name(from_table, to_table, column_name)
    column_name ||= foreignkey_column_name(from_table, from_column)
  
      # does not work for PostgreSQL
    #    execute %{alter table #{to_table} drop foreign key #{constraint_name}}
    execute %{alter table #{to_table} drop constraint #{constraint_name}}
    execute %{alter table #{to_table} drop #{column_name}} if options[:remove_column]
  end

  def create_index(table, *columns)
    execute %{create index #{index_name(columns)} on #{table} (#{columns.join(',')}) }
  end

  def drop_index(table, *columns)
    execute %{drop index #{index_name(columns)}on #{table}}
  end

  private
  def foreignkey_column_name(from_table, from_column)
    "#{from_table.to_s.singularize}_#{from_column}"
  end

  def foreignkey_name(from_table, to_table, column_name="")
    column_name="_"+column_name if !column_name.blank?
    "fk_#{from_table}_to_#{to_table}#{column_name}"
  end

  def index_name(*columns)
    "idx_#{columns.join('_')}"
  end
end