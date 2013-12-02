class ResetDefaultIdValues < ActiveRecord::Migration

  def tables
    [
      :abstracts,
      :investigator_appointments,
      :organizational_units,
      :investigators,
      :investigator_abstracts,
      :investigator_colleagues,
      :investigator_proposals,
      :investigator_studies,
      :journals,
      :load_dates,
      :logs,
      :organization_abstracts,
      :proposals,
      :studies,
      :word_frequencies,
    ]
  end

  def up
    tables.each do |table|
      # change_column_default(table, :id, "nextval('#{table.to_s}_id_seq'::regclass)")
      execute "ALTER TABLE #{table} ALTER COLUMN id SET DEFAULT NEXTVAL('#{table}_id_seq'::regclass);"
    end
  end

  def down
    tables.each do |table|
      change_column_default(table, :id, 0)
    end
  end
end
