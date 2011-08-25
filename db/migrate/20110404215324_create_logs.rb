class CreateLogs < ActiveRecord::Migration
  def self.up
    create_table :logs do |t|
      t.string :activity
      t.integer :investigator_id
      t.integer :program_id
      t.string :controller_name
      t.string :action_name
      t.text   :params
      t.string :created_ip

      t.timestamps
    end
  end

  def self.down
    drop_table :logs
  end
end
