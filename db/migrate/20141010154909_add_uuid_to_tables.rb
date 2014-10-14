class AddUuidToTables < ActiveRecord::Migration
  def change
  	add_column :investigators, :uuid, :string
  	add_column :investigator_appointments, :uuid, :string
  	add_column :organizational_units, :uuid, :string
  end
end
