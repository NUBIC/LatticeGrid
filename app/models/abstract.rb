class Abstract < ActiveRecord::Base
  include MeshHelper
  
  has_many :journals, :foreign_key => "journal_abbreviation", :primary_key =>  "journal_abbreviation", :readonly => true
  has_many :investigator_abstracts
  has_many :investigators, :through => :investigator_abstracts,
    :conditions => ['(investigators.end_date is null or investigators.end_date >= :now) and investigator_abstracts.end_date is null', {:now => Date.today }]
  has_many :investigator_appointments, :through => :investigator_abstracts,
    :conditions => ['investigator_appointments.end_date is null or investigator_appointments.end_date >= :now', 
      {:now => Date.today }]
  has_many :organization_abstracts,
        :conditions => ['organization_abstracts.end_date is null or organization_abstracts.end_date >= :now', {:now => Date.today }]
  has_many :organizational_units, :through => :organization_abstracts
  validates_uniqueness_of :pubmed
  acts_as_taggable  # for MeSH terms
  
  has_many :organization_abstracts,
        :conditions => ['organization_abstracts.end_date is null or organization_abstracts.end_date >= :now', {:now => Date.today }]
  named_scope :abstracts_last_five_years, 
        :conditions => ['(publication_date >= :start_date or electronic_publication_date  >= :start_date)', 
          {:start_date => 5.years.ago }]
  named_scope :abstracts_by_date, lambda { |*dates|
      {:conditions => 
          [' publication_date between :start_date and :end_date or electronic_publication_date between :start_date and :end_date ', 
            {:start_date => dates.first, :end_date => dates.last } ] }
  }
  named_scope :ccsg_abstracts_by_date, lambda { |*dates|
      {:conditions => 
          ['is_cancer = true and (publication_date between :start_date and :end_date or electronic_publication_date between :start_date and :end_date) ', 
            {:start_date => dates.first, :end_date => dates.last } ] }
    }

  named_scope :by_ids, lambda { |*ids|
      {:conditions => ['id IN (:ids) ', {:ids => ids.first}] }
    }
  default_scope :conditions => 'abstracts.deleted_at is null'


  def self.include_deleted( id=nil )
    with_exclusive_scope do
      if id.blank?
        find(:all)
      else
        find(id)
      end
    end
  end

  def self.find_by_pubmed_include_deleted( val )
    with_exclusive_scope do
        find_by_pubmed(val)
    end
  end

  def self.display_all_investigator_data_include_deleted( investigator_id )
    with_exclusive_scope do
      find(:all,
        :order => "year DESC, authors ASC",
        :joins => :investigator_abstracts,
        :conditions => ["investigator_abstracts.investigator_id = :investigator_id", {:investigator_id => investigator_id}])
    end
  end

  def self.from_journal_include_deleted(journal_abbreviation)
    with_exclusive_scope do
      find(:all,
          :conditions => ['lower(journal_abbreviation) = :journal_abbreviation',{:journal_abbreviation => journal_abbreviation}],
          :order => "year DESC, authors ASC" )
    end
  end
  
  def self.from_journal(journal_abbreviation)
      find(:all,
          :conditions => ['lower(journal_abbreviation) = :journal_abbreviation',{:journal_abbreviation => journal_abbreviation}],
          :order => "year DESC, authors ASC" )
  end
  
  def self.co_authors(abstracts)
    author_ids=abstracts.collect{|ab| ab.investigators.collect(&:id)}.flatten.sort.uniq
    Investigator.find(:all, :conditions =>  ["id IN (:author_ids)", 
      {:author_ids => author_ids }], :order => "lower(last_name), lower(first_name)" )
  end
  def self.annual_data( years)
    conditions = "year IN (#{Journal.yearstring(years)}) "
    find(:all,
        :order => "authors ASC",
        :conditions =>  "#{conditions}")
  end

  def self.missing_publications(years, journals)
    conditions = "year IN (#{Journal.yearstring(years)}) "
    find(:all, 
      :select => "count(*) as count_all, journal, journal_abbreviation",
      :conditions => ["lower(journal_abbreviation) NOT IN (:abbreviations) AND #{conditions}", 
        {:abbreviations => Journal.journal_to_array(journals) }],
      :group => "journal, journal_abbreviation", 
      :order => "count_all DESC" )
  end

  def self.display_data( year=2008, page=1)
    paginate(:page => page,
      :per_page => 20, 
      :order => "publication_date DESC, electronic_publication_date DESC, authors ASC",
 		  :conditions => ['year = :year', 
  		      {:year => year }])
  end
  
  def self.display_all_data( year=2008)
    find(:all,
      :order => "investigators.last_name ASC, authors ASC",
      :include => [:investigators, :investigator_abstracts],
 		  :conditions => ['year = :year and investigator_abstracts.end_date is null', 
  		      {:year => year }])
  end
  
  def self.display_investigator_data( investigator_id, page=1)
    paginate(:page => page,
      :per_page => 20, 
      :order => "year DESC, authors ASC",
      :joins => [:investigators],
      :conditions => ["investigators.id = :investigator_id", {:investigator_id => investigator_id}])
  end

  def self.display_all_investigator_data( investigator_id )
    find(:all,
      :order => "year DESC, authors ASC",
      :joins => [:investigators],
    :conditions => ["investigators.id = :investigator_id", {:investigator_id => investigator_id}])
  end
  
  def self.investigator_publications( investigators, number_years=5)
    cutoff_date=number_years.years.ago
    find(:all,
       :joins => [:investigators, :investigator_abstracts],
  		  :conditions => ['(publication_date >= :start_date or electronic_publication_date  >= :start_date) and investigator_abstracts.investigator_id IN (:investigators) and investigator_abstracts.end_date is null', 
   		      {:start_date => cutoff_date, :investigators => investigators }])
  end
  
  def self.display_abstracts_by_date( unit_id, pub_start_date, pub_end_date )
    find(:first,
      :order => "abstracts.year DESC, authors ASC",
      :include => [:abstracts],
  		:conditions => ['organizational_units.id = :unit_id AND abstracts.publication_date between :pub_start_date and :pub_end_date', 
   		      {:unit_id => unit_id, :pub_start_date => pub_start_date, :pub_end_date => pub_end_date}])
  end

  def self.display_search(keywords, paginate=1, page=1)
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
      find :all, 
        :order => "year DESC, authors ASC",
        :conditions => ["lower(abstract) like :search_term",
           {:search_term => lc_keywords}]
    elsif keywords.search_field.include?("Author")
       terms = keywords.keywords.downcase.split(" ",2) + Array.new(1, "")
       terms[1] = terms[0] if terms[1].blank?
       terms[0] = "%"+terms[0]+"%"
       terms[1] = "%"+terms[1]+"%"
       find :all, 
          :order => "year DESC, authors ASC",
          :conditions => ["(lower(full_authors) like :term1 AND lower(full_authors) like :term2) OR (lower(authors) like :term1 AND lower(authors) like :term2)",
             {:term1 => terms[0], :term2 => terms[1]}]
    elsif keywords.search_field.include?("Title")
      find :all, 
          :order => "year DESC, authors ASC",
          :conditions => ["lower(title) like :search_term",
             {:search_term => lc_keywords}]
    elsif keywords.search_field.include?("Journal")
      find :all, 
          :order => "year DESC, authors ASC",
          :conditions => ["lower(journal) like :search_term OR lower(journal_abbreviation) like :search_term",
             {:search_term => lc_keywords}]
    else
      find :all, 
          :order => "year DESC, authors ASC",
          :conditions => ["lower(abstract) like :search_term OR lower(title) like :search_term OR lower(journal) like :search_term OR lower(authors) like :search_term",
            {:search_term => lc_keywords}]
    end
  end
end
