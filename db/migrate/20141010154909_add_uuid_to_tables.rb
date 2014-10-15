class AddUuidToTables < ActiveRecord::Migration
  def change
  	add_column :investigators, :uuid, :string
  	add_column :investigator_appointments, :uuid, :string
  	add_column :organizational_units, :uuid, :string
  	add_column :abstracts, :uuid, :string
  	add_column :investigator_abstracts, :uuid, :string
  end
end
