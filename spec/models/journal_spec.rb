# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20141010154909
#
# Table name: journals
#
#  article_influence_score  :float
#  created_at               :datetime
#  eigenfactor_score        :float
#  id                       :integer          not null, primary key
#  immediacy_index          :float
#  impact_factor            :float
#  impact_factor_five_year  :float
#  include_as_high_impact   :boolean          default(FALSE), not null
#  issn                     :string(255)
#  jcr_journal_abbreviation :string(255)
#  journal_abbreviation     :string(255)      not null
#  journal_name             :string(255)
#  score_year               :integer
#  total_articles           :integer
#  total_cites              :integer
#  updated_at               :datetime
#

require 'spec_helper'

describe Journal do

  it { should have_many(:abstracts) }
  it { should validate_presence_of(:journal_name) }
  it { should validate_presence_of(:journal_abbreviation) }

  it 'can be instantiated' do
    FactoryGirl.build(:journal).should be_an_instance_of(Journal)
  end

  it 'can be saved successfully' do
    FactoryGirl.create(:journal).should be_persisted
  end
end
