# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20131121210426
#
# Table name: abstracts
#
#  abstract                     :text
#  abstract_vector              :text
#  author_affiliations          :text
#  author_vector                :text
#  authors                      :text
#  citation_cnt                 :integer          default(0)
#  citation_last_get_at         :datetime
#  citation_url                 :string(255)
#  created_at                   :datetime         not null
#  created_id                   :integer
#  created_ip                   :string(255)
#  deposited_date               :date
#  doi                          :string(255)
#  electronic_publication_date  :date
#  endnote_citation             :text
#  full_authors                 :text
#  id                           :integer          not null, primary key
#  is_cancer                    :boolean          default(TRUE), not null
#  is_first_author_investigator :boolean          default(FALSE)
#  is_last_author_investigator  :boolean          default(FALSE)
#  is_valid                     :boolean          default(TRUE), not null
#  isbn                         :string(255)
#  issn                         :string(255)
#  issue                        :string(255)
#  journal                      :string(255)
#  journal_abbreviation         :string(255)
#  journal_vector               :text
#  last_reviewed_at             :datetime
#  last_reviewed_id             :integer
#  last_reviewed_ip             :string(255)
#  mesh                         :text
#  mesh_vector                  :text
#  pages                        :string(255)
#  publication_date             :date
#  publication_status           :string(255)
#  publication_type             :string(255)
#  pubmed                       :string(255)
#  pubmed_creation_date         :date
#  pubmedcentral                :string(255)
#  reviewed_at                  :datetime
#  reviewed_id                  :integer
#  reviewed_ip                  :string(255)
#  status                       :string(255)
#  title                        :text
#  updated_at                   :datetime         not null
#  updated_id                   :integer
#  updated_ip                   :string(255)
#  url                          :string(255)
#  vectors                      :text
#  volume                       :string(255)
#  year                         :string(255)
#

require 'spec_helper'

describe Abstract do

  it { should have_many(:journals) }
  it { should have_many(:investigator_abstracts) }
  it { should have_many(:investigators).through(:investigator_abstracts) }
  it { should have_many(:investigator_appointments).through(:investigator_abstracts) }
  it { should have_many(:organization_abstracts) }
  it { should have_many(:organizational_units).through(:organization_abstracts) }

  it 'can be instantiated' do
    FactoryGirl.build(:abstract).should be_an_instance_of(Abstract)
  end

  it 'can be saved successfully' do
    FactoryGirl.create(:abstract).should be_persisted
  end
end
