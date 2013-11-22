# == Schema Information
# Schema version: 20130327155943
#
# Table name: journals
#
#  article_influence_score  :float
#  created_at               :timestamp
#  eigenfactor_score        :float
#  id                       :integer          default(0), not null, primary key
#  immediacy_index          :float
#  impact_factor            :float
#  impact_factor_five_year  :float
#  include_as_high_impact   :boolean          default(FALSE), not null
#  issn                     :string(255)
#  jcr_journal_abbreviation :string(255)
#  journal_abbreviation     :string(255)      not null
#  journal_name             :string(255)
#  score_year               :integer
#  total_articles           :integer
#  total_cites              :integer
#  updated_at               :timestamp
#

class Journal < ActiveRecord::Base
  has_many :abstracts,
    :foreign_key => 'issn',
    :primary_key =>  'issn',
    :readonly => true,
    :order => 'year DESC, authors ASC'

  def self.match_by_abbrev
    select('DISTINCT journals.id, journals.score_year, journals.impact_factor, journals.journal_abbreviation, journals.issn, journals.total_cites, journals.impact_factor_five_year, journals.immediacy_index, journals.total_articles, journals.eigenfactor_score, journals.article_influence_score, abstracts.issn as pubmed_issn')
      .joins('INNER JOIN Abstracts ON lower(abstracts.journal_abbreviation) = lower(journals.journal_abbreviation)')
      .where("NOT EXISTS (select 'x' from Abstracts where abstracts.issn = journals.issn)")
      .order('journals.journal_abbreviation')
      .to_a
  end

  def all_publications
    Abstract.from_journal_include_deleted(journal_abbreviation.downcase)
  end

  def publications
    Abstract.from_journal_include_deleted(journal_abbreviation.downcase)
  end

  def self.high_impact_issns(impact = 12.0)
    select('issn').where('impact_factor >= :impact', { :impact => impact }).to_a
  end

  def self.preferred_high_impact_issns
    select('issn').where('impact_factor = true').to_a
  end

  def self.high_impact(impact = 12.0)
    # order should be one of impact_factor DESC, count_all DESC, journals.journal_abbreviation
    select('id, score_year, impact_factor, journal_abbreviation, issn, total_cites, impact_factor_five_year, immediacy_index, total_articles, eigenfactor_score, article_influence_score')
      .where('impact_factor >= :impact', { :impact => impact })
      .order('impact_factor DESC')
      .to_a
    # score_year DESC, shows if more than one score year is used
  end

  def self.preferred_high_impact
   # order should be one of impact_factor DESC, count_all DESC, journals.journal_abbreviation
   select('id, score_year, impact_factor, journal_abbreviation, issn, total_cites, impact_factor_five_year, immediacy_index, total_articles, eigenfactor_score, article_influence_score')
     .where('include_as_high_impact = true')
     .order('impact_factor DESC')
     .to_a
  end

  def self.journal_publications(years, sortby)
    # sortby should be one of impact_factor DESC, count_all DESC, journals.journal_abbreviation
    sortby = sortby.blank? ? "impact_factor DESC" : sortby
    conditions = "AND #{sortby.sub(/desc/i,'')} > 0.001" if (sortby =~ /desc/i ) and (sortby !~ /count_all/i)

    select("count(*) as count_all, journals.id, journals.score_year, journals.impact_factor, journals.journal_abbreviation, journals.issn, journals.total_cites, journals.impact_factor_five_year, journals.immediacy_index, journals.total_articles, journals.eigenfactor_score, journals.article_influence_score")
      .joins(:abstracts)
      .where("abstracts.year IN (:years) AND journals.impact_factor > 0.001 #{conditions}", { :years => yearstring(years) })
      .group("journals.id, journals.score_year, journals.impact_factor, journals.journal_abbreviation, journals.issn, journals.total_cites, journals.impact_factor_five_year, journals.immediacy_index, journals.total_articles, journals.eigenfactor_score, journals.article_influence_score")
      .order(sortby.to_s)
      .to_a
  end

  def self.high_impact_publications(years, impact = 5.0)
    select("count(*) as count_all, journals.id, journals.score_year, journals.impact_factor, journals.journal_abbreviation, journals.issn, journals.total_cites, journals.impact_factor_five_year, journals.immediacy_index, journals.total_articles, journals.eigenfactor_score, journals.article_influence_score")
      .joins(:abstracts)
      .where("journals.impact_factor >= :impact AND abstracts.year IN (:years)", { :impact => impact, :years => yearstring(years) })
      .group("journals.id, journals.score_year, journals.impact_factor, journals.journal_abbreviation, journals.issn, journals.total_cites, journals.impact_factor_five_year, journals.immediacy_index, journals.total_articles, journals.eigenfactor_score, journals.article_influence_score")
      .order("count_all DESC, score_year DESC")
      .to_a
   end

  def self.journal_to_array(journals)
    journals.collect{ |x| x.journal_abbreviation.downcase }.sort.uniq.compact
  end

  def self.yearstring(years)
    return '' if years.blank?
    years.to_s.split(',')
  end
end
