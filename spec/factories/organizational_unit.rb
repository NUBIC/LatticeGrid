# -*- coding: utf-8 -*-
FactoryGirl.define do
  factory :organizational_unit do
    name 'ou_name'
    type 'OrganizationalUnit'
  end

  factory :center, :class => 'Center' do
    name 'center'
    type 'Center'
  end

  factory :division, :class => 'Division' do
    name 'division'
    type 'Division'
  end

  factory :program, :class => 'Program' do
    name 'program'
    type 'Program'
  end

  factory :school, :class => 'School' do
    name 'school'
    type 'School'
  end
end
