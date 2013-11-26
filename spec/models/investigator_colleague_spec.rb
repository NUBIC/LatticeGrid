# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20131121210426
#
# Table name: investigator_colleagues
#
#  colleague_id     :integer
#  created_at       :datetime         not null
#  id               :integer          not null, primary key
#  in_same_program  :boolean          default(FALSE)
#  investigator_id  :integer
#  mesh_tags_cnt    :integer          default(0)
#  mesh_tags_ic     :float            default(0.0)
#  proposal_cnt     :integer          default(0)
#  proposal_list    :text
#  publication_cnt  :integer          default(0)
#  publication_list :text
#  study_cnt        :integer          default(0)
#  study_list       :text
#  tag_list         :text
#  updated_at       :datetime         not null
#

require 'spec_helper'

describe InvestigatorColleague do

  it { should belong_to(:investigator) }
  it { should belong_to(:colleague) }

  it 'can be instantiated' do
    FactoryGirl.build(:investigator_colleague).should be_an_instance_of(InvestigatorColleague)
  end

  it 'can be saved successfully' do
    FactoryGirl.create(:investigator_colleague).should be_persisted
  end
end
