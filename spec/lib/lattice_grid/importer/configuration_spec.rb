# -*- coding: utf-8 -*-

require 'spec_helper'

describe LatticeGrid::Importer::Configuration do
  def config_from(&block)
    LatticeGrid::Importer::Configuration.new(&block)
  end

  describe '#faculty_publication_source' do
    it 'defaults to pub_med' do
      config_from.faculty_publication_source.should == :pub_med
    end

    it 'is can be changed' do
      c = config_from { faculty_publication_source :foo }
      c.faculty_publication_source.should == :foo
    end
  end
end