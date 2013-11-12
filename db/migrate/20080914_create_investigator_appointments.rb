class CreateInvestigatorAppointments < ActiveRecord::Migration
  def self.up
    create_table :investigator_appointments do |t|
      #add_foreign_key (:mainentity, :mainentity_id, secundaryentity)
      t.column :organizational_unit_id, :integer, :null => false
      t.column :investigator_id, :integer, :null => false
      t.column :type, :string #primary, secondary, member, associate_member, joint
      t.column :start_date, :date
      t.column :end_date, :date
      t.timestamps
      # adds created_at and updated_at
    end
  end

  def self.down
    begin
      drop_table :investigator_appointments
    rescue Exception => error
      puts "unable to drop investigator_appointments. Probably doesn't exist"
    end
  end
end
