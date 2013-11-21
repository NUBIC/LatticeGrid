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
#  citation_last_get_at         :timestamp
#  citation_url                 :string(255)
#  created_at                   :timestamp
#  created_id                   :integer
#  created_ip                   :string(255)
#  deposited_date               :date
#  doi                          :string(255)
#  electronic_publication_date  :date
#  endnote_citation             :text
#  full_authors                 :text
#  id                           :integer          not null, primary key
#  is_cancer                    :boolean          default(TRUE)
#  is_first_author_investigator :boolean          default(FALSE)
#  is_last_author_investigator  :boolean          default(FALSE)
#  is_valid                     :boolean          default(TRUE), not null
#  isbn                         :string(255)
#  issn                         :string(255)
#  issue                        :string(255)
#  journal                      :string(255)
#  journal_abbreviation         :string(255)
#  journal_vector               :text
#  last_reviewed_at             :timestamp
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
#  reviewed_at                  :timestamp
#  reviewed_id                  :integer
#  reviewed_ip                  :string(255)
#  status                       :string(255)
#  title                        :text
#  updated_at                   :timestamp
#  updated_id                   :integer
#  updated_ip                   :string(255)
#  url                          :string(255)
#  vectors                      :text
#  volume                       :string(255)
#  year                         :string(255)
#

require File.dirname(__FILE__) + '/../test_helper'

class AbstractTest < ActiveSupport::TestCase
  fixtures :abstracts

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  test "invalid with empty attributes" do 
    first_abstract = abstracts(:one)
    abstract = Abstract.new(:pubmed=>first_abstract.pubmed)
    assert !abstract.valid? 
    assert abstract.errors.invalid?(:pubmed) 
  end 
  
  test "test abstracts exist" do 
    abstracts = Abstract.all
    assert( abstracts.length > 0 )
  end

  test "test first abstract is not nil" do 
    first_abstract = abstracts(:one)
    assert( ! first_abstract.blank?)
    assert( ! first_abstract.year.blank?)
    assert( first_abstract.year ==  '2006')
  end
  
  test "test abstract display methods" do 
    first_abstract = abstracts(:one)
    assert( ! first_abstract.year.blank?)
    abstracts=Abstract.display_data(first_abstract.year)
    assert(abstracts.length > 0)
    assert(abstracts[0].id > 0)
    assert_not_nil(abstracts.total_entries, "abstracts.total_entries should  exist")
    assert(abstracts.length == abstracts.total_entries)
    abstracts=Abstract.display_all_data(first_abstract.year)
    assert(abstracts.length == 1)
    assert(abstracts[0].id == 1)
    assert_raise(NoMethodError,"abstracts.total_entries should not exist") {abstracts.total_entries}
  end

  test "test abstract date methods" do
    abstracts=Abstract.abstracts_by_date("5/1/2000", "5/1/2020")
    assert(abstracts.length > 0)
    assert(abstracts.length == Abstract.all.length )
    assert_raise(NoMethodError,"abstracts.total_entries should not exist") {abstracts.total_entries}
  end
    
  test "test investigator abstract display methods" do 
    first_abstract = abstracts(:one)
    first_investigator = investigators(:one)
    investigators = Investigator.find(:all)
    abstracts=Abstract.display_investigator_data(first_investigator.id)
    assert(abstracts.length == 1)
    assert(abstracts[0].id == 1)
    assert_not_nil(abstracts.total_entries, "abstracts.total_entries should  exist")
    assert(abstracts.length == abstracts.total_entries)
    abstracts=Abstract.display_all_investigator_data(first_investigator.id)
    assert(abstracts.length == 1)
    assert(abstracts[0].id == 1)
    assert_raise(NoMethodError,"abstracts.total_entries should not exist") {abstracts.total_entries}
    abstracts=Abstract.investigator_publications(investigators)
    #investigator_publications finds only abstracts in the last 5 years are included!
    assert(abstracts.length == 0)
    abstracts=first_abstract.investigator_abstracts
    assert(abstracts.length == 1)
    assert(abstracts[0].id == 1)
    assert_raise(NoMethodError,"abstracts.total_entries should not exist") {abstracts.total_entries}
  end

  
end
