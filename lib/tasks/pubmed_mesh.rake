require 'find'
require 'date'
require 'utilities' # was row_iterator and other methods
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
  # tag all abstracts with associated MeSH terms
  # about 60 minutes with 46000 abstracts
  # for RHLCCC about 20 minutes with 7800 abstracts and more than 8,000 tags. Total of 120K taggings
  abstract_tag_count = Tagging.count(:conditions=>"taggable_type='Abstract'")
  puts "count of all abstract MeSH tags is #{abstract_tag_count}" if LatticeGridHelper.verbose?
  
  block_timing("tagAbstractsWithMeshTerms") {
    row_iterator(@AllAbstracts) do |abstract|
      TagAbstractWithMeSH(abstract)
    end
  }
  abstract_tag_count = Tagging.count(:conditions=>"taggable_type='Abstract'")
  puts "count of all abstract MeSH tags is #{abstract_tag_count}" if LatticeGridHelper.verbose?
end

task :tagInvestigatorsWithMeshTerms => [:getInvestigators] do
  # tag all investigators with associated MeSH terms from all abstracts
  # about 15 minutes laptop, 20 minutes staging with 2100 investigators and 46000 abstracts
  # for RHLCCC about 10 minutes with 7800 abstracts and 280 investigators
  investigator_tag_count = Tagging.count(:conditions=>"taggable_type='Investigator'")
  puts "count of all investigator MeSH tags is #{investigator_tag_count}" if LatticeGridHelper.verbose?
  start = Time.now

  block_timing("tagInvestigatorsWithMeshTerms") {
    row_iterator(@AllInvestigators, 0, 100, start) do |investigator|
      TagInvestigatorWithMeSH(investigator)
    end
  }
  investigator_tag_count = Tagging.count(:conditions=>"taggable_type='Investigator'")
  puts "count of all investigator MeSH tags is #{investigator_tag_count}" if LatticeGridHelper.verbose?
end

task :tagInvestigatorsWithKeywords => [:getInvestigators] do
  # tag all investigator with faculty_keywords and faculty_interests
  investigator_tag_count = Tagging.count(:conditions=>"taggable_type='Investigator'")
  puts "count of all investigator tags is #{investigator_tag_count}" if LatticeGridHelper.verbose?
  start = Time.now

  block_timing("tagInvestigatorsWithKeywords") {
    row_iterator(@AllInvestigators, 0, 100, start) do |investigator|
      TagInvestigatorWithKeywords(investigator)
    end
  }
  investigator_tag_count = Tagging.count(:conditions=>"taggable_type='Investigator'")
  puts "count of all investigator  tags is #{investigator_tag_count}" if LatticeGridHelper.verbose?
end

task :calculateTagCounts => [:getTags, :getInvestigators, :getAbstracts] do
  #@total_taggings_count=Tagging.find(:all,:conditions=>"taggable_type='Abstract'").length  # get all taggings of abstracts
  @total_publications = Abstract.find(:all).length
  @total_tagged_publications = Abstract.find(:all, :conditions=>"mesh <> ''").length
  @total_investigators = @AllInvestigators.length
  @total_tag_count= @AllTags.length  # same as Abstract.tag_counts.length
end

task :attachMeshInformationContent => :environment do
  # takes about an hour with 12000 tags

  investigator_tag_counts=Investigator.tag_counts(:order=>"count asc")
  investigator_max_tag_count=Investigator.tag_counts(:limit=>5, :order=>"count desc")[0].count

  abstract_tag_counts=Abstract.tag_counts(:order=>"count asc")
  abstract_max_tag_count=Abstract.tag_counts(:limit=>5, :order=>"count desc")[0].count
  
  block_timing("attachMeshInformationContent") {
    row_iterator(investigator_tag_counts) { |tag_count|
      SetMeshInformationContent( tag_count, investigator_max_tag_count, 'Investigator' )
    }
    row_iterator(abstract_tag_counts) { |tag_count|
      SetMeshInformationContent(tag_count, abstract_max_tag_count, 'Abstract' )
    }
  }
end

# this is the task that will take the information content calculations and build up the InvestigatorColleague model
# for the medical school with 3700 investigotors, this takes about 24 hours to run.
# it takes about 6 minutes for the first 10 investigators, depending on number of MeSH terms, total investigators and publications
task :buildInvestigatorColleaguesMesh => [:getInvestigators, :getMeshTags] do
  # load the test data
  block_timing("buildInvestigatorColleaguesMesh") {
    start = Time.now
    num_processed = 0
    cnt = 0 # start at zero or if you want to break this into shorter tasks, you could break it differently
    update_only=false
    last = @AllInvestigators.length-1
    to_process= last-cnt+1
    # this is a 2 (n-1)(n-2) problem. symmetric so it requires only (n-1)(n-2) iterations
    puts "ready to process #{to_process.humanize} investigators relationships starting with row #{cnt} of #{last}" if LatticeGridHelper.verbose?
    row_iterator(@AllInvestigators[cnt..last], 0, 10, start)  { |investigator|
      num_processed+=1
      AnalyzeInvestigatorColleague(investigator, update_only)
    }
    puts "processed #{num_processed} investigator relationships" if LatticeGridHelper.verbose?
  }
end

task :normalizeInvestigatorColleaguesMesh => :environment do
  block_timing("normalizeInvestigatorColleaguesMesh") {
    max_mesh_ic = InvestigatorColleague.find(:first, :order => 'mesh_tags_ic desc').mesh_tags_ic
    if max_mesh_ic < 100
      puts "Unable to normalize. max_mesh_ic = #{max_mesh_ic};"
      break
    end
    mesh_ic_multiplier = 10000.0/max_mesh_ic
    puts "Adjusting slope based on max: max_mesh_ic = #{max_mesh_ic}; mesh_ic_multiplier = #{mesh_ic_multiplier}" if LatticeGridHelper.verbose?
    InvestigatorColleague.update_all("mesh_tags_ic = round(#{mesh_ic_multiplier} * mesh_tags_ic)") if mesh_ic_multiplier < 0.99 or mesh_ic_multiplier > 1.01
    investigator_colleagues_count = InvestigatorColleague.find(:all, :conditions => ['investigator_colleagues.mesh_tags_ic > 2000']).length
    pub_colleagues_count = InvestigatorColleague.find(:all, :conditions => ['investigator_colleagues.publication_cnt > 0']).length
    # the number of records in colleagues should be about 2x  pub_colleagues at 2000 to give about the right MeSH graphs
    max_investigator_colleagues_count = InvestigatorColleague.find(:all, :conditions => ['investigator_colleagues.mesh_tags_ic > 100']).length
    if max_investigator_colleagues_count.to_f / pub_colleagues_count < 2.0
      puts "Unable to normalize count. max_investigator_colleagues_count = #{max_investigator_colleagues_count}; pub_colleagues_count = #{pub_colleagues_count}"
      break
    end
    if (investigator_colleagues_count < 1.4*pub_colleagues_count  or  investigator_colleagues_count > 1.8*pub_colleagues_count)
      puts "investigator_colleagues_count = #{investigator_colleagues_count}; pub_colleagues_count = #{pub_colleagues_count}" if LatticeGridHelper.verbose?
      cutoff = find_cutoff(investigator_colleagues_count, pub_colleagues_count*1.6, 2000)
      # this is the new adjustment - do we need to adjust the Y intercept too?
      # for instance, assume that 6000 needs to be reassigned as 2000
      # compressing all the numbers below 6000 is probably fine, so that "mesh_tags_ic = mesh_tags_ic * multiplier " where "mesh_tags_ic <= cutoff"
      # slope is (new top - new bottom) / (top-bottom) so in this case:  (8000/ (10000-cutoff) * (value-cutoff) ) + 2000
      # if 1000 needs to be reassigned as 2000, this also works
      
      # and above the cutoff we do something like this: "mesh_tags_ic = mesh_tags_ic * multiplier " where "mesh_tags_ic > cutoff"
      mesh_ic_multiplier = 2000.0/cutoff
      puts "Adjusting overall slope: cutoff = #{cutoff}; mesh_ic_multiplier = #{mesh_ic_multiplier}" if LatticeGridHelper.verbose?
      #adjustment for the entire set
      InvestigatorColleague.update_all("mesh_tags_ic = round(#{mesh_ic_multiplier} * mesh_tags_ic)")
    end
      
    # now check if the upper bound is reasonable. if 2000 is about pub_colleagues_count*2.3, 3000 should be about pub_colleagues_count*1.1
    investigator_colleagues_count = InvestigatorColleague.find(:all, :conditions => ['investigator_colleagues.mesh_tags_ic > 3000']).length
    
    if (investigator_colleagues_count < 0.65 *pub_colleagues_count  or  investigator_colleagues_count > 0.9*pub_colleagues_count)
      cut_point = 2000
      cutoff = find_cutoff(investigator_colleagues_count, pub_colleagues_count*0.8, cut_point+1000)
      # need to reslope the line to go from cut_point to cut_point+1000
      mesh_ic_multiplier = 1000.0/(cutoff-cut_point)
      puts "Adjusting from 2000 to 3000: cut_point = #{cut_point}; cutoff = #{cutoff}; mesh_ic_multiplier = #{mesh_ic_multiplier}" if LatticeGridHelper.verbose?
      InvestigatorColleague.update_all("mesh_tags_ic = round(#{mesh_ic_multiplier} * (mesh_tags_ic-#{cut_point})) + #{cut_point}", "mesh_tags_ic > #{cut_point}")
    end

    # now check if the upper bound is reasonable. if 3000 is about pub_colleagues_count*1.1, 4000 should be about pub_colleagues_count*0.5
    investigator_colleagues_count = InvestigatorColleague.find(:all, :conditions => ['investigator_colleagues.mesh_tags_ic > 4000']).length

    if (investigator_colleagues_count < 0.3 *pub_colleagues_count  or  investigator_colleagues_count > 0.5*pub_colleagues_count)
      cut_point = 3000
      cutoff = find_cutoff(investigator_colleagues_count, pub_colleagues_count*0.4, cut_point+1000)
      # need to reslope the line to go from cut_point to cut_point+1000
      mesh_ic_multiplier = 1000.0/(cutoff-cut_point)
      puts "Adjusting from 3000 to 4000: cut_point = #{cut_point}; cutoff = #{cutoff}; mesh_ic_multiplier = #{mesh_ic_multiplier}" if LatticeGridHelper.verbose?
      InvestigatorColleague.update_all("mesh_tags_ic = round(#{mesh_ic_multiplier} * (mesh_tags_ic-#{cut_point})) + #{cut_point}", "mesh_tags_ic > #{cut_point}")
    end

    # now check if the upper bound is reasonable. if 4000 is about pub_colleagues_count*0.55, 5000 should be about pub_colleagues_count*0.27
    investigator_colleagues_count = InvestigatorColleague.find(:all, :conditions => ['investigator_colleagues.mesh_tags_ic > 5000']).length
    
    if investigator_colleagues_count < 0.15 *pub_colleagues_count
      cut_point = 4000
      cutoff = find_cutoff(investigator_colleagues_count, pub_colleagues_count*0.2, cut_point+1000)
      # need to reslope the line to go from cutoff to 5000 starting at 4000
      mesh_ic_multiplier = 1000.0/(cutoff-cut_point)
      puts "Adjusting from 4000 to 5000: cut_point = #{cut_point}; cutoff = #{cutoff}; mesh_ic_multiplier = #{mesh_ic_multiplier}" if LatticeGridHelper.verbose?
      InvestigatorColleague.update_all("mesh_tags_ic = round(#{mesh_ic_multiplier} * (mesh_tags_ic-#{cut_point})) + #{cut_point}", "mesh_tags_ic > #{cut_point}")
    end

    # now readjust from 5000 to 10,000, if upper value is over 10,000
    max_mesh_ic = InvestigatorColleague.find(:first, :order => 'mesh_tags_ic desc').mesh_tags_ic
    if max_mesh_ic > 10000
      cut_point = 5000
      mesh_ic_multiplier = 5000.0 / (max_mesh_ic-cut_point)
      puts "Adjusting upper slope from #{cut_point} to 10000; mesh_ic_multiplier = #{mesh_ic_multiplier}; max_mesh_ic=#{max_mesh_ic};" if LatticeGridHelper.verbose?

      InvestigatorColleague.update_all("mesh_tags_ic = round(#{mesh_ic_multiplier} * (mesh_tags_ic-#{cut_point})) + #{cut_point}", "mesh_tags_ic > #{cut_point}")
    end
    max_mesh_ic = InvestigatorColleague.find(:first, :order => 'mesh_tags_ic desc').mesh_tags_ic
    puts "final max_mesh_ic = #{max_mesh_ic};" if LatticeGridHelper.verbose?
   }
end

task :nightlyBuild => [:insertAbstracts, :updateAbstractInvestigators, :buildCoauthors, :updateInvestigatorInformation, :updateOrganizationAbstractInformation] do
   puts "task nightlyBuild completed. Includes the tasks :insertAbstracts, :updateAbstractInvestigators, :buildCoauthors, :updateInvestigatorInformation, :updateOrganizationAbstractInformation" if LatticeGridHelper.verbose?
end

task :monthlyBuild => [ :tagAbstractsWithMeshTerms, :tagInvestigatorsWithMeshTerms, :tagInvestigatorsWithKeywords, :attachMeshInformationContent, :buildInvestigatorColleaguesMesh, :normalizeInvestigatorColleaguesMesh] do
  puts "task monthlyBuild completed. Includes the tasks :tagAbstractsWithMeshTerms, :tagInvestigatorsWithMeshTerms, :tagInvestigatorsWithKeywords, :attachMeshInformationContent, :buildInvestigatorColleaguesMesh, :normalizeInvestigatorColleaguesMesh" if LatticeGridHelper.verbose?
end