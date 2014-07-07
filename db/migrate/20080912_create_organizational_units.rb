class CreateOrganizationalUnits < ActiveRecord::Migration
  def self.up
    create_table :organizational_units do |t|
      t.string :name, :null => false #full common name
      t.string :search_name #for searching
      t.string :abbreviation  #short name
      t.string :campus
      t.string :organization_url  #home url
      t.string :type, :null => false #School, Department, Division, Program, Center, Institute, Core
      t.string :organization_classification #Research, Basic, Clinical, ??
      t.string :organization_phone
      t.integer :department_id, :null => false, :default=>0 # points to institutional identifier
      t.integer :division_id, :default=>0
      t.integer :member_count, :default => 0
      t.integer :appointment_count, :default => 0
      t.integer :lft
      t.integer :rgt
      t.integer :children_count, :default => 0
      t.integer :sort_order, :default => 1
      t.integer :parent_id
      t.integer :depth, :default => 0
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
    add_index :organizational_units, [:department_id, :division_id], :unique => true
  end

  def self.down
    drop_table :organizational_units
  end
end
