class CreateStudies < ActiveRecord::Migration
  def self.up
    create_table :studies do |t|
       t.column :title, :text 
       t.column :abstract, :text
       t.column :sponsor, :string
       t.column :nct_id, :string
       t.column :accrual_goal, :integer
       t.column :approval_date, :date # DP: pubmed YYYY/MM/DD
       t.column :closure_date, :date # DP: pubmed YYYY/MM/DD
       t.column :completion_date, :date # DP: pubmed YYYY/MM/DD
       t.column :is_awarded, :boolean, :default => false 
       t.column :award_mechanism, :string # R01, U01, K01
       t.column :status, :string 
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
    drop_table :studies
  end
end
