# -*- coding: utf-8 -*-

require 'spec_helper'
require_relative 'shared_examples'


module Test
  module Importer
    # Isolate the PubMed for now to make sure other methods in the class
    # works as expected. This is temporary since I have limited time to
    # refactor.
    #
    # Next refactoring steps:
    #   1. Redue size of isolation from find_pubmed_ids method
    #      to only the Bio::PubMed.esearch(keywords, options) call
    #   2. Mock out the PubMed http request with webmock and add specs
    #   3. Extract logic that maps pubmed ids to investigator since that's
    #      a common behavior in other importers
    # 
    class PubMedIsolated < ::LatticeGrid::Importer::PubMed
      FAKE_MAPPINGS = {
        :wakibbe => [123456, 987654],
        :jstarren => [333333]
      }

      # Uses the fake mappings in place of the PubMed search. 
      # WARNING...WARNING...WARNING:
      # I'm attempting to duplicate the behavior in Importer::PubMed
      # as a temporary way to test othe parts of the code before refactoring.
      def find_pubmed_ids(all_investigators, options, number_years, debug = false, smart_filters = false)
        @all_investigators.each do |investigator|
          investigator['entries'] = FAKE_MAPPINGS[investigator.username.to_sym]
        end
        FAKE_MAPPINGS.values.flatten.size
      end
    end
  end
end

describe LatticeGrid::Importer::PubMed do
  let(:investigators) do
    [] << Investigator.new(:username => 'wakibbe') << Investigator.new(:username => 'jstarren')
  end

  subject(:subject) do 
    Test::Importer::PubMedIsolated.new.tap do |p|
      p.attributes = { :all_investigators => investigators }
    end
  end

  it_should_behave_like "a faculty publications api consumer"

  it 'retrieves all faculty publications' do
    subject.faculty_publications.should ==
      [
        {:pmid => 123456, :netid => 'wakibbe'},
        {:pmid => 987654, :netid => 'wakibbe'},
        {:pmid => 333333, :netid => 'jstarren'}
      ]
  end

  it 'keeps a counter of found publications (for legacy code)' do
    subject.faculty_publications
    subject.faculty_publication_count.should == 3
  end
end