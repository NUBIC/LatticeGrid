class CreateOrganizationAbstracts < ActiveRecord::Migration
  def self.up
    create_table :organization_abstracts do |t|
      t.column :organizational_unit_id, :integer, :null => false #now in the add_foreign_key call
      t.column :abstract_id, :integer, :null => false #now in the add_foreign_key call
      t.column :start_date, :date
      t.column :end_date, :date
      t.timestamps
    end
  end

  def self.down
    begin
      drop_table :organization_abstracts
    rescue Exception => error
      puts "unable to drop organization_abstracts. Probably doesn't exist"
    end
  end
end

