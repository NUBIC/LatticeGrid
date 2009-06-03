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
   start = Time.now
   options = BuildSearchOptions(@publication_years)
   pubsFound = FindPubMedIDs (@AllInvestigators, options, @publication_years, @limit_to_institution, @debug, @smart_filters)
   stop = Time.now
   elapsed_seconds = stop.to_f - start.to_f
   puts "number of publications found for #{@publication_years} years: #{pubsFound} in #{elapsed_seconds} seconds" if @verbose
end

task :getPIAbstracts => :getPubmedIDs do
  #get the abstracts
  start = Time.now
  GetPubsForInvestigators(@AllInvestigators)
  stop = Time.now
  elapsed_seconds = stop.to_f - start.to_f
  puts " abstracts pulled in #{elapsed_seconds} seconds" if @verbose
end

task :insertAbstracts => :getPIAbstracts do
  # load the test data
  start = Time.now
  @AllInvestigators.each do |investigator|
    if !investigator.publications.nil? then
      investigator.publications.each do |publication|
        abstract = InsertPublication(publication)
        if abstract.id > 0 then
           InsertInvestigatorPublication( abstract.id, investigator.id, IsFirstAuthor(abstract,investigator), IsLastAuthor(abstract,investigator) )
        end
      end
    end
  end
  stop = Time.now
  elapsed_seconds = stop.to_f - start.to_f
  puts "task insertAbstracts ran in #{elapsed_seconds} seconds" if @verbose
end

task :insertAllAbstracts => [:setAllYears, :insertAbstracts] do
  # dependencies do all the work
end

task :associateAbstractsWithInvestigators => [:getAbstracts, :getInvestigators] do
  # load the test data
  start = Time.now
  @AllAbstracts.each do |abstract|
    investigator_ids = MatchInvestigatorsInCitation(@AllInvestigators,abstract)
    old_investigator_ids = abstract.investigators.collect(&:id).sort.uniq
    all_investigator_ids=(investigator_ids|old_investigator_ids).sort.uniq
    new_ids = all_investigator_ids.delete_if{|id| old_investigator_ids.include?(id)}.compact
    #sped this up by only processing the intersection
    if !(new_ids == [] ) then
      puts "found new investigators for abstract #{abstract.id}. new investigator ids: #{new_ids.join(',')}; old investigator ids: #{old_investigator_ids.join(',')}" if @verbose
      new_ids.each do |investigator_id|
        InsertInvestigatorPublication (abstract.id, investigator_id)
      end
    end
  end
  stop = Time.now
  elapsed_seconds = stop.to_f - start.to_f
  puts "task associateAbstractsWithInvestigators ran in #{elapsed_seconds} seconds" if @verbose
end

task :updateAbstractInvestigators => [:associateAbstractsWithInvestigators] do
  # load the test data
  updateAbstractInvestigatorsStart = Time.now
  @AllAbstracts.each do |abstract|
    investigator_ids = abstract.investigators.collect(&:id)
    first_author_id = FindFirstAuthorInCitation(abstract.investigators,abstract)
    last_author_id = FindLastAuthorInCitation(abstract.investigators,abstract)
    UpdateCitationInvestigatorInformation (abstract.id, investigator_ids, first_author_id, last_author_id)
   end
  stop = Time.now
  elapsed_seconds = stop.to_f - updateAbstractInvestigatorsStart.to_f
  puts "task updateAbstractInvestigators ran in #{elapsed_seconds} seconds" if @verbose
end

task :updateInvestigatorInformation => [:getInvestigators] do
  # load the test data
  start = Time.now
  @AllInvestigators.each do |investigator|
    UpdateInvestigatorCitationInformation(investigator)
   end
  stop = Time.now
  elapsed_seconds = stop.to_f - start.to_f
  puts "task updateInvestigatorInformation ran in #{elapsed_seconds} seconds" if @verbose
end


task :getInstitutionalPubmedIDs => :environment do
  # get all pubmed IDs using the following keywords:
  start = Time.now
  keywords = InstitutionalSearchTerms()
  options = BuildSearchOptions(@publication_years,50000)
  @all_entries = Bio::PubMed.esearch(keywords, options)
  stop = Time.now
  elapsed_seconds = stop.to_f - start.to_f
  puts "task getInstitutionalPubmedIDs: number of publications found for #{@publication_years} years: #{@all_entries.length} in #{elapsed_seconds} seconds" if @verbose
end

task :getInstitutionalPubmedIDsAbstracts => :getInstitutionalPubmedIDs do
  #get the abstracts
  theCnt = 0
  theSize = 499
  theEnd = 0
  start = Time.now
  puts "looking up #{@all_entries.length} pubs" if @debug
  while theCnt < @all_entries.length do
    theEnd = theCnt+theSize
    theEnd = @all_entries.length-1 if theEnd > @all_entries.length-1 
    puts "Slicing all_entries from #{theCnt} to #{theEnd}" if @debug
    mySlice = @all_entries[theCnt..theEnd]
    puts "looking up #{mySlice.length} pubs from #{theCnt} to #{theEnd}" if @debug
    theCnt = theEnd+1
    printSlice(mySlice) if @debug
    pubs = Bio::PubMed.efetch(mySlice)
    inspectObject(pubs[0]) if @debug
    puts "found #{pubs.length} pubs" if @debug
    @all_publications =  @all_publications + pubs
  end
  stop = Time.now
  elapsed_seconds = stop.to_f - start.to_f
  puts "task getInstitutionalPubmedIDsAbstracts: number abstracts pulled: #{@all_publications.length} in #{elapsed_seconds} seconds" if @verbose
end

task :insertInstitutionalAbstracts => :getInstitutionalPubmedIDsAbstracts do
  # load the test data
  start = Time.now
  @all_publications.each do |publication|
      abstract = InsertPublication(publication)
   end
  stop = Time.now
  elapsed_seconds = stop.to_f - start.to_f
  puts "task insertInstitutionalAbstracts ran in #{elapsed_seconds} seconds" if @verbose
end

task :insertAllInstitutionalAbstracts => [:setAllYears, :insertInstitutionalAbstracts] do
  # dependencies do all the work
  puts "task insertAllInstitutionalAbstracts completed"
end
