# -*- coding: utf-8 -*-
FactoryGirl.define do
  factory :investigator do
    username   'username'
    last_name  'last_name'
    first_name 'first_name'
  end

  factory :investigator_abstract do
    is_valid false
    publication_date Date.today
    association :investigator, factory: :investigator
    association :abstract, factory: :abstract
  end
end
