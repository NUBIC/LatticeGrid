class Abstract < ActiveRecord::Base
  has_many :journals, :foreign_key => "journal_abbreviation", :primary_key =>  "journal_abbreviation", :readonly => true
  has_many :investigator_abstracts
  has_many :investigators, :through => :investigator_abstracts,
    :conditions => ['investigators.end_date is null or investigators.end_date >= :now', {:now => Date.today }]
  has_many :investigator_appointments, :through => :investigator_abstracts
  has_many :organization_abstracts,
        :conditions => ['organization_abstracts.end_date is null or organization_abstracts.end_date >= :now', {:now => Date.today }]
  has_many :organizational_units, :through => :organization_abstracts
  validates_uniqueness_of :pubmed
  acts_as_taggable  # for MeSH terms

  def self.annual_data( year)
    conditions="year = #{year}" if !year.blank?
    find(:all,
        :order => "authors ASC",
  		  :conditions => conditions||"" )
  end
  
  def self.missing_publications(year, found_journals)
    abbreviations = found_journals.collect{|x| x.journal_abbreviation.downcase}
    conditions = ""
    conditions = " AND abstracts.year = #{year}" if ! year.blank?
    # sortby should be one of impact_factor DESC, count_all DESC, journals.journal_abbreviation
    find(:all, 
      :select => "count(*) as count_all, journal, journal_abbreviation",
  		:conditions => ["lower(journal_abbreviation) NOT IN (:abbreviations) #{conditions}", 
   		      {:abbreviations => abbreviations }],
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
 		  :conditions => ['year = :year', 
  		      {:year => year }])
  end
  
  def self.display_investigator_data( investigator_id, page=1)
    paginate(:page => page,
      :per_page => 20, 
      :order => "year DESC, authors ASC",
      :joins => [:investigator_abstracts],
      :conditions => ["investigator_abstracts.investigator_id = :investigator_id", {:investigator_id => investigator_id}])
  end

  def self.display_all_investigator_data( investigator_id )
    find(:all,
      :order => "year DESC, authors ASC",
      :joins => :investigator_abstracts,
      :conditions => ["investigator_abstracts.investigator_id = :investigator_id", {:investigator_id => investigator_id}])
  end
  
  def self.investigator_publications( investigators, number_years=5)
    cutoff_date=number_years.years.ago
    find(:all,
       :joins => [:investigators, :investigator_abstracts],
  		  :conditions => ['(publication_date >= :start_date or electronic_publication_date  >= :start_date) and investigator_abstracts.investigator_id IN (:investigators)', 
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
    if keywords.search_field.include?("Abstract")
      paginate(:page => page,
        :per_page => 20, 
        :order => "year DESC, authors ASC",
        :conditions => ["lower(abstract) like :search_term",
           {:search_term => lc_keywords}])
    elsif keywords.search_field.include?("Author")
       terms = keywords.keywords.downcase.split(" ",2) + Array.new(1, "")
       terms[1] = terms[0] if terms[1].blank?
       terms[0] = "%"+terms[0]+"%"
       terms[1] = "%"+terms[1]+"%"
       paginate(:page => page,
          :per_page => 20, 
          :order => "year DESC, authors ASC",
          :conditions => ["(lower(full_authors) like :term1 AND lower(full_authors) like :term2) OR (lower(authors) like :term1 AND lower(authors) like :term2)",
             {:term1 => terms[0], :term2 => terms[1]}])
    elsif keywords.search_field.include?("Title")
       paginate(:page => page,
          :per_page => 20, 
          :order => "year DESC, authors ASC",
          :conditions => ["lower(title) like :search_term",
             {:search_term => lc_keywords}])
    elsif keywords.search_field.include?("Journal")
       paginate(:page => page,
          :per_page => 20, 
          :order => "year DESC, authors ASC",
          :conditions => ["lower(journal) like :search_term OR lower(journal_abbreviation) like :search_term",
             {:search_term => lc_keywords}])
    else
      paginate(:page => page,
          :per_page => 20, 
          :order => "year DESC, authors ASC",
          :conditions => ["lower(abstract) like :search_term OR lower(title) like :search_term OR lower(journal) like :search_term OR lower(authors) like :search_term",
             {:search_term => lc_keywords}])
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
