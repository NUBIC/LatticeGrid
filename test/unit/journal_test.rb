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

require 'test_helper'

class JournalTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
