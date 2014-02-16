class AddOrganizationPubmedSearchName < ActiveRecord::Migration
  def self.up
    add_column :organizational_units, :pubmed_search_name, :string
  end

  def self.down
    remove_column :organizational_units, :pubmed_search_name
  end
end
