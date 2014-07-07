class CreateLoadDates < ActiveRecord::Migration
  def self.up
    create_table :load_dates do |t|
      t.timestamp :load_date
      t.timestamps
    end
    add_index(:load_dates, [:load_date], :unique => true)
  end

  def self.down
    begin
      drop_table :load_dates
    rescue Exception => error
      puts "unable to drop load_dates. Probably doesn't exist"
    end
  end
end
