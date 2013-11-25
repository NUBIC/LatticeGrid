# == Schema Information
# Schema version: 20131121210426
#
# Table name: load_dates
#
#  created_at :timestamp        not null
#  id         :integer          default(0), not null, primary key
#  load_date  :timestamp
#  updated_at :timestamp        not null
#

class LoadDate < ActiveRecord::Base
end
