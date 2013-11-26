# -*- coding: utf-8 -*-
FactoryGirl.define do
  factory :organizational_unit do
    name 'ou_name'
    type 'OrganizationalUnit'
  end

  factory :school, :class => 'School' do
    name 'school'
    type 'School'
  end
end
