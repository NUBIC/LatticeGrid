# -*- coding: utf-8 -*-

module LatticeGrid
  module Importer
    class PubMed
      def attributes=(opts={})
        @all_investigators = opts[:all_investigators]
        @search_options = opts[:search_options]
        @number_years = opts[:number_years]
        @debug = opts[:debug]
        @smart_filters = opts[:smart_filters]
      end

      def faculty_publications
        find_pubmed_ids(@all_investigators, @search_options, @number_years, @debug, @smart_filters)
        @all_investigators.map do |investigator|
          netid = investigator.username
          pmids = investigator['entries']
          pmids.map do |pmid| 
            { :pmid => pmid, :netid => netid }
          end
        end.flatten
      end

      def find_pubmed_ids(all_investigators, options, number_years, debug = false, smart_filters = false)
        cnt = 0
        all_investigators.each do |investigator|
          # reset counters
          attempt = 0
          repeat_cnt = 0
          entries = nil
          perform_esearch = true
          keywords = build_pi_search(investigator, true)
          investigator['mark_pubs_as_valid'] = limit_to_institution(investigator)
          while perform_esearch && repeat_cnt < 3 && attempt < 4
            begin
              # puts "esearch keywords = #{keywords}; repeat_cnt=#{repeat_cnt}"
              entries = Bio::PubMed.esearch(keywords, options)
              # puts "esearch results: #{entries.length} pubs for investigator #{investigator.first_name} #{investigator.last_name} using the keywords #{keywords} were found"
              if entries.length < 1 && smart_filters && ! LatticeGridHelper.global_pubmed_search_full_first_name?
                keywords = build_pi_search(investigator, false)
              elsif entries.length > (LatticeGridHelper.expected_max_pubs_per_year * number_years) && smart_filters && repeat_cnt < 3 && !limit_pubmed_search_to_institution
                keywords = limit_search_to_institution(keywords, investigator)
              else
                investigator['mark_pubs_as_valid'] = true if LatticeGridHelper.mark_full_name_searches_as_valid? && repeat_cnt == 0
                perform_esearch = false
              end
             rescue Timeout::Error => exc
               if attempt < 4
                 puts "esearch Failed call with keywords: #{keywords}; options: #{options}; for investigator #{investigator.first_name} #{investigator.last_name}"
                 puts "exception = #{exc.message}"
                 puts 'trying again!'
                 retry
               end
               raise "Failed call with keywords: #{keywords}; options: #{options}; for investigator #{investigator.first_name} #{investigator.last_name}"
             rescue Exception => error
              attempt += 1
              puts "Failed call with keywords: #{keywords}; options: #{options}; for investigator #{investigator.first_name} #{investigator.last_name}"
              retry if attempt < 3
              raise
            end
            repeat_cnt += 1
          end
          # leaving perform_esearch
          investigator['entries'] = entries
          if entries.length < 1
            puts "No publications found for investigator #{investigator.first_name} #{investigator.last_name} using the keywords #{keywords}" if debug
          elsif entries.length > (LatticeGridHelper.expected_max_pubs_per_year * number_years)
            puts "Too many hits??: #{entries.length} pubs for investigator #{investigator.first_name} #{investigator.last_name} using the keywords #{keywords} were found. repeat_cnt = #{repeat_cnt}"
          elsif entries.length < number_years
            puts "Too few found: #{entries.length} pubs for investigator #{investigator.first_name} #{investigator.last_name} using the keywords #{keywords} were found" if debug
            investigator['entries'] = entries
          else
            puts "#{entries.length} pubs for investigator #{investigator.first_name} #{investigator.last_name} using the keywords #{keywords} were found" if debug
            investigator['entries'] = entries
          end
          # reset these if we make it this far
          # puts "Done with investigator #{investigator.first_name} #{investigator.last_name}"
          cnt = cnt + entries.length
        end
        cnt
      end

      ##
      # This has an empty implementation because the method #find_pubmed_ids
      # already associates investigators with their publications. Once there is
      # more time I will split #find_pubmed_ids into separate methods for data 
      # retrieval and investigator pmid associate, similar to 
      # how Importer::NubicFacultyWS works.
      def associate_investigators_with_publications(investigators, faculty_publications)
      end
    end
  end
end