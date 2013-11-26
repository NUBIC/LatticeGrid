# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20131121210426
#
# Table name: load_dates
#
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  load_date  :datetime
#  updated_at :datetime         not null
#

class LoadDate < ActiveRecord::Base
end
