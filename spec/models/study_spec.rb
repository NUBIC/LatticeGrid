# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20131121210426
#
# Table name: studies
#
#  abstract             :text
#  accrual_goal         :integer
#  approved_date        :date
#  closed_date          :date
#  completed_date       :date
#  created_at           :datetime         not null
#  created_id           :integer
#  created_ip           :string(255)
#  deleted_at           :datetime
#  deleted_id           :integer
#  deleted_ip           :string(255)
#  enotis_study_id      :integer
#  exclusion_criteria   :text
#  had_import_errors    :boolean          default(FALSE)
#  has_medical_services :boolean          default(FALSE), not null
#  id                   :integer          not null, primary key
#  inclusion_criteria   :text
#  irb_study_number     :string(255)
#  is_clinical_trial    :boolean          default(FALSE), not null
#  nct_id               :string(255)
#  next_review_date     :date
#  proposal_id          :integer
#  research_type        :string(255)
#  review_type          :string(255)
#  sponsor              :string(255)
#  status               :string(255)
#  title                :text
#  updated_at           :datetime         not null
#  updated_id           :integer
#  updated_ip           :string(255)
#  url                  :string(255)
#

require 'spec_helper'

describe Study do

  it { should have_many(:investigator_studies) }
  it { should have_many(:investigators).through(:investigator_studies) }

  it 'can be instantiated' do
    FactoryGirl.build(:study).should be_an_instance_of(Study)
  end

  it 'can be saved successfully' do
    FactoryGirl.create(:study).should be_persisted
  end
end
