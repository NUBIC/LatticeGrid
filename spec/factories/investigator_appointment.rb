# -*- coding: utf-8 -*-
FactoryGirl.define do
  factory :investigator_appointment do
    association :investigator, factory: :investigator
    association :center, factory: :center
  end

  factory :member, :class => 'Member' do
    association :investigator, factory: :investigator
    association :center, factory: :center
    type 'Member'
  end

  factory :associate_member, :class => 'AssociateMember' do
    type 'AssociateMember'
  end

  factory :primary_member, :class => 'PrimaryMember' do
    type 'PrimaryMember'
  end
end
