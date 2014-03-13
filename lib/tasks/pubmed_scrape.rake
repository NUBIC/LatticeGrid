require 'find'
require 'date'
require 'fileutils'
require 'bio' #require bioruby!
require 'utilities' #all the helper methods
require 'pubmed_utilities' #all the helper methods
require 'pubmed_config' #look here to change the default time spans
require 'pubmedext' #my extensions to grab other dates and full author names
#require 'tasks/obo_parser'
#require 'tasks/tree_traversal'

require 'rubygems'

def do_insert_abstracts
  block_timing("insert_abstracts") do
    thisLoad = LoadDate.new(:load_date=> Time.now)
    thisLoad.save
    puts "investigator.mark_pubs_as_valid is #{(@all_investigators[0].mark_pubs_as_valid || limit_pubmed_search_to_institution)}"
    row_iterator(@all_investigators) do |investigator|
      if !investigator.publications.nil? then
        investigator.publications.each do |publication|
          abstract = InsertPublication(publication)
          unless abstract.blank? || abstract.id.blank? || abstract.id < 1
            thePIPub = InsertInvestigatorPublication( abstract.id, investigator.id, (abstract.publication_date||abstract.electronic_publication_date||abstract.deposited_date), IsFirstAuthor(abstract,investigator), is_last_author?(abstract,investigator), (investigator.mark_pubs_as_valid || limit_pubmed_search_to_institution) )
            # check to see if we should set as valid if it has not been reviewed!
            if (investigator.mark_pubs_as_valid || limit_pubmed_search_to_institution) && !thePIPub.is_valid
              if (thePIPub.last_reviewed_at.blank? || thePIPub.last_reviewed_id == 0) && (thePIPub.last_reviewed_ip.blank? || thePIPub.last_reviewed_ip =~ /abstract|migration/i)
                thePIPub.is_valid = true
                thePIPub.save!
              end
            elsif (!investigator.mark_pubs_as_valid) && thePIPub.is_valid
              if (thePIPub.last_reviewed_id.blank? || thePIPub.last_reviewed_id < 1) && (thePIPub.last_reviewed_ip.blank? || thePIPub.last_reviewed_ip =~ /abstract|migration/i)
                thePIPub.is_valid = false
                thePIPub.save!
              end
            end
            if thePIPub.is_valid && abstract.is_valid == false && (abstract.last_reviewed_id.blank? || abstract.last_reviewed_id < 1) && (abstract.last_reviewed_ip.blank? || abstract.last_reviewed_ip =~ /abstract|migration/i)
              abstract.is_valid         = true
              abstract.last_reviewed_id = 0
              abstract.last_reviewed_at = Time.now
              abstract.last_reviewed_ip = 'added valid investigator_abstract'
              abstract.save!
            end
          end
        end
      end
    end
  end
end

def get_pubmed_ids
  block_timing("get_pubmed_ids") do
    options = build_search_options(@publication_years)
    pubsFound = find_pubmed_ids(@all_investigators, options, @publication_years, LatticeGridHelper.debug?, LatticeGridHelper.smart_filters?)
    puts "number of publications found for #{@publication_years} years: #{pubsFound}" if LatticeGridHelper.verbose?
  end
end

def get_pi_abstracts
  block_timing("get_pi_abstracts") { get_pubs_for_investigators(@all_investigators) }
end

task :get_pubmed_ids_task => :get_investigators do
  get_pubmed_ids
end

task :get_pi_abstracts_task => :get_pubmed_ids_task do
  get_pi_abstracts
end

task :insert_abstracts => :get_pi_abstracts_task do
  # load the test data
  do_insert_abstracts
  if LatticeGridHelper.global_limit_pubmed_search_to_institution? == false
    # repeat with limited to institution and trust the results
    limit_pubmed_search_to_institution(true)
    get_pubmed_ids
    get_pi_abstracts
    do_insert_abstracts
  end
end

task :insertAllAbstracts => [:setAllYears, :insert_abstracts] do
  # dependencies do all the work
end

task :associateAbstractsWithInvestigators => [:getAbstracts] do
  # load the test data
  block_timing("associateAbstractsWithInvestigators") do
    row_iterator(@all_abstracts) do |abstract|
      investigator_ids = MatchInvestigatorsInCitation(abstract)
      old_investigator_ids = abstract.investigators.collect(&:id).sort.uniq
      all_investigator_ids=(investigator_ids|old_investigator_ids).sort.uniq
      new_ids = all_investigator_ids.delete_if { |id| old_investigator_ids.include?(id) }.compact
      # sped this up by only processing the intersection
      unless (new_ids == [])
        puts "found new investigators for abstract #{abstract.id}. new investigator ids: #{new_ids.join(',')}; old investigator ids: #{old_investigator_ids.join(',')}" if LatticeGridHelper.debug?
        new_ids.each do |investigator_id|
          investigator=Investigator.find(investigator_id)
          InsertInvestigatorPublication(abstract.id, investigator_id, (abstract.publication_date||abstract.electronic_publication_date||abstract.deposited_date), IsFirstAuthor(abstract,investigator), is_last_author?(abstract,investigator), true)
        end
        # this fails on the server but not on my laptop...
        # abstract.investigators = Abstract.find(abstract.id).investigators
      end
    end
    @all_abstracts = Abstract.find(:all, :order => 'id')
  end
end

task :updateAbstractInvestigators => [:associateAbstractsWithInvestigators] do
  # load the test data
  block_timing("updateAbstractInvestigators") do
    row_iterator(@all_abstracts) do |abstract|
      investigator_ids = abstract.investigators.collect(&:id)
      first_author_id = FindFirstAuthorInCitation(abstract.investigators,abstract)
      last_author_id = FindLastAuthorInCitation(abstract.investigators,abstract)
      UpdateCitationInvestigatorInformation(abstract.id, investigator_ids, first_author_id, last_author_id)
    end
  end
end

task :updateInvestigatorInformation => [:get_investigators] do
  # load the test data
  block_timing("updateInvestigatorInformation") {
    row_iterator(@all_investigators, 0, 50) {  |investigator|
      UpdateInvestigatorCitationInformation(investigator)
    }
  }
end

task :buildCoauthors => [:get_investigators] do
  # insert all the co-publication data for all authors
  block_timing("BuildCoauthors") {
    row_iterator(@all_investigators, 0, 50) { |investigator|
      BuildCoauthors(investigator)
    }
  }
end

task :getInstitutionalPubmedIDs => :environment do
  # get all pubmed IDs using the following keywords:
  block_timing("getInstitutionalPubmedIDs") {
    keywords = LatticeGridHelper.institutional_limit_search_string
    options = build_search_options(@publication_years, 50000)
    @all_entries = Bio::PubMed.esearch(keywords, options) # returns an array of pubmed_ids
    puts "task getInstitutionalPubmedIDs: number of publications found for #{@publication_years} years: #{@all_entries.length}" if LatticeGridHelper.verbose?
  }
end

task :getInstitutionalPubmedIDsAbstracts => :getInstitutionalPubmedIDs do
  #get the abstracts
  block_timing("getInstitutionalPubmedIDsAbstracts") {
    puts "looking up #{@all_entries.length} pubs" if LatticeGridHelper.debug?
    @all_publications = fetch_publication_data(@all_entries) # takes an array of pubmed_ids and returns an array of pubmed records
    puts "task getInstitutionalPubmedIDsAbstracts: number abstracts pulled: #{@all_publications.length}" if LatticeGridHelper.verbose?
  }
end

task :insertInstitutionalAbstracts => :getInstitutionalPubmedIDsAbstracts do
  # load the test data
  block_timing("insertInstitutionalAbstracts") {
    InsertPubmedRecords(@all_publications)
  }
end

task :insertAllInstitutionalAbstracts => [:setAllYears, :insertInstitutionalAbstracts] do
  # dependencies do all the work
  puts "task insertAllInstitutionalAbstracts completed"
end
