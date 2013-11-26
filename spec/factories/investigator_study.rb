# -*- coding: utf-8 -*-
FactoryGirl.define do
  factory :investigator_study do
    association :investigator, factory: :investigator
    association :study, factory: :study
  end
end
