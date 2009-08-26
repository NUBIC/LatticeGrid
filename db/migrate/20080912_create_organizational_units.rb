class CreatePrograms < ActiveRecord::Migration
  def self.up
    create_table :programs do |t|
       t.column :program_number, :integer, :null => false
       t.column :parent_id, :integer
       t.column :depth, :integer, :default => 0
       t.column :program_abbrev, :string
       t.column :program_title, :string 
       t.column :program_category, :string 
       t.column :start_date, :date
       t.column :end_date, :date
       t.timestamps
    end

  end

  def self.down
    drop_table :programs
  end
end

