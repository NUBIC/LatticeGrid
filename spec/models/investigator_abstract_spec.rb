# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20141010154909
#
# Table name: investigator_abstracts
#
#  abstract_id      :integer          not null
#  created_at       :datetime
#  id               :integer          not null, primary key
#  investigator_id  :integer          not null
#  is_first_author  :boolean          default(FALSE), not null
#  is_last_author   :boolean          default(FALSE), not null
#  is_valid         :boolean          default(FALSE), not null
#  last_reviewed_at :datetime
#  last_reviewed_id :integer
#  last_reviewed_ip :string(255)
#  publication_date :date
#  reviewed_at      :datetime
#  reviewed_id      :integer
#  reviewed_ip      :string(255)
#  updated_at       :datetime
#  uuid             :string(255)
#

require 'spec_helper'

describe InvestigatorAbstract do

  it { should belong_to(:investigator) }
  it { should belong_to(:abstract) }
  it { should have_many(:investigator_appointments).through(:investigator) }

  it 'can be instantiated' do
    FactoryGirl.build(:investigator_abstract).should be_an_instance_of(InvestigatorAbstract)
  end

  it 'can be saved successfully' do
    FactoryGirl.create(:investigator_abstract).should be_persisted
  end
end
