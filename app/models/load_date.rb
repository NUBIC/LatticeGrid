# == Schema Information
# Schema version: 20130327155943
#
# Table name: load_dates
#
#  created_at :timestamp
#  id         :integer          default(0), not null, primary key
#  load_date  :timestamp
#  updated_at :timestamp
#

class LoadDate < ActiveRecord::Base
end
