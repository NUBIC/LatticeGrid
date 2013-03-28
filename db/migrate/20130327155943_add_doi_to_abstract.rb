class AddDoiToAbstract < ActiveRecord::Migration
  def self.up
    add_column :abstracts, :doi, :string, :unique => true
    add_index(:abstracts, [:pubmed, :doi], :unique=>true, :name => 'by_pubmed_doi_unique')
  end

  def self.down
    remove_column :abstracts, :doi
    remove_index :abstracts, :name => 'by_pubmed_doi_unique'
  end
end
