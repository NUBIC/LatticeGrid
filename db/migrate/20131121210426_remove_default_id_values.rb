class RemoveDefaultIdValues < ActiveRecord::Migration
  def up
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
    ].each do |table|
      change_column_default(table, :id, nil)
    end
  end

  def down
  end
end
