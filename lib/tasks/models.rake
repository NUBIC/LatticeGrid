require 'pubmed_config' #look here to change the default time spans

require 'rubygems'

task :setAllYears => :environment do
  @publication_years = @all_years
end

task :getInvestigators => :environment do
  # load all investigators
  # @AllInvestigators = Investigator.find(:all,  :conditions => ['end_date is null or end_date >= :now', {:now => Date.today }])
  begin
    @AllInvestigators = Investigator.find(:all, :order => 'id', :include => ["abstracts"])
  rescue
    @AllInvestigators = Investigator.find(:all, :order => 'id')
  end
  
#  @AllInvestigators = Investigator.find(:all, :conditions => "id=1")
  puts "count of all investigators is #{@AllInvestigators.length}" if @verbose
end

task :getMeshTags => :environment do
    @AllInvestigatorMeshTags = Tagging.find(:all, :joins => :tag, :select=> "distinct information_content, tag_id, tags.name", :conditions=>"taggable_type='Investigator'")
    puts "count of all investigator MeSH tags is #{@AllInvestigatorMeshTags.length}" if @verbose
    @AllAbstractMeshTags = Tagging.find(:all, :joins => :tag, :select=> "distinct information_content, tag_id, tags.name", :conditions=>"taggable_type='Abstract'")
    puts "count of all abstract MeSH tags is #{@AllAbstractMeshTags.length}" if @verbose
end

task :getPrimaryAppointments => :environment do
  # load distinct Departments from Investigators
  @AllPrimaryAppointments = Investigator.distinct_primary_appointments()
  
   puts "count of all investigator home appointments is #{@AllPrimaryAppointments.length}" if @verbose
end

task :getAllOrganizations => :environment do
  # load all organizations that have an investigator
  @AllOrganizations = OrganizationalUnit.find(:all)
  
  puts "count of all organizations is #{@AllOrganizations.length}" if @verbose
end

task :getAllOrganizationsWithInvestigators => :environment do
  # load all organizations that have an investigator
  @AllInvestigatorAssociations = Investigator.distinct_all_appointments_and_memberships()
  
  puts "count of all organizations with investigators (including primary appointments) is #{@AllInvestigatorAssociations.length}" if @verbose
end

task :getAllMembers => :environment do
  # load all organizations that have an investigator
  @AllMembers = Investigator.all_members()
  
  puts "count of all investigators  with a membership is #{@AllMembers.length}" if @verbose
end

task :getAllInvestigatorsWithoutMembership => :environment do
  # load all organizations that have an investigator
  @InvestigatorsWithoutMembership = Investigator.not_members()
  
  puts "count of all investigators  without a membership is #{@InvestigatorsWithoutMembership.length}" if @verbose
end

task :getAbstracts => :environment do
  # load all abstracts
  begin
    if ENV['RAILS_ENV'] != 'production'
      @AllAbstracts = Abstract.find(:all, :order => 'id', :include => ["investigator_abstracts","investigators"])
    else
      @AllAbstracts = Abstract.find(:all, :order => 'id')
    end
  rescue
    @AllAbstracts = Abstract.find(:all, :order => 'id')
  end
  puts "count of all abstracts is #{@AllAbstracts.length}" if @verbose
  if @verbose then
    investigator_abstracts_length = @AllAbstracts.collect{|x| x.investigator_abstracts.length }.sum
    puts "count of all investigator_abstracts is #{investigator_abstracts_length}"
  end
end

task :getTags => :environment do
  # load all tags
  @AllTags = Tag.find(:all)
  puts "count of all tags is #{@AllTags.length}" if @verbose
end

task :getInvestigatorColleagues => :environment do
  # load all investigator_colleagues
  @AllInvestigatorColleagues = InvestigatorColleague.find(:all)
  puts "count of all investigator_colleagues is #{@AllInvestigatorColleagues.length}" if @verbose
end

task :updateOrganizationAbstractInformation => [:getAllOrganizationsWithInvestigators] do
  # load the test data
  block_timing("updateOrganizationAbstractInformation") {
    row_iterator(@AllInvestigatorAssociations) {  |unit_id|
      investigators = OrganizationalUnit.find(unit_id).primary_faculty+OrganizationalUnit.find(unit_id).associated_faculty
      puts "count of all investigators for organizational unit #{unit_id} is #{investigators.length}" if @verbose
      abstracts = Abstract.investigator_publications(investigators.collect(&:id), 10).uniq
      puts "count of all abstracts for organizational unit #{unit_id} is #{abstracts.length}" if @verbose
      abstracts.each do |abstract|
        UpdateOrganizationAbstract (unit_id,abstract.id)
      end
    }
  }
end

