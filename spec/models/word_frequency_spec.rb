# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20131121210426
#
# Table name: word_frequencies
#
#  created_at :datetime         not null
#  frequency  :integer
#  id         :integer          not null, primary key
#  the_type   :string(255)
#  updated_at :datetime         not null
#  word       :string(255)
#

require 'spec_helper'

describe WordFrequency do

  it 'can be instantiated' do
    FactoryGirl.build(:word_frequency).should be_an_instance_of(WordFrequency)
  end

  it 'can be saved successfully' do
    FactoryGirl.create(:word_frequency).should be_persisted
  end
end
