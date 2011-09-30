class Journal < ActiveRecord::Base
  has_many :abstracts, 
    :foreign_key => "issn", 
    :primary_key =>  "issn", 
    :readonly => true,
    :order => "year DESC, authors ASC"

  def self.match_by_abbrev( )
      find(:all, 
        :select => " DISTINCT journals.id, journals.score_year, journals.impact_factor, journals.journal_abbreviation, journals.issn, journals.total_cites, journals.impact_factor_five_year, journals.immediacy_index, journals.total_articles, journals.eigenfactor_score, journals.article_influence_score, abstracts.issn as pubmed_issn",
        :joins => " INNER JOIN Abstracts ON lower(abstracts.journal_abbreviation) = lower(journals.journal_abbreviation)",
        :conditions => [" NOT EXISTS (select 'x' from Abstracts where abstracts.issn = journals.issn) "],
        :order => "journals.journal_abbreviation" )
  end

  def all_publications( )
    Abstract.from_journal_include_deleted(journal_abbreviation.downcase)
  end

  def publications( )
    Abstract.from_journal_include_deleted(journal_abbreviation.downcase)
  end

  def self.high_impact_issns(impact=10.0 )
    all(
      :select => "issn",
      :conditions => ['impact_factor >= :impact', 
            {:impact => impact}] )
  end

  def self.preferred_high_impact_issns()
    all(
      :select => "issn",
      :conditions => ['include_as_high_impact = true'] )
  end

  def self.high_impact(impact=10.0 )
    # order should be one of impact_factor DESC, count_all DESC, journals.journal_abbreviation
    all(
      :select => "id, score_year, impact_factor, journal_abbreviation, issn, total_cites, impact_factor_five_year, immediacy_index, total_articles, eigenfactor_score, article_influence_score",
      :conditions => ['impact_factor >= :impact', 
            {:impact => impact}],
      :order => "impact_factor DESC" )
    # score_year DESC, shows if more than one score year is used
  end

  def self.preferred_high_impact()
   # order should be one of impact_factor DESC, count_all DESC, journals.journal_abbreviation
    all(
      :select => "id, score_year, impact_factor, journal_abbreviation, issn, total_cites, impact_factor_five_year, immediacy_index, total_articles, eigenfactor_score, article_influence_score",
      :conditions => ['include_as_high_impact = true'],
      :order => "impact_factor DESC" )
    # score_year DESC, shows if more than one score year is used
  end

  def self.journal_publications( years, sortby )
    sortby = sortby.blank? ? "impact_factor DESC" : sortby
    conditions = " AND #{sortby.sub(/desc/i,'')} > 0.001" if (sortby =~ /desc/i ) and (sortby !~ /count_all/i )
    # sortby should be one of impact_factor DESC, count_all DESC, journals.journal_abbreviation
    find(:all, 
      :select => "count(*) as count_all, journals.id, journals.score_year, journals.impact_factor, journals.journal_abbreviation, journals.issn, journals.total_cites, journals.impact_factor_five_year, journals.immediacy_index, journals.total_articles, journals.eigenfactor_score, journals.article_influence_score",
      :joins => :abstracts,
      :conditions => [" abstracts.year IN (:years) AND journals.impact_factor > 0.001 #{conditions}", {:years => yearstring(years)}],
      :group => "journals.id, journals.score_year, journals.impact_factor, journals.journal_abbreviation, journals.issn, journals.total_cites, journals.impact_factor_five_year, journals.immediacy_index, journals.total_articles, journals.eigenfactor_score, journals.article_influence_score", 
      :order => "#{sortby}" )
      # score_year DESC, shows if more than one score year is used
  end

  def self.high_impact_publications(years, impact=5.0)
    all( 
      :select => "count(*) as count_all, journals.id, journals.score_year, journals.impact_factor, journals.journal_abbreviation, journals.issn, journals.total_cites, journals.impact_factor_five_year, journals.immediacy_index, journals.total_articles, journals.eigenfactor_score, journals.article_influence_score",
      :joins => :abstracts,
      :conditions => ["journals.impact_factor >= :impact AND abstracts.year IN (:years)", 
           {:impact => impact, :years => yearstring(years) }],
      :group => "journals.id, journals.score_year, journals.impact_factor, journals.journal_abbreviation, journals.issn, journals.total_cites, journals.impact_factor_five_year, journals.immediacy_index, journals.total_articles, journals.eigenfactor_score, journals.article_influence_score", 
      :order => "count_all DESC, score_year DESC" )
   end
  
  def self.journal_to_array(journals)
    journals.collect{|x| x.journal_abbreviation.downcase}.sort.uniq.compact
  end
  
  def self.yearstring(years)
    return '' if years.blank?
    year_string = years.to_s
    # logger.warn("years = #{year_string}, cnt  =#{year_string.split(',').length}")
    year_string.split(',')
  end
end
