# -*- coding: utf-8 -*-
FactoryGirl.define do
  factory :investigator_appointment do
    association :investigator, factory: :investigator
    association :center, factory: :center
  end

  factory :joint, :class => 'Joint' do
    association :investigator, factory: :investigator
    association :organizational_unit, factory: :organizational_unit
    type 'Joint'
  end

  factory :member, :class => 'Member' do
    association :investigator, factory: :investigator
    association :center, factory: :center
    type 'Member'
  end

  factory :associate_member, :class => 'AssociateMember' do
    association :investigator, factory: :investigator
    association :organizational_unit, factory: :organizational_unit
    type 'AssociateMember'
  end

  factory :primary_member, :class => 'PrimaryMember' do
    association :investigator, factory: :investigator
    association :organizational_unit, factory: :organizational_unit
    type 'PrimaryMember'
  end

  factory :primary_associate_member, :class => 'PrimaryAssociateMember' do
    association :investigator, factory: :investigator
    association :organizational_unit, factory: :organizational_unit
    type 'PrimaryAssociateMember'
  end

  factory :secondary, :class => 'Secondary' do
    association :investigator, factory: :investigator
    association :organizational_unit, factory: :organizational_unit
    type 'Secondary'
  end

  factory :secondary_member, :class => 'SecondaryMember' do
    association :investigator, factory: :investigator
    association :organizational_unit, factory: :organizational_unit
    type 'SecondaryMember'
  end

  factory :secondary_associate_member, :class => 'SecondaryAssociateMember' do
    association :investigator, factory: :investigator
    association :organizational_unit, factory: :organizational_unit
    type 'SecondaryAssociateMember'
  end

  factory :tertiary_member, :class => 'TertiaryMember' do
    association :investigator, factory: :investigator
    association :organizational_unit, factory: :organizational_unit
    type 'TertiaryMember'
  end

  factory :tertiary_associate_member, :class => 'TertiaryAssociateMember' do
    association :investigator, factory: :investigator
    association :organizational_unit, factory: :organizational_unit
    type 'TertiaryAssociateMember'
  end
end
