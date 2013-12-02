# -*- coding: utf-8 -*-
FactoryGirl.define do
  factory :investigator_colleague do
    association :investigator, factory: :investigator, username: 'investigator_colleague_investigator'
    association :colleague, factory: :investigator, username: 'investigator_colleague_colleague'
  end
end
