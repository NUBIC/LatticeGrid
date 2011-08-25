class TsearchVectors < ActiveRecord::Migration
  def self.up
		Abstract.create_vector  #doesn't hurt to try, even if it exists
		Abstract.update_vector
		Investigator.create_vector  #doesn't hurt to try, even if it exists
		Investigator.update_vector
  end

  def self.down
  end
end
