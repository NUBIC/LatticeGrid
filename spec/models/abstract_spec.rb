# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20141010154909
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
#  created_at                   :datetime
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
#  updated_at                   :datetime
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

  context 'validity' do
    it 'is invalid when pubmed is not unique' do
      existing_abstract = FactoryGirl.create(:abstract)
      new_abstract = Abstract.new(pubmed: existing_abstract.pubmed)
      new_abstract.should_not be_valid
      new_abstract.errors.messages[:pubmed].should_not be_blank
    end

    it 'is invalid when pubmed and doi are both blank' do
      ab = Abstract.new(pubmed: nil, doi: nil)
      ab.should_not be_valid
    end
  end

  context 'with valid data' do
    let(:investigator_abstract) { FactoryGirl.create(:investigator_abstract, is_valid: true) }
    let(:investigator)          { investigator_abstract.investigator }
    let!(:abstract)             { investigator_abstract.abstract }

    describe '#display_data' do
      it 'returns matching records' do
        abstracts = Abstract.display_data(abstract.year)
        abstracts.should_not be_empty
        abstracts.total_entries.should_not be_nil
        abstracts.length.should eq abstracts.total_entries
      end
    end

    describe '#display_all_data' do
      it 'returns matching records' do
        abstracts = Abstract.display_all_data(abstract.year)
        abstracts.length.should eq 1
        expect { abstracts.total_entries }.to raise_error(NoMethodError)
      end
    end

    describe '#abstracts_by_date' do
      it 'returns matching records' do
        abstracts = Abstract.abstracts_by_date('5/1/2000', '5/1/2020')
        abstracts.length.should eq Abstract.count
        expect { abstracts.total_entries }.to raise_error(NoMethodError)
      end
    end

    describe '#display_investigator_data' do
      it 'returns matching records' do
        abstracts = Abstract.display_investigator_data(investigator.id)
        abstracts.should_not be_empty
        abstracts.total_entries.should_not be_nil
        abstracts.length.should eq abstracts.total_entries
      end
    end

    describe '#display_all_investigator_data' do
      it 'returns matching records' do
        abstracts = Abstract.display_all_investigator_data(investigator.id)
        abstracts.length.should eq 1
        expect { abstracts.total_entries }.to raise_error(NoMethodError)
      end
    end

    describe '#investigator_publications' do
      it 'returns matching records' do
        investigators = Investigator.all
        abstracts = Abstract.investigator_publications(investigators)
        abstracts.length.should eq 1
        expect { abstracts.total_entries }.to raise_error(NoMethodError)
      end
    end

  end
end
