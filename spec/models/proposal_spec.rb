# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20141010154909
#
# Table name: proposals
#
#  abstract                        :text
#  agency                          :string(255)
#  award_category                  :string(255)
#  award_end_date                  :date
#  award_mechanism                 :string(255)
#  award_start_date                :date
#  award_type                      :string(255)
#  created_at                      :datetime
#  created_id                      :integer
#  created_ip                      :string(255)
#  deleted_at                      :datetime
#  deleted_id                      :integer
#  deleted_ip                      :string(255)
#  direct_amount                   :integer
#  id                              :integer          not null, primary key
#  indirect_amount                 :integer
#  institution_award_number        :string(255)
#  is_awarded                      :boolean          default(TRUE)
#  keywords                        :text
#  merged                          :boolean          default(FALSE)
#  original_sponsor_code           :string(255)
#  original_sponsor_name           :string(255)
#  parent_institution_award_number :string(255)
#  pi_employee_id                  :string(255)
#  project_end_date                :date
#  project_start_date              :date
#  sponsor_award_number            :string(255)
#  sponsor_code                    :string(255)
#  sponsor_name                    :string(255)
#  sponsor_type_code               :string(255)
#  sponsor_type_name               :string(255)
#  submission_date                 :date
#  title                           :string(255)
#  total_amount                    :integer
#  updated_at                      :datetime
#  updated_id                      :integer
#  updated_ip                      :string(255)
#  url                             :string(255)
#

require 'spec_helper'

describe Proposal do

  it { should have_many(:investigator_proposals) }
  it { should have_many(:investigators).through(:investigator_proposals) }

  it 'can be instantiated' do
    FactoryGirl.build(:proposal).should be_an_instance_of(Proposal)
  end

  it 'can be saved successfully' do
    FactoryGirl.create(:proposal).should be_persisted
  end
end
