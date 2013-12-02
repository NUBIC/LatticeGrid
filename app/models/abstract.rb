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

class Abstract < ActiveRecord::Base
  include MeshHelper
  acts_as_taggable  # for MeSH terms
  acts_as_tsearch :vectors => {:fields => ["abstract","authors", "full_authors", "title", "journal", "journal_abbreviation", "mesh"]},
                  :author_vector => {:fields => ["authors", "full_authors"]},
                  :abstract_vector => {:fields => ["abstract", "title"]},
                  :mesh_vector => {:fields => ["mesh"]},
                  :journal_vector => {:fields => ["journal","journal_abbreviation"]}
  has_many :journals,
    :foreign_key => "issn",
    :primary_key =>  "issn",
    :readonly => true,
    :order => "score_year DESC,journal_abbreviation"

  has_many :investigator_abstracts
  has_many :investigators, :through => :investigator_abstracts,
    :conditions => ['(investigators.end_date is null or investigators.end_date >= :now) and investigator_abstracts.is_valid = true', {:now => Date.today }]
  has_many :investigator_appointments, :through => :investigator_abstracts,
    :conditions => ['investigator_appointments.end_date is null or investigator_appointments.end_date >= :now', {:now => Date.today }]

  has_many :organization_abstracts,
    :conditions => ['organization_abstracts.end_date is null or organization_abstracts.end_date >= :now', {:now => Date.today }]
  has_many :organizational_units, :through => :organization_abstracts

  # if pubmed if blank, force uniqueness (non-blankness!) for doi, and vice versus. Both cannot be blank!
  validates :pubmed, :uniqueness => true, :presence => true, :if => "doi.blank?"
  validates :doi, :uniqueness => true, :presence => true, :if => "pubmed.blank?"

  scope :most_recent, lambda { |latest|
    if latest.blank?
      order("abstracts.year DESC, abstracts.authors ASC")
    else
      limit(latest).order("abstracts.year DESC, abstracts.authors ASC")
    end
  }

  scope :abstracts_last_five_years,
    where('abstracts.publication_date >= :start_date',
      { :start_date => 5.years.ago })

  scope :abstracts_by_date, lambda { |*dates|
    where('abstracts.publication_date between :start_date and :end_date',
      { :start_date => dates.first, :end_date => dates.last })
  }

  scope :ccsg_abstracts_by_date, lambda { |*dates|
    where('is_cancer = true and (abstracts.publication_date between :start_date and :end_date)',
      { :start_date => dates.first, :end_date => dates.last })
  }

  scope :with_impact_factor, lambda { |factor|
    joins(:journals)
    .where('journals.impact_factor >= :impact_factor',
      { :impact_factor => factor })
  }

  scope :ccsg_abstracts, where('abstracts.is_cancer = true')

  scope :only_valid, where('abstracts.is_valid = true')

  scope :recently_changed,
    where('abstracts.updated_at >= :recent_date',
      { :recent_date => 30.days.ago }).order("abstracts.updated_at DESC")

  scope :exclude_letters,
    where('lower(abstracts.publication_type) NOT IN (:publication_types)',
      { :publication_types => ["dictionary", "introductory journal article", "interview", "bibliography", "retraction of publication",
                               "english abstract", "newspaper article", "letter", "lectures", "interactive tutorial", "news", "letter",
                               "guideline", "editorial", "consensus development conference", "historical article", "duplicate publication",
                               "biography", "addresses", "video-audio media", "comment", "congresses", "editorial", "clinical conference"] })

  scope :by_ids, lambda { |*ids|
    where('abstracts.id IN (:ids) ', { :ids => ids.first })
  }

  scope :by_investigator_ids, lambda { |*ids|
    joins(:investigator_abstracts)
    .where('investigator_abstracts.investigator_id IN (:investigator_ids) AND investigator_abstracts.is_valid = true',
      { :investigator_ids => ids.first })
  }

  default_scope :conditions => 'abstracts.is_valid = true'

  def check_pubmed_doi_blank?
    doi.blank? and pubmed.blank?
  end

  def self.abstract_words
    all.map(&:abstract_words).join(" ").split(/[ \t\r\n]+/)
  end

  def abstract_words
    [self.abstract, self.title].join(" ").gsub(/([;:\.\,\+\\\/]+)/,' ').downcase.split(/[ \t\r\n]+/).map{ |w| w.gsub(/([\?\'\"\*\#\%\[\]\,\(\)\<\>\=]+)/,'').gsub(/^([\-\+\<\=0-9]+)/,'').gsub(/([\-\+\<\=0-9]+)$/,'') }.uniq
  end

  def has_full
    return false if self.full_authors.blank?
    return true if self.full_authors.split(/\n|\r/).first =~ /[^,]{2,}, +[^\. ]{2,}/
    return false
  end

  def author_array
    if self.has_full
      self.full_authors.split(/\n|\r/)
    else
      self.authors.split(/\n|\r/)
    end
  end

  def self.recently_changed_unvalidated
    unscoped do
      where("abstracts.updated_at >= :recent_date and (abstracts.is_valid = false or exists(select 'x' from investigator_abstracts where abstracts.id = investigator_abstracts.abstract_id and investigator_abstracts.is_valid = false and investigator_abstracts.reviewed_at is null ) )",
          {:recent_date => 90.days.ago })
      .order('abstracts.updated_at DESC')
      .to_a
    end
  end

  def self.full_author_not_has_full
    unscoped do
      abs = where("abstracts.full_authors is not null and not abstracts.full_authors = ''").to_a
      ary = []
      abs.each { |ab| ary << ab unless ab.has_full }
      ary
    end
  end

  def self.full_author_has_full
    unscoped do
      abs = where("abstracts.full_authors is not null and not abstracts.full_authors = ''").to_a
      ary = []
      abs.each { |ab| ary << ab unless ab.has_full }
      ary
    end
  end

  def self.include_deleted(id = nil)
    unscoped do
      id.blank? ? all : find(id)
    end
  end

  def self.only_deleted
    unscoped do
      where('abstracts.deleted_at is not null').to_a
    end
  end

  def self.include_invalid(id = nil)
    unscoped do
      id.blank? ? all : find(id)
    end
  end

  def self.all_ccsg_publications_by_date( faculty_ids, start_date, end_date, exclude_letters=nil, first_last_only=false, impact_factor=nil )
    if first_last_only
      abstract_ids = InvestigatorAbstract.for_investigator_ids(faculty_ids).first_or_last_author_abstracts.by_date_range(start_date, end_date).map(&:abstract_id)
      abstracts = Abstract.by_ids(abstract_ids).ccsg_abstracts
    else
      abstracts = Abstract.by_investigator_ids(faculty_ids).ccsg_abstracts_by_date(start_date, end_date)
    end
    unless exclude_letters.blank? or ! exclude_letters
      abstracts = abstracts.exclude_letters
    end
    unless impact_factor.blank? or impact_factor.to_s !~ /^\d+$/
      abstracts = abstracts.with_impact_factor(impact_factor)
    end
    abstracts.uniq
  end

  def self.abstracts_with_missing_dates
     unscoped do
       where("abstracts.publication_date is null or abstracts.electronic_publication_date is null").to_a
     end
  end

  def self.abstracts_with_missing_publication_date
    unscoped do
      where("abstracts.publication_date is null").to_a
    end
  end

  def self.abstracts_with_missing_publication_date_and_good_edate
    abstracts_with_missing_publication_date.select{ |ab| ab.year.to_s == ab.electronic_publication_date.year.to_s }
  end

  def self.abstracts_with_missing_electronic_publication_date
    unscoped do
      where("abstracts.electronic_publication_date is null").to_a
    end
  end

  def self.abstracts_with_missing_deposited_date
    unscoped do
      where("abstracts.deposited_date is null").to_a
    end
  end

  def self.only_invalid
    unscoped do
      where("abstracts.is_valid = false").to_a
    end
  end

  def self.find_by_pubmed_include_deleted(val)
    unscoped do
      find_by_pubmed(val.to_s)
    end
  end

  def self.find_by_doi_include_deleted(val)
    unscoped do
      find_by_doi(val.to_s)
    end
  end

  def self.find_all_by_pubmed_include_deleted(val)
    unscoped do
      find_all_by_pubmed(val)
    end
  end

  def self.display_all_investigator_data_include_deleted(investigator_id)
    unscoped do
      joins(:investigator_abstracts)
      .where('investigator_abstracts.investigator_id = :investigator_id',
        { :investigator_id => investigator_id })
      .order('is_valid DESC, year DESC, authors ASC')
      .to_a
    end
  end

  def self.recents_by_issns(issns)
    where('abstracts.issn IN (:issns) and abstracts.publication_date >= :recent_date',
      { :issns => issns, :recent_date => 30.months.ago })
    .order('abstracts.publication_date DESC, authors ASC')
    .to_a
  end

  def self.from_journal_include_deleted(journal_abbreviation)
    unscoped do
      where('lower(journal_abbreviation) = :journal_abbreviation',
        { :journal_abbreviation => journal_abbreviation })
      .order('year DESC, authors ASC')
      .to_a
    end
  end

  def self.from_journal(journal_abbreviation)
    where('lower(journal_abbreviation) = :journal_abbreviation',
      { :journal_abbreviation => journal_abbreviation })
    .order('year DESC, authors ASC')
    .to_a
  end

  def self.mismatched_issns
    select('distinct journal, journal_abbreviation, issn')
    .where("exists(select 'x' from abstracts a2 where a2.journal_abbreviation = abstracts.journal_abbreviation and a2.issn != abstracts.issn)")
    .order('journal, issn')
    .to_a
  end

  def self.nulled_issns
    select('distinct journal, journal_abbreviation, issn')
    .where("exists(select 'x' from abstracts a2 where a2.journal_abbreviation = abstracts.journal_abbreviation and a2.issn is null and abstracts.issn is not null)")
    .order('journal, issn')
    .to_a
  end

  def self.without_jcr_entries
    select('distinct journal, journal_abbreviation, issn')
    .where("not exists(select 'x' from journals where journals.issn = abstracts.issn )")
    .order('journal, issn')
    .to_a
  end

  def self.with_jcr_entries
    select('distinct journal, journal_abbreviation, issn')
    .where("exists(select 'x' from journals where journals.issn = abstracts.issn )")
    .order('journal, issn')
    .to_a
  end

  def self.all_issns
    select('distinct journal, journal_abbreviation, issn')
    .order('journal, issn')
    .to_a
  end

  def self.co_authors(abstracts)
    author_ids = abstracts.collect{ |ab| ab.investigators.collect(&:id) }.flatten.sort.uniq
    Investigator.where('id IN (:author_ids)', { :author_ids => author_ids })
      .order('lower(last_name), lower(first_name)').to_a
  end

  def self.annual_data(years)
    where("year IN (:years)",{ :years => Journal.yearstring(years) })
    .order('authors ASC')
    .to_a
  end

  def self.without_investigators
    where("not exists(select 'x' from investigator_abstracts where investigator_abstracts.abstract_id = abstracts.id )").to_a
  end

  def self.without_valid_investigators
    where("not exists(select 'x' from investigator_abstracts where investigator_abstracts.abstract_id = abstracts.id and investigator_abstracts.is_valid = true )").to_a
  end

  def self.invalid_with_investigators
    unscoped do
      where("abstracts.is_valid = false and exists(select 'x' from investigator_abstracts where investigator_abstracts.abstract_id = abstracts.id and investigator_abstracts.is_valid = true )").to_a
    end
  end

  def self.invalid_with_investigators_unreviewed
    unscoped do
      where("abstracts.is_valid = false and abstracts.last_reviewed_id is null and exists(select 'x' from investigator_abstracts where investigator_abstracts.abstract_id = abstracts.id and investigator_abstracts.is_valid = true )").to_a
    end
  end

  def self.invalid_with_investigators_reviewed
    unscoped do
      where("abstracts.is_valid = false and abstracts.last_reviewed_id is not null and exists(select 'x' from investigator_abstracts where investigator_abstracts.abstract_id = abstracts.id and investigator_abstracts.is_valid = true )").to_a
    end
  end

  def self.invalid_unreviewed
    unscoped do
      where("abstracts.is_valid = false and abstracts.last_reviewed_id is null").to_a
    end
  end

  def self.invalid_reviewed()
    unscoped do
      where("abstracts.is_valid = false and abstracts.last_reviewed_id is not null").to_a
    end
  end

  def self.valid_unreviewed()
    unscoped do
      where("abstracts.is_valid = true and abstracts.last_reviewed_id is null").to_a
    end
  end

  def self.valid_reviewed()
    unscoped do
      where("abstracts.is_valid = true and abstracts.last_reviewed_id is not null").to_a
    end
  end

  def self.missing_impact_factors(years)
    select('count(*) as count_all, journal, journal_abbreviation, issn')
    .where("abstracts.year IN (:years) AND not exists(select 'x' from journals where journals.issn = abstracts.issn )",
      { :years => Journal.yearstring(years) })
    .group('journal, journal_abbreviation, issn')
    .order('count_all DESC, journal, issn')
    .to_a
  end

  def self.display_data(year = 2007, page = 1)
    paginate(:page => page,
      :per_page => 20,
      :order => "abstracts.publication_date DESC, abstracts.electronic_publication_date DESC, abstracts.authors ASC",
      :include => [:investigators],
      :conditions => ['year = :year and investigator_abstracts.is_valid = true',
  		      { :year => year }])
  end

  def self.display_all_data(year = 2008)
    includes([:investigators])
    .where('year = :year and investigator_abstracts.is_valid = true',
      { :year => year })
    .order('investigators.last_name ASC, authors ASC')
    .to_a
  end

  def self.display_investigator_data(investigator_id, page = 1)
    paginate(:page => page,
      :per_page => 20,
      :order => "year DESC, authors ASC",
      :joins => [:investigators],
      :conditions => ["investigators.id = :investigator_id", {:investigator_id => investigator_id}])
  end

  def self.display_all_investigator_data(investigator_id)
    joins([:investigators])
    .where("investigators.id = :investigator_id", { :investigator_id => investigator_id })
    .order('year DESC, authors ASC')
    .to_a
  end

  def self.all_investigator_publications(investigators)
    joins([:investigators, :investigator_abstracts])
  	.where('investigator_abstracts.investigator_id IN (:investigators) and investigator_abstracts.is_valid = true and abstracts.is_valid = true',
   	  { :investigators => investigators })
    .to_a.uniq
  end
  def self.investigator_publications(investigators, number_years = 5)
    joins([:investigators, :investigator_abstracts])
    .where('abstracts.publication_date >= :start_date and investigator_abstracts.investigator_id IN (:investigators) and investigator_abstracts.is_valid = true and abstracts.is_valid = true ',
      { :start_date => number_years.years.ago, :investigators => investigators })
    .to_a
  end

  def self.investigator_publications_by_date(investigators, pub_start_date, pub_end_date)
    joins([:investigators, :investigator_abstracts])
    .where('(abstracts.publication_date between :pub_start_date and :pub_end_date) and investigator_abstracts.investigator_id IN (:investigators) and investigator_abstracts.is_valid = true',
      { :pub_start_date => pub_start_date, :pub_end_date => pub_end_date, :investigators => investigators })
    .to_a.uniq
  end

  def self.display_abstracts_by_date(unit_id, pub_start_date, pub_end_date)
    where('organizational_units.id = :unit_id AND abstracts.publication_date between :pub_start_date and :pub_end_date',
      { :unit_id => unit_id, :pub_start_date => pub_start_date, :pub_end_date => pub_end_date })
    .order('abstracts.year DESC, authors ASC')
    .first
  end

  def self.display_tsearch(keywords, paginate=1, page=1, limit=nil)
    if paginate != '0' then
      abstracts = display_tsearch_paginated(keywords.keywords, keywords.search_field, page, limit)
    else
      abstracts = display_tsearch_no_pagination(keywords.keywords, keywords.search_field, limit)
    end
    abstracts
  end

  def self.display_tsearch_paginated(terms, search_field, page, limit=nil)
    if search_field.include?("Abstract") or search_field.include?("Title")
      abstract_ids = Abstract.find_by_tsearch(terms, {:select => 'ID'}, {:vector => "abstract_vector"})
    elsif search_field.include?("Author") or search_field.include?("Investigator")
      abstract_ids = Abstract.find_by_tsearch(terms, {:select => 'ID'}, {:vector => "author_vector"})
    elsif search_field.include?("Journal")
      abstract_ids = Abstract.find_by_tsearch(terms, {:select => 'ID'}, {:vector => "journal_vector"})
    elsif search_field.include?("Summary")
      lc_keywords = terms.sub(/\*/, '%')
      lc_keywords = "%"+lc_keywords+"%"
      abstracts = paginate(:page => page,
           :joins => [:investigators],
           :per_page => 20,
           :order => "year DESC, authors ASC",
           :conditions => ["lower(investigators.faculty_keywords) like :search_term OR lower(investigators.faculty_research_summary) like :search_term  OR lower(investigators.faculty_interests) like :search_term",
              {:search_term => lc_keywords }])
    elsif search_field.include?("Keywords") or search_field.include?("MeSH")
      abstract_ids = Abstract.find_by_tsearch(terms, {:select => 'ID'}, {:vector => "mesh_vector"})
    else
      abstract_ids = Abstract.find_by_tsearch(terms, {:select => 'ID'})
    end
    if defined?(abstract_ids) and !abstract_ids.nil? then
      abstracts = Abstract.paginate(:page => page,
        :include => [:investigators],
        :per_page => 20,
        :limit => limit,
        :order => "year DESC, authors ASC",
        :conditions => ["abstracts.id IN (:abstract_ids) and investigator_abstracts.is_valid = true",
           {:abstract_ids => abstract_ids.collect(&:id)} ])
    end
    abstracts
  end

  def self.display_tsearch_no_pagination(terms, search_field, limit=nil)
    if search_field.include?("Abstract") or search_field.include?("Title")
      abstracts = Abstract.find_by_tsearch(terms, {:select=>tsearch_select_fields, :limit=>limit, :order=>'year desc, publication_date desc, authors ASC'}, {:vector => "abstract_vector"})
    elsif search_field.include?("Author") or search_field.include?("Investigator")
      abstracts = Abstract.find_by_tsearch(terms, {:select=>tsearch_select_fields, :limit=>limit, :order=>'year desc, publication_date desc, authors ASC'}, {:vector => "author_vector"})
    elsif search_field.include?("Journal")
      abstracts = Abstract.find_by_tsearch(terms, {:select=>tsearch_select_fields, :limit=>limit, :order=>'year desc, publication_date desc, authors ASC'}, {:vector => "journal_vector"})
    elsif search_field.include?("Summary")
      lc_keywords = terms.sub(/\*/, '%')
      lc_keywords = "%"+lc_keywords+"%"
      abstracts = select(tsearch_select_fields)
        .joins([:investigators])
        .where("lower(investigators.faculty_keywords) like :search_term OR lower(investigators.faculty_research_summary) like :search_term  OR lower(investigators.faculty_interests) like :search_term",
          { :search_term => lc_keywords })
        .order('year DESC, publication_date desc, authors ASC')
        .limit(limit)
        .to_a
    elsif search_field.include?("Keywords") or search_field.include?("MeSH")
      abstracts = Abstract.find_by_tsearch(terms, {:select=>tsearch_select_fields,:limit=>limit, :order=>'year desc, publication_date desc, authors ASC'}, {:vector => "mesh_vector"})
    else
      abstracts = Abstract.find_by_tsearch(terms, {:select=>tsearch_select_fields, :limit=>limit, :order=>'year desc, publication_date desc, authors ASC'})
    end
    abstracts
  end

  def tsearch_select_fields
    "id, endnote_citation, abstract, authors, full_authors, is_first_author_investigator, is_last_author_investigator, title, journal_abbreviation, journal, volume, issue, pages, year, publication_date, publication_type, electronic_publication_date, deposited_date, status, publication_status, pubmed, issn, isbn, citation_cnt, citation_last_get_at, citation_url, url, mesh, is_cancer, pubmedcentral, is_valid, pubmed_creation_date"
  end
  private :tsearch_select_fields

  # legacy for sites running postgres 8.2 or older
  def self.display_search(keywords, paginate = 1, page = 1)
    lc_keywords = keywords.keywords.downcase
    lc_keywords = lc_keywords.sub(/\*/, '%')
    lc_keywords = "%"+lc_keywords+"%"
    if paginate != '0' then
      abstracts = display_search_paginated(keywords, lc_keywords, page)
    else
      abstracts = display_search_no_pagination(keywords, lc_keywords)
    end
    return abstracts
  end

  def self.display_search_paginated(keywords, lc_keywords, page)
    terms = keywords.keywords.downcase.split(" ",3) + Array.new(2, "")
    terms[2] = terms[0] if terms[2].blank?
    terms[1] = terms[0] if terms[1].blank?
    terms[0] = "%"+terms[0]+"%"
    terms[1] = "%"+terms[1]+"%"
    terms[2] = "%"+terms[2]+"%"
    if keywords.search_field.include?("Abstract")
      paginate(:page => page,
        :per_page => 20,
        :order => "year DESC, authors ASC",
        :conditions => ["lower(abstract) like :term1 and lower(abstract) like :term2 and lower(abstract) like :term3",
          {:term1 => terms[0], :term2 => terms[1], :term3 => terms[2]} ])
    elsif keywords.search_field.include?("Author")
      paginate(:page => page,
        :per_page => 20,
        :order => "year DESC, authors ASC",
        :conditions => ["(lower(full_authors) like :term1 AND lower(full_authors) like :term2) OR (lower(authors) like :term1 AND lower(authors) like :term2)",
          {:term1 => terms[0], :term2 => terms[1]}])
    elsif keywords.search_field.include?("Title")
      paginate(:page => page,
        :per_page => 20,
        :order => "year DESC, authors ASC",
        :conditions => ["lower(title) like :term1 and lower(title) like :term2 and lower(title) like :term3",
          {:term1 => terms[0], :term2 => terms[1], :term3 => terms[2]}])
    elsif keywords.search_field.include?("Journal")
      paginate(:page => page,
        :per_page => 20,
        :order => "year DESC, authors ASC",
        :conditions => ["lower(journal) like :search_term OR lower(journal_abbreviation) like :search_term",
          {:search_term => lc_keywords}])
    elsif keywords.search_field.include?("Summary")
      paginate(:page => page,
        :include => [:taggings,:investigators],
        :per_page => 20,
        :order => "year DESC, authors ASC",
        :conditions => ["lower(investigators.faculty_keywords) like :search_term OR lower(investigators.faculty_research_summary) like :search_term  OR lower(investigators.faculty_interests) like :search_term",
          {:search_term => lc_keywords }])
    elsif keywords.search_field.include?("Keywords")
      # @tags will contain tags to include
      # do_mesh_search is in the MeshHelper
      mesh_terms = MeshHelper.do_mesh_search(lc_keywords)
      mesh_ids = mesh_terms.collect(&:id)

      paginate(:page => page,
        :include => [:taggings,:investigators],
        :per_page => 20,
        :order => "year DESC, authors ASC",
        :conditions => ["lower(investigators.faculty_keywords) like :search_term OR lower(investigators.faculty_research_summary) like :search_term  OR lower(investigators.faculty_interests) like :search_term  OR taggings.tag_id in (:tag_ids)",
          {:search_term => lc_keywords, :tag_ids => mesh_ids }])
    elsif keywords.search_field.include?("MeSH")
      # @tags will contain tags to include
      # do_mesh_search is in the MeshHelper
      mesh_terms = MeshHelper.do_mesh_search(lc_keywords)
      mesh_ids = mesh_terms.collect(&:id)

      paginate(:page => page,
        :include => [:taggings,:investigators],
        :per_page => 20,
        :order => "year DESC, authors ASC",
        :conditions => ["taggings.tag_id in (:tag_ids)",
          {:search_term => lc_keywords, :tag_ids => mesh_ids }])
    else
      mesh_terms = MeshHelper.do_mesh_search(lc_keywords)
      mesh_ids = mesh_terms.collect(&:id)

      paginate(:page => page,
        :per_page => 20,
        :include => [:taggings,:investigators],
        :order => "year DESC, authors ASC",
        :conditions => ["(lower(abstracts.abstract) like :term1 and lower(abstracts.abstract) like :term2 and lower(abstracts.abstract) like :term3) OR (lower(abstracts.title) like :term1 and lower(abstracts.title) like :term2 and lower(abstracts.title) like :term3) OR (lower(abstracts.journal) like :term1 and lower(abstracts.journal) like :term2 and lower(abstracts.journal) like :term3 ) OR (lower(abstracts.authors) like :term1 AND lower(abstracts.authors) like :term2 AND lower(abstracts.authors) like :term3 ) OR lower(investigators.faculty_keywords) like :search_term OR lower(investigators.faculty_research_summary) like :search_term  OR lower(investigators.faculty_interests) like :search_term  or taggings.tag_id in (:tag_ids)",
          {:term1 => terms[0], :term2 => terms[1], :term3 => terms[2], :search_term => lc_keywords, :tag_ids => mesh_ids } ])
    end
  end

  def self.display_search_no_pagination(keywords, lc_keywords)
    if keywords.search_field.include?("Abstract")
      where('lower(abstract) like :search_term',
        {:search_term => lc_keywords})
      .order('year DESC, authors ASC')
      .to_a
    elsif keywords.search_field.include?("Author")
      terms = keywords.keywords.downcase.split(" ",2) + Array.new(1, "")
      terms[1] = terms[0] if terms[1].blank?
      terms[0] = "%"+terms[0]+"%"
      terms[1] = "%"+terms[1]+"%"

      where('(lower(full_authors) like :term1 AND lower(full_authors) like :term2) OR (lower(authors) like :term1 AND lower(authors) like :term2)',
        { :term1 => terms[0], :term2 => terms[1] })
      .order('year DESC, authors ASC')
      .to_a
    elsif keywords.search_field.include?("Title")
      where('lower(title) like :search_term',
        { :search_term => lc_keywords })
      .order('year DESC, authors ASC')
      .to_a
    elsif keywords.search_field.include?("Journal")
      where('lower(journal) like :search_term OR lower(journal_abbreviation) like :search_term',
        { :search_term => lc_keywords })
      .order('year DESC, authors ASC')
      .to_a
    else
      where('lower(abstract) like :search_term OR lower(title) like :search_term OR lower(journal) like :search_term OR lower(authors) like :search_term',
        { :search_term => lc_keywords })
      .order('year DESC, authors ASC')
      .to_a
    end
  end
  # end of legacy for sites running postgres 8.2 or older
end
