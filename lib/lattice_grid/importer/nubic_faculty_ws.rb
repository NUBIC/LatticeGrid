# -*- coding: utf-8 -*-

module LatticeGrid
  module Importer
    class NubicFacultyWS
      class << self
        attr_writer :base_url
      end

      def self.base_url
        @base_url ||= 'https://clinical-rails-prod.nubic.northwestern.edu/ws-faculty'
      end

      def faculty_publications
        response = Faraday.get("#{self.class.base_url}/faculty_publications")
        if response.success?
          JSON.parse(response.body).map(&:symbolize_keys)
        else
          raise RuntimeError.new("Failed to retreive faculty publications from '#{self.class.base_url}/faculty_publications': Status Code #{response.status}")
        end
      end


      module LegacySupport
        def attributes=(opts={}); end

        def associate_investigators_with_publications(investigators, faculty_publications)
          grouped = faculty_publications.group_by {|p| p[:netid] }
          found = investigators.select { |i| i.username.present? }
          found.each do |investigator|
            key = investigator.username
            investigator['entries'] = grouped[key]
            investigator['mark_pubs_as_valid'] = true
          end
        end
      end
      include LegacySupport
    end
  end
end