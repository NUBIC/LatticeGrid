
class CreateInvestigatorPrograms < ActiveRecord::Migration
  def self.up
    create_table :investigator_programs do |t|
      #add_foreign_key (:mainentity, :mainentity_id, secundaryentity)
      #add_foreign_key(:investigators, :id, :investigator_programs, :add_column)
      #add_foreign_key(:programs, :id, :investigator_programs, :add_column)
      t.column :program_id, :integer, :null => false
      t.column :investigator_id, :integer, :null => false
      t.column :program_appointment, :string 
      t.column :start_date, :date
      t.column :end_date, :date
      t.timestamps
    end
  end

  def self.down
    drop_table :investigator_programs
  end
end
