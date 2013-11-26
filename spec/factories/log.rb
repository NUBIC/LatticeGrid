# -*- coding: utf-8 -*-
FactoryGirl.define do
  factory :log do
    association :investigator, factory: :investigator
    association :organizational_unit, factory: :program
    params 'params'
  end
end