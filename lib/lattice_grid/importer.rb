# -*- encoding : utf-8 -*-

module LatticeGrid
  module Importer
    def self.configuration
      @configuration ||= LatticeGrid::Importer::Configuration.new
    end

    def self.configure(&block)
      configuration.enhance(&block)
    end

    def self.faculty_publication_importer
      case configuration.faculty_publication_source
      when :pub_med
        LatticeGrid::Importer::PubMed.new
      when :nubic_faculty_ws
        LatticeGrid::Importer::NubicFacultyWS.new
      else
        raise "Unable to find faculty_publications_source: #{configuration.faculty_publications_source}"
      end
    end
  end
end