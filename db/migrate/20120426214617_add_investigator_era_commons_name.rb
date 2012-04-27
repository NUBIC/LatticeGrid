class AddInvestigatorEraCommonsName < ActiveRecord::Migration
  def self.up
    add_column :investigators, :era_comons_name, :string
    add_index(:investigators, [:era_comons_name], :name => 'by_era_comons_name_unique', :unique=>true)
  end

  def self.down
    remove_index :investigators, :name => 'by_era_comons_name_unique'
    remove_column :investigators, :era_comons_name
  end
end

