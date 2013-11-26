# -*- coding: utf-8 -*-
FactoryGirl.define do
  factory :abstract do
    pubmed            'abstract_pubmed'
    year              '2525'
    is_valid          false
    publication_date  Date.today
    authors           'last_name, f. m.'
    full_authors      'last_name, first_name m.'
    pages             '1'
  end
end
