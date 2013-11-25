# == Schema Information
# Schema version: 20131121210426
#
# Table name: word_frequencies
#
#  created_at :timestamp        not null
#  frequency  :integer
#  id         :integer          default(0), not null, primary key
#  the_type   :string(255)
#  updated_at :timestamp        not null
#  word       :string(255)
#

require 'test_helper'

class WordFrequencyTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
