class Journal < ActiveRecord::Base
  has_many :abstracts, 
    :foreign_key => "journal_abbreviation", 
    :primary_key =>  "journal_abbreviation", 
    :readonly => true,
    :order => "year DESC, authors ASC"

  def publications( )
    Abstract.from_journal_include_deleted(journal_abbreviation.downcase)
  end

  def self.journals_with_scores( journals )
    find(:all,
      :order => "score_year,journal_abbreviation",
      :conditions => ['lower(journal_abbreviation) IN (:journals)', 
           {:journals => journal_to_array(journals)}])
  end

  def self.high_impact(impact=5.0 )
    sortby = "impact_factor DESC" 
    # sortby should be one of impact_factor DESC, count_all DESC, journals.journal_abbreviation
    find(:all,
      :select => "id, score_year, impact_factor, journal_abbreviation, issn, total_cites, impact_factor_five_year, immediacy_index, total_articles, eigenfactor_score, article_influence_score",
      :conditions => ['impact_factor >= :impact', 
            {:impact => impact}],
      :order => "score_year DESC, #{sortby}" )
  end

  def self.journal_publications( years, sortby )
    sortby = sortby.blank? ? "impact_factor DESC" : sortby
    conditions = " abstracts.year IN (#{yearstring(years)}) "
    conditions += " AND journals.impact_factor > 0.001"
    conditions += " AND #{sortby.sub(/desc/i,'')} > 0.001" if (sortby =~ /desc/i ) and (sortby !~ /count_all/i )
    # sortby should be one of impact_factor DESC, count_all DESC, journals.journal_abbreviation
    find(:all, 
      :select => "count(*) as count_all, journals.id, journals.score_year, journals.impact_factor, journals.journal_abbreviation, journals.issn, journals.total_cites, journals.impact_factor_five_year, journals.immediacy_index, journals.total_articles, journals.eigenfactor_score, journals.article_influence_score",
      :joins => "INNER JOIN abstracts on lower(abstracts.journal_abbreviation) = lower(journals.journal_abbreviation)",
      :conditions => "#{conditions}",
      :group => "journals.id, journals.score_year, journals.impact_factor, journals.journal_abbreviation, journals.issn, journals.total_cites, journals.impact_factor_five_year, journals.immediacy_index, journals.total_articles, journals.eigenfactor_score, journals.article_influence_score", 
      :order => "journals.score_year DESC, #{sortby}" )
  end

  def self.with_publications(years, journals)
    conditions = " abstracts.year IN (#{yearstring(years)}) "
     find(:all, 
      :select => "count(*) as count_all, journals.id, journals.score_year, journals.impact_factor, journals.journal_abbreviation, journals.issn, journals.total_cites, journals.impact_factor_five_year, journals.immediacy_index, journals.total_articles, journals.eigenfactor_score, journals.article_influence_score",
      :joins => "INNER JOIN abstracts on lower(abstracts.journal_abbreviation) = lower(journals.journal_abbreviation)",
      :conditions => ["lower(abstracts.journal_abbreviation) IN (:abbreviations) AND journals.impact_factor > 0.001 AND #{conditions}", 
           {:abbreviations => journal_to_array(journals) }],
      :group => "journals.id, journals.score_year, journals.impact_factor, journals.journal_abbreviation, journals.issn, journals.total_cites, journals.impact_factor_five_year, journals.immediacy_index, journals.total_articles, journals.eigenfactor_score, journals.article_influence_score", 
      :order => "count_all DESC" )
   end
  
  def self.journal_to_array(journals)
    journals.collect{|x| x.journal_abbreviation.downcase}.sort.uniq.compact
  end
  
  def self.yearstring(years)
    return '' if years.nil? or years.length == 0
    year_string = years.to_s
    # logger.warn("years = #{year_string}, cnt  =#{year_string.split(',').length}")
    "'"+year_string.split(',').join("\', \'")+"'"
  end
end
