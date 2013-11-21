# == Schema Information
# Schema version: 20131121210426
#
# Table name: word_frequencies
#
#  created_at :timestamp
#  frequency  :integer
#  id         :integer          not null, primary key
#  the_type   :string(255)
#  updated_at :timestamp
#  word       :string(255)
#

require 'test_helper'

class WordFrequencyTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
