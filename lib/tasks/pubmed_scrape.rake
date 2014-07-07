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
  block_timing("insertAbstracts") {
    thisLoad = LoadDate.new(:load_date=> Time.now)
    thisLoad.save
    puts "investigator.mark_pubs_as_valid is #{(@AllInvestigators[0].mark_pubs_as_valid || limit_pubmed_search_to_institution())}"
    row_iterator(@AllInvestigators) {  |investigator|
      if !investigator.publications.nil? then
        investigator.publications.each do |publication|
          abstract = InsertPublication(publication)
          unless abstract.blank? or abstract.id.blank? or abstract.id < 1 then
            thePIPub = InsertInvestigatorPublication( abstract.id, investigator.id, (abstract.publication_date||abstract.electronic_publication_date||abstract.deposited_date), IsFirstAuthor(abstract,investigator), IsLastAuthor(abstract,investigator), (investigator.mark_pubs_as_valid || limit_pubmed_search_to_institution()) )
            # check to see if we should set as valid if it has not been reviewed!
            if (investigator.mark_pubs_as_valid || limit_pubmed_search_to_institution()) and ! thePIPub.is_valid 
              if (thePIPub.last_reviewed_at.blank? || thePIPub.last_reviewed_id == 0) and (thePIPub.last_reviewed_ip.blank? or thePIPub.last_reviewed_ip =~ /abstract|migration/i ) then
                thePIPub.is_valid = true
                thePIPub.save!
              end
            elsif (!investigator.mark_pubs_as_valid) and thePIPub.is_valid 
              if (thePIPub.last_reviewed_id.blank? or thePIPub.last_reviewed_id < 1) and (thePIPub.last_reviewed_ip.blank? or thePIPub.last_reviewed_ip =~ /abstract|migration/i ) then
                thePIPub.is_valid = false
                thePIPub.save!
              end
            end
            if thePIPub.is_valid and abstract.is_valid == false and (abstract.last_reviewed_id.blank? or abstract.last_reviewed_id < 1) and (abstract.last_reviewed_ip.blank? or abstract.last_reviewed_ip =~ /abstract|migration/i ) then
              abstract.is_valid    = true
              abstract.last_reviewed_id    = 0
              abstract.last_reviewed_at    = Time.now
              abstract.last_reviewed_ip    = 'added valid investigator_abstract'
              abstract.save!
            end
          end
        end
      end
    }
  }
end

def get_pubmed_ids
  block_timing("getPubmedIDs") {
    options = BuildSearchOptions(@publication_years)
    pubsFound = FindPubMedIDs(@AllInvestigators, options, @publication_years, LatticeGridHelper.debug?, LatticeGridHelper.smart_filters?)
    puts "number of publications found for #{@publication_years} years: #{pubsFound}" if LatticeGridHelper.verbose?
  }
end

def get_pi_abstracts
  block_timing("getPIAbstracts") {
    GetPubsForInvestigators(@AllInvestigators)
  }
end

task :getPubmedIDs => :getInvestigators do
  #get the pubmed ids
  get_pubmed_ids()
end

task :getPIAbstracts => :getPubmedIDs do
  #get the abstracts
  get_pi_abstracts()
end

task :insertAbstracts => :getPIAbstracts do
  # load the test data
  do_insert_abstracts()
  if LatticeGridHelper.global_limit_pubmed_search_to_institution?() == false then
    #repeat with limited to institution and trust the results
    limit_pubmed_search_to_institution(true)
    get_pubmed_ids()
    get_pi_abstracts()
    do_insert_abstracts()
  end
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
        puts "found new investigators for abstract #{abstract.id}. new investigator ids: #{new_ids.join(',')}; old investigator ids: #{old_investigator_ids.join(',')}" if LatticeGridHelper.debug?
        new_ids.each do |investigator_id|
          investigator=Investigator.find(investigator_id)
          InsertInvestigatorPublication(abstract.id, investigator_id, (abstract.publication_date||abstract.electronic_publication_date||abstract.deposited_date), IsFirstAuthor(abstract,investigator), IsLastAuthor(abstract,investigator), true)
        end
        # this fails on the server but not on my laptop...
        # abstract.investigators = Abstract.find(abstract.id).investigators
      end
    }
    @AllAbstracts = Abstract.find(:all, :order => 'id')
  }
end

task :updateAbstractInvestigators => [:associateAbstractsWithInvestigators] do
  # load the test data
  block_timing("updateAbstractInvestigators") {
    row_iterator(@AllAbstracts) {  |abstract|
      investigator_ids = abstract.investigators.collect(&:id)
      first_author_id = FindFirstAuthorInCitation(abstract.investigators,abstract)
      last_author_id = FindLastAuthorInCitation(abstract.investigators,abstract)
      UpdateCitationInvestigatorInformation(abstract.id, investigator_ids, first_author_id, last_author_id)
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
    keywords = LatticeGridHelper.institutional_limit_search_string()
    options = BuildSearchOptions(@publication_years,50000)
    @all_entries = Bio::PubMed.esearch(keywords, options) # returns an array of pubmed_ids
    puts "task getInstitutionalPubmedIDs: number of publications found for #{@publication_years} years: #{@all_entries.length}" if LatticeGridHelper.verbose?
  }
end

task :getInstitutionalPubmedIDsAbstracts => :getInstitutionalPubmedIDs do
  #get the abstracts
  block_timing("getInstitutionalPubmedIDsAbstracts") {
    puts "looking up #{@all_entries.length} pubs" if LatticeGridHelper.debug?
    @all_publications = FetchPublicationData(@all_entries) # takes an array of pubmed_ids and returns an array of pubmed records
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


task :getMeSHPubmedIDs => :environment do
  # get all pubmed IDs using the following keywords:
  block_timing("getMeSHPubmedIDs") {
    keywords = BuildSearchByMeSHterms()
    options = BuildSearchOptions(@publication_years,50000)
    if keywords.blank?
      @all_entries = nil
      puts "getMeSHPubmedIDs did not return a MeSH search string. No abstracts found"
    else
      @all_entries = Bio::PubMed.esearch(keywords, options) # returns an array of pubmed_ids
      puts "task getMeSHPubmedIDs: number of publications found for #{@publication_years} years: #{@all_entries.length}" if LatticeGridHelper.verbose?
    end
  }
end

task :getMeSHPubmedIDsAbstracts => :getMeSHPubmedIDs do
  #get the abstracts
  block_timing("getMeSHPubmedIDsAbstracts") {
    puts "looking up #{@all_entries.length} pubs" if LatticeGridHelper.debug?
    @all_publications = FetchPublicationData(@all_entries) # takes an array of pubmed_ids and returns an array of pubmed records
    puts "task getInstitutionalPubmedIDsAbstracts: number abstracts pulled: #{@all_publications.length}" if LatticeGridHelper.verbose?
  }
end

task :insertMeSHAbstracts => :getMeSHPubmedIDsAbstracts do
  # load the test data
  block_timing("insertMeSHAbstracts") {
    InsertPubmedRecords(@all_publications)
  }
end

task :insertAllMeSHAbstracts => [:setAllYears, :insertMeSHAbstracts] do
  # dependencies do all the work
  puts "task insertAllMeSHAbstracts completed"
end
