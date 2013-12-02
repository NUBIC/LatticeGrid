# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20131121210426
#
# Table name: investigator_proposals
#
#  created_at      :datetime         not null
#  id              :integer          not null, primary key
#  investigator_id :integer          not null
#  is_main_pi      :boolean          default(FALSE), not null
#  percent_effort  :integer          default(0)
#  proposal_id     :integer          not null
#  role            :string(255)
#  updated_at      :datetime         not null
#

require 'spec_helper'

describe InvestigatorProposal do

  it { should belong_to(:investigator) }
  it { should belong_to(:proposal) }

  it 'can be instantiated' do
    FactoryGirl.build(:investigator_proposal).should be_an_instance_of(InvestigatorProposal)
  end

  it 'can be saved successfully' do
    FactoryGirl.create(:investigator_proposal).should be_persisted
  end
end
