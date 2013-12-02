# -*- coding utf-8 -*-
FactoryGirl.define do
  factory :investigator do
    username   'username'
    last_name  'last_name'
    first_name 'first_name'
    middle_name 'F'
    pubmed_limit_to_institution false
    home_department_id 1
    num_first_pubs_last_five_years 0
    num_last_pubs_last_five_years 1
    total_publications_last_five_years 1
    num_intraunit_collaborators_last_five_years 1
    num_extraunit_collaborators_last_five_years 0
    appointment_basis 'FT'
    email 'pi@northwestern.edu'
    weekly_hours_min 35
    consecutive_login_failures 0
  end
end
