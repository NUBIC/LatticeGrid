class CreateProposals < ActiveRecord::Migration
  def self.up
    create_table :proposals do |t|
      t.column :sponsor_award_number, :string 
      t.column :sponsor_code, :string 
      t.column :sponsor_name, :string 
      t.column :institution_award_number, :string 
      t.column :title, :string 
      t.column :abstract, :text
      t.column :keywords, :text
      t.column :agency, :string
      t.column :submission_date, :date # DP: pubmed YYYY/MM/DD
      t.column :award_date, :date # DP: pubmed YYYY/MM/DD
      t.column :project_start_date, :date # DP: pubmed YYYY/MM/DD
      t.column :project_end_date, :date # DP: pubmed YYYY/MM/DD
      t.column :is_awarded, :boolean, :default => true 
      t.column :award_category, :string # Clinical Trial, Sponsored Research
      t.column :award_mechanism, :string # R01, U01, K01
      t.column :award_type, :string # Grant, Contract
      t.column :url, :string 
      t.column :created_id, :integer  
      t.column :created_ip, :string
      t.column :updated_id, :integer  
      t.column :updated_ip, :string
      t.column :deleted_at, :timestamp
      t.column :deleted_id, :integer  
      t.column :deleted_ip, :string

      t.timestamps
    end
  end

  def self.down
    drop_table :proposals
  end
end
