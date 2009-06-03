require 'find'
require 'date'
#require 'fileutils'
#require 'bio' #require bioruby!
require 'publication_utilities' #all the helper methods
require 'mesh_utilities' #information content utility
require 'pubmed_config' #look here to change the default time spans
#require 'pubmedext' #my extensions to grab other dates and full author names
#require 'tasks/obo_parser'
#require 'tasks/tree_traversal'

require 'rubygems'

task :tagAbstractsWithMeshTerms => [:getAbstracts] do
  # about 60 minutes with 46000 abstracts
  # for RHLCCC about 20 minutes with 7800 abstracts and more than 8,000 tags. Total of 120K taggings
  start = Time.now
  @AllAbstracts.each do |abstract|
    TagAbstractWithMeSH (abstract)
   end
  stop = Time.now
  elapsed_seconds = stop.to_f - start.to_f
  puts "task tagAbstractsWithMeshTerms ran in #{elapsed_seconds} seconds" if @verbose
end

task :tagInvestigatorsWithMeshTerms => [:getInvestigators] do
  # about 15 minutes laptop, 20 minutes staging with 2100 investigators and 46000 abstracts
  # for RHLCCC about 10 minutes with 7800 abstracts and 280 investigators
  start = Time.now
  @AllInvestigators.each do |investigator|
    TagInvestigatorWithMeSH (investigator)
   end
  stop = Time.now
  elapsed_seconds = stop.to_f - start.to_f
  puts "task tagInvestigatorsWithMeshTerms ran in #{elapsed_seconds} seconds" if @verbose
end

task :calculateTagCounts => [:getTags, :getInvestigators] do
  #@total_taggings_count=Tagging.find(:all,:conditions=>"taggable_type='Abstract'").length  # get all taggings of abstracts
  @total_publications = Abstract.find(:all).length
  @total_tagged_publications = Abstract.find(:all, :conditions=>"mesh <> ''").length
  @total_investigators = @AllInvestigators.length
  @total_tag_count= @AllTags.length  # same as Abstract.tag_counts.length
end

task :attachMeshInformationContent => :calculateTagCounts do
  # takes about an hour with 12000 tags
  start = Time.now
  cnt = 0
  @AllTags.each do |tag|
    SetMeshInformationContent(tag.name)
    cnt+=1
    if (cnt / 1000).round * 1000 == cnt
      stop = Time.now
      elapsed_seconds = stop.to_f - start.to_f
      puts "attachMeshInformationContent processed #{cnt} tags in #{elapsed_seconds} seconds"
    end
  end
  stop = Time.now
  elapsed_seconds = stop.to_f - start.to_f
  puts "task attachMeshInformationContent ran in #{elapsed_seconds} seconds" if @verbose
end

# this is the task that will take the information content calculations and build up the InvestigatorRelationship model
task :buildInvestigatorRelationships => [:getInvestigators, :getMeshTags] do
  # load the test data
  start = Time.now
  cnt = 0
  last = @AllInvestigators.length-1
  @AllInvestigators.each do |investigator|
    cnt+=1
    @AllInvestigators[cnt..last].each do |colleague|
      BuildInvestigatorRelationship (investigator, colleague)
    end
    if (cnt / 10).round * 10 == cnt
      stop = Time.now
      elapsed_seconds = stop.to_f - start.to_f
      puts "buildInvestigatorRelationships processed #{cnt} investigators in #{elapsed_seconds} seconds"
    end
   end
  stop = Time.now
  elapsed_seconds = stop.to_f - start.to_f
  puts "task updateProgramAbstractInformation ran in #{elapsed_seconds} seconds" if @verbose
end

task :nightlyBuild => [:insertAbstracts, :associateAbstractsWithInvestigators, :updateAbstractInvestigators, :updateInvestigatorInformation, :tagAbstractsWithMeshTerms, :tagInvestigatorsWithMeshTerms, :updateProgramAbstractInformation] do
   puts "task nightlyBuild completed. Includes the tasks :insertAbstracts, :updateAbstractInvestigators, :updateInvestigatorInformation, :tagAbstractsWithMeshTerms, :tagInvestigatorsWithMeshTerms, :updateProgramAbstractInformation " if @verbose
end

task :monthlyBuild => [ :attachMeshInformationContent, :buildInvestigatorRelationships] do
  puts "task monthlyBuild completed. Includes the tasks :attachMeshInformationContent, :buildInvestigatorRelationships " if @verbose
end