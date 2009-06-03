class CreateProgramAbstracts < ActiveRecord::Migration
  def self.up
    create_table :program_abstracts do |t|
      t.column :program_id, :integer, :null => false #now in the add_foreign_key call
      t.column :abstract_id, :integer, :null => false #now in the add_foreign_key call
      t.column :start_date, :date
      t.column :end_date, :date
      t.timestamps
    end
  end

  def self.down
    begin
      drop_table :program_abstracts
    rescue
      puts "unable to drop program_abstracts. Probably doesn't exist"
    end
  end
end

