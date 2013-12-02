# -*- coding: utf-8 -*-
FactoryGirl.define do
  factory :organization_abstract do
    association :organizational_unit, factory: :organizational_unit
    association :abstract, factory: :abstract
  end
end
