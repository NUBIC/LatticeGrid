# -*- coding: utf-8 -*-
FactoryGirl.define do
  factory :organizational_unit do
    name 'ou_name'
    type 'OrganizationalUnit'
    department_id 666666
    division_id 666999
  end

  factory :center, :class => 'Center' do
    name 'center'
    type 'Center'
    department_id 612000
    division_id 612010
  end

  factory :department, :class => 'Department' do
    name 'department'
    type 'Department'
    department_id 601000
    division_id 601010
  end

  factory :division, :class => 'Division' do
    name 'division'
    type 'Division'
    department_id 202000
    division_id 202020
  end

  factory :program, :class => 'Program' do
    name 'program'
    search_name 'program'
    type 'Program'
    abbreviation 'pro'
    organization_url 'program_url'
    organization_classification 'program_classification'
    organization_phone '312-555-1212'
    department_id 615000
    division_id 404000
  end

  factory :school, :class => 'School' do
    name 'school'
    type 'School'
    department_id 600000
    division_id 600010
  end
end
