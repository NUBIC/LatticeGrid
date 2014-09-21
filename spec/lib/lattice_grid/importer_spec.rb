# -*- coding: utf-8 -*-

require 'spec_helper'

describe LatticeGrid::Importer do
  describe '#faculty_publications_importer' do
    before(:each) do
      LatticeGrid::Importer.configure do |c|
        # c.faculty_publication_source :nubic_faculty_ws
        c.faculty_publication_source :pub_med
      end
    end
    
    it 'instantiates an instance of the importer class' do
      LatticeGrid::Importer.faculty_publication_importer.class.should == LatticeGrid::Importer::PubMed
    end
  end
end
