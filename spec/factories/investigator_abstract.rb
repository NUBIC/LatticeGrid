# -*- coding: utf-8 -*-
FactoryGirl.define do
  factory :investigator_abstract do
    is_valid false
    publication_date Date.today
    association :investigator, factory: :investigator
    association :abstract, factory: :abstract
  end
end
