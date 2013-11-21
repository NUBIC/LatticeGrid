# == Schema Information
# Schema version: 20131121210426
#
# Table name: investigator_abstracts
#
#  abstract_id      :integer          not null
#  created_at       :timestamp
#  id               :integer          not null, primary key
#  investigator_id  :integer          not null
#  is_first_author  :boolean          default(FALSE), not null
#  is_last_author   :boolean          default(FALSE), not null
#  is_valid         :boolean          default(FALSE), not null
#  last_reviewed_at :timestamp
#  last_reviewed_id :integer
#  last_reviewed_ip :string(255)
#  publication_date :date
#  reviewed_at      :timestamp
#  reviewed_id      :integer
#  reviewed_ip      :string(255)
#  updated_at       :timestamp
#

require File.dirname(__FILE__) + '/../test_helper'

class InvestigatorAbstractTest < Test::Unit::TestCase
#  fixtures :investigator_abstracts

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
