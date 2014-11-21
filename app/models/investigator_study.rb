# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20141010154909
#
# Table name: investigator_studies
#
#  approval_date   :date
#  completion_date :date
#  consent_role    :string(255)
#  created_at      :datetime
#  id              :integer          not null, primary key
#  investigator_id :integer          not null
#  role            :string(255)
#  status          :string(255)
#  study_id        :integer          not null
#  updated_at      :datetime
#

class InvestigatorStudy < ActiveRecord::Base
  belongs_to :investigator
  belongs_to :study

  scope :by_role, joins(:study).order('investigator_studies.role DESC')
  scope :distinct_roles, order('role').select('role, count(*) as count').group('role')
  scope :pis, joins(:investigator).where("role = 'PI'")
end
