class RemoveDefaultIdValues < ActiveRecord::Migration

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
      change_column_default(table, :id, nil)
    end
  end

  def down
    tables.each do |table|
      change_column_default(table, :id, 0)
    end
  end
end
