# -*- coding: utf-8 -*-
FactoryGirl.define do
  factory :investigator_proposal do
    association :investigator, factory: :investigator
    association :proposal, factory: :proposal
  end
end
