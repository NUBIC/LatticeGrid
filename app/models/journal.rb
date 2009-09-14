class Journal < ActiveRecord::Base
  has_many :abstracts, :foreign_key => "journal_abbreviation", :primary_key =>  "journal_abbreviation", :readonly => true
  
  def self.journals_with_scores( journal_abbrev_array )
    find(:all,
      :order => "score_year,journal_abbreviation",
  		:conditions => ['lower(journal_abbreviation) IN (:journal_abbrev_array)', 
   		      {:journal_abbrev_array => journal_abbrev_array}])
  end

  def self.publication_record( year, sortby )
    sortby = sortby.blank? ? "impact_factor DESC" : sortby
    conditions = "journals.impact_factor > 0.001"
    conditions = "#{sortby.sub(/desc/i,'')} > 0.001" if (sortby =~ /desc/i ) and (sortby !~ /count_all/i )
    conditions += " AND abstracts.year = #{year}" if ! year.blank?
    # sortby should be one of impact_factor DESC, count_all DESC, journals.journal_abbreviation
    find(:all, 
      :select => "count(*) as count_all, journals.score_year, journals.impact_factor, journals.journal_abbreviation, journals.issn, journals.total_cites, journals.impact_factor_five_year, journals.immediacy_index, journals.total_articles, journals.eigenfactor_score, journals.article_influence_score",
      :joins => "INNER JOIN abstracts on lower(abstracts.journal_abbreviation) = lower(journals.journal_abbreviation)",
   		:conditions => conditions, 
      :group => "journals.score_year, journals.impact_factor, journals.journal_abbreviation, journals.issn, journals.total_cites, journals.impact_factor_five_year, journals.immediacy_index, journals.total_articles, journals.eigenfactor_score, journals.article_influence_score", 
      :order => "journals.score_year DESC, #{sortby}" )
  end

  def self.high_impact( )
    sortby = "article_influence_score DESC" 
    conditions = "impact_factor >= 5.0"
    # sortby should be one of impact_factor DESC, count_all DESC, journals.journal_abbreviation
    find(:all,
      :select => "score_year, impact_factor, journal_abbreviation, issn, total_cites, impact_factor_five_year, immediacy_index, total_articles, eigenfactor_score, article_influence_score",
   		:conditions => conditions, 
      :order => "score_year DESC, #{sortby}" )
  end

end
