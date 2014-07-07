class UpdateInvestigatorAbstracts < ActiveRecord::Migration
  def self.up
    add_column :investigator_abstracts, :is_valid, :boolean, :default => false, :null => false
    add_column :investigator_abstracts, :reviewed_at, :timestamp
    add_column :investigator_abstracts, :reviewed_id, :integer
    add_column :investigator_abstracts, :reviewed_ip, :string
    add_column :investigator_abstracts, :last_reviewed_at, :timestamp
    add_column :investigator_abstracts, :last_reviewed_id, :integer
    add_column :investigator_abstracts, :last_reviewed_ip, :string
    InvestigatorAbstract.update_all(:is_valid=>true)
    abs = InvestigatorAbstract.only_deleted()
    abs.each do |ia|
      ia.is_valid = false
      ia.reviewed_at = ia.end_date
      ia.last_reviewed_at = ia.end_date
      ia.reviewed_id = 0
      ia.last_reviewed_id = ia.reviewed_id
      ia.reviewed_ip = 'set during migration'
      ia.last_reviewed_ip = ia.reviewed_ip
      ia.save!
    end
    puts "marked #{abs.length} investigator_abstracts as invalid"

    remove_column :investigator_abstracts, :start_date
    remove_column :investigator_abstracts, :end_date

    add_column :abstracts, :is_valid, :boolean, :default => true, :null => false
    add_column :abstracts, :reviewed_at, :timestamp
    add_column :abstracts, :reviewed_id, :integer
    add_column :abstracts, :reviewed_ip, :string
    add_column :abstracts, :last_reviewed_at, :timestamp
    add_column :abstracts, :last_reviewed_id, :integer
    add_column :abstracts, :last_reviewed_ip, :string
    #for rails 3 this needs to be Abstract.unscoped
    
    abs = Abstract.only_deleted()
    abs.each do |abstract|
      abstract.is_valid = false
      abstract.reviewed_at = abstract.deleted_at
      abstract.last_reviewed_at = abstract.deleted_at
      abstract.reviewed_id = abstract.deleted_id
      abstract.last_reviewed_id = abstract.deleted_id
      abstract.reviewed_ip = abstract.deleted_ip
      abstract.last_reviewed_ip = abstract.deleted_ip
      abstract.save!
    end
    puts "marked #{abs.length} abstracts as invalid"
    remove_column :abstracts, :deleted_at
    remove_column :abstracts, :deleted_ip
    remove_column :abstracts, :deleted_id

   end

  def self.down
    add_column :investigator_abstracts, :start_date, :date
    add_column :investigator_abstracts, :end_date, :date

    abs = InvestigatorAbstract.only_invalid()
    abs.each do |ia|
      ia.end_date = ia.last_reviewed_at || Time.now
      ia.save!
    end
    puts "marked #{abs.length} as investigator_abstracts deleted"

    remove_column :investigator_abstracts, :is_valid
    remove_column :investigator_abstracts, :reviewed_at
    remove_column :investigator_abstracts, :reviewed_id
    remove_column :investigator_abstracts, :reviewed_ip
    remove_column :investigator_abstracts, :last_reviewed_at
    remove_column :investigator_abstracts, :last_reviewed_id
    remove_column :investigator_abstracts, :last_reviewed_ip

    add_column :abstracts, :deleted_at, :timestamp
    add_column :abstracts, :deleted_id, :integer
    add_column :abstracts, :deleted_ip, :string

    abs = Abstract.only_invalid()
    abs.each do |abstract|
      abstract.deleted_at = abstract.last_reviewed_at || Time.now
      abstract.deleted_id = abstract.last_reviewed_id
      abstract.deleted_ip = abstract.last_reviewed_ip
      abstract.save!
    end
    puts "marked #{abs.length} abstracts as deleted"

    remove_column :abstracts, :is_valid
    remove_column :abstracts, :reviewed_at
    remove_column :abstracts, :reviewed_id
    remove_column :abstracts, :reviewed_ip
    remove_column :abstracts, :last_reviewed_at
    remove_column :abstracts, :last_reviewed_id
    remove_column :abstracts, :last_reviewed_ip

  end
end
