class AddUuidToTables < ActiveRecord::Migration
  def change
    add_column :investigators, :uuid, :string
    add_column :investigator_appointments, :uuid, :string
    add_column :organizational_units, :uuid, :string
    add_column :abstracts, :uuid, :string
    add_column :investigator_abstracts, :uuid, :string

    add_index :investigators, :uuid, :unique => true
    add_index :investigator_appointments, :uuid, :unique => true
    add_index :organizational_units, :uuid, :unique => true
    add_index :abstracts, :uuid, :unique => true
    add_index :investigator_abstracts, :uuid, :unique => true
  end
end
