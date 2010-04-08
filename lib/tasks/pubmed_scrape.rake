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

task :getPubmedIDs => :getInvestigators do
  #get the pubmed ids
  block_timing("getPubmedIDs") {
    options = BuildSearchOptions(@publication_years)
    pubsFound = FindPubMedIDs (@AllInvestigators, options, @publication_years, @limit_to_institution, @debug, @smart_filters)
    puts "number of publications found for #{@publication_years} years: #{pubsFound}" if @verbose
  }
end

task :getPIAbstracts => :getPubmedIDs do
  #get the abstracts
  block_timing("getPIAbstracts") {
    GetPubsForInvestigators(@AllInvestigators)
  }
end

task :insertAbstracts => :getPIAbstracts do
  # load the test data
  block_timing("insertAbstracts") {
    thisLoad = LoadDate.new(:load_date=> Time.now)
    thisLoad.save
    row_iterator(@AllInvestigators) {  |investigator|
      if !investigator.publications.nil? then
        investigator.publications.each do |publication|
          abstract = InsertPublication(publication)
          if abstract.id > 0 then
             InsertInvestigatorPublication( abstract.id, investigator.id, IsFirstAuthor(abstract,investigator), IsLastAuthor(abstract,investigator) )
          end
        end
      end
    }
  }
end

task :insertAllAbstracts => [:setAllYears, :insertAbstracts] do
  # dependencies do all the work
end

task :associateAbstractsWithInvestigators => [:getAbstracts] do
  # load the test data
  block_timing("associateAbstractsWithInvestigators") {
    row_iterator(@AllAbstracts) {  |abstract|
      investigator_ids = MatchInvestigatorsInCitation(abstract)
      old_investigator_ids = abstract.investigators.collect(&:id).sort.uniq
      all_investigator_ids=(investigator_ids|old_investigator_ids).sort.uniq
      new_ids = all_investigator_ids.delete_if{|id| old_investigator_ids.include?(id)}.compact
      #sped this up by only processing the intersection
      if !(new_ids == [] ) then
        puts "found new investigators for abstract #{abstract.id}. new investigator ids: #{new_ids.join(',')}; old investigator ids: #{old_investigator_ids.join(',')}" if @debug
        new_ids.each do |investigator_id|
          InsertInvestigatorPublication (abstract.id, investigator_id)
        end
        # this fails on the server but not on my laptop...
        # abstract.investigators = Abstract.find(abstract.id).investigators
      end
    }
  }
end

task :updateAbstractInvestigators => [:associateAbstractsWithInvestigators] do
  # load the test data
  block_timing("updateAbstractInvestigators") {
    row_iterator(@AllAbstracts) {  |abstract|
      investigator_ids = abstract.investigators.collect(&:id)
      first_author_id = FindFirstAuthorInCitation(abstract.investigators,abstract)
      last_author_id = FindLastAuthorInCitation(abstract.investigators,abstract)
      UpdateCitationInvestigatorInformation (abstract.id, investigator_ids, first_author_id, last_author_id)
    }
  }
end

task :updateInvestigatorInformation => [:getInvestigators] do
  # load the test data
  block_timing("updateInvestigatorInformation") {
    row_iterator(@AllInvestigators, 0, 50) {  |investigator|
      UpdateInvestigatorCitationInformation(investigator)
    }
  }
end

task :buildCoauthors => [:getInvestigators] do
  # insert all the co-publication data for all authors
  block_timing("BuildCoauthors") {
    row_iterator(@AllInvestigators, 0, 50) { |investigator|
      BuildCoauthors(investigator)
    }
  }
end

task :getInstitutionalPubmedIDs => :environment do
  # get all pubmed IDs using the following keywords:
  block_timing("getInstitutionalPubmedIDs") {
    keywords = InstitutionalSearchTerms()
    options = BuildSearchOptions(@publication_years,50000)
    @all_entries = Bio::PubMed.esearch(keywords, options) # returns an array of pubmed_ids
    puts "task getInstitutionalPubmedIDs: number of publications found for #{@publication_years} years: #{@all_entries.length}" if @verbose
  }
end

task :getInstitutionalPubmedIDsAbstracts => :getInstitutionalPubmedIDs do
  #get the abstracts
  block_timing("getInstitutionalPubmedIDsAbstracts") {
    puts "looking up #{@all_entries.length} pubs" if @debug
    @all_publications = FetchPublicationData(@all_entries) # takes an array of pubmed_ids and returns an array of pubmed records
    puts "task getInstitutionalPubmedIDsAbstracts: number abstracts pulled: #{@all_publications.length}" if @verbose
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
