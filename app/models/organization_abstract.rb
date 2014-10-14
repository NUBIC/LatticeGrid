# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20141010154909
#
# Table name: organization_abstracts
#
#  abstract_id            :integer          not null
#  created_at             :datetime
#  end_date               :date
#  id                     :integer          not null, primary key
#  organizational_unit_id :integer          not null
#  start_date             :date
#  updated_at             :datetime
#

class OrganizationAbstract < ActiveRecord::Base
  belongs_to :organizational_unit
  belongs_to :abstract
  validates_uniqueness_of :organizational_unit_id, :scope => "abstract_id"
end
