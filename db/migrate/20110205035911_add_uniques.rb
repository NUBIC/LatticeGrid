class AddUniques < ActiveRecord::Migration
  def self.up
    add_index(:investigator_abstracts, [:abstract_id, :investigator_id], :unique=>true, :name => 'by_asbtract_investigator_unique')
    add_index(:investigator_appointments, [:organizational_unit_id, :investigator_id, :type], :unique=>true, :name => 'by_unit_investigator_unique')
    add_index(:organization_abstracts, [:organizational_unit_id, :abstract_id], :unique=>true, :name => 'by_unit_abstract_unique')
    add_index(:investigators, [:faculty_keywords,:faculty_interests], :name => 'by_keywords_summary_interests')
    # pulled out research_summary - too many large inserts to build an index
  end

  def self.down
    remove_index :investigator_abstracts, :name => 'by_asbtract_investigator_unique'
    remove_index :investigator_appointments, :name => 'by_unit_investigator_unique'
    remove_index :organization_abstracts, :name => 'by_unit_abstract_unique'
    remove_index :investigators, :name => 'by_keywords_summary_interests'
  end
end
