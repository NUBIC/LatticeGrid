require 'pubmed_config' #look here to change the default time spans
require 'utilities'

require 'rubygems'

task :setAllYears => :environment do
  @publication_years = LatticeGridHelper.all_years
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
  puts "count of all investigators is #{@AllInvestigators.length}" if LatticeGridHelper.verbose?
end

task :getMeshTags => :environment do
    @AllInvestigatorMeshTags = Tagging.find(:all, :joins => :tag, :select=> "distinct information_content, tag_id, tags.name", :conditions=>"taggable_type='Investigator'")
    puts "count of all investigator MeSH tags is #{@AllInvestigatorMeshTags.length}" if LatticeGridHelper.verbose?
    @AllAbstractMeshTags = Tagging.find(:all, :joins => :tag, :select=> "distinct information_content, tag_id, tags.name", :conditions=>"taggable_type='Abstract'")
    puts "count of all abstract MeSH tags is #{@AllAbstractMeshTags.length}" if LatticeGridHelper.verbose?
end

task :getPrimaryAppointments => :environment do
  # load distinct Departments from Investigators
  @AllPrimaryAppointments = Investigator.distinct_primary_appointments()
  
   puts "count of all investigator home appointments is #{@AllPrimaryAppointments.length}" if LatticeGridHelper.verbose?
end

task :getAllOrganizations => :environment do
  # load all organizations that have an investigator
  @AllOrganizations = OrganizationalUnit.find(:all)
  
  puts "count of all organizations is #{@AllOrganizations.length}" if LatticeGridHelper.verbose?
end

task :getAllOrganizationsNotUpdated => :environment do
  # load all organizations that have an investigator
  directly_updated = OrganizationalUnit.all(:conditions=> ['updated_at >= :recently', {:recently => Date.yesterday}]).compact
  parents = directly_updated.collect{|org| org.parent}.compact
  grandparents = parents.collect{|org| org.parent}.compact
  all_organizations_updated = (directly_updated + parents + OrganizationalUnit.roots + grandparents).sort.uniq
  
  @AllOrganizationsNotUpdated = OrganizationalUnit.all(:conditions=> ['id NOT IN (:ids)', {:ids => all_organizations_updated.collect(&:id)}] ).compact

  puts "Updated Orgs: #{all_organizations_updated.collect(&:abbreviation).join(", ")}" if LatticeGridHelper.verbose?
  puts "Unupdated Orgs: #{@AllOrganizationsNotUpdated.collect(&:abbreviation).join(", ")}" if LatticeGridHelper.verbose?
  puts "count of all organizations not updated is #{@AllOrganizationsNotUpdated.length}" if LatticeGridHelper.verbose?
end

task :getAllOrganizationsWithInvestigators => :environment do
  # load all organizations that have an investigator
  @AllInvestigatorAssociations = Investigator.distinct_all_appointments_and_memberships()
  
  puts "count of all organizations with investigators (including primary appointments) is #{@AllInvestigatorAssociations.length}" if LatticeGridHelper.verbose?
end

task :getAllMembers => :environment do
  # load all organizations that have an investigator
  
  @AllMembers = Investigator.all_with_membership()
  
  puts "count of all_with_membership is #{@AllMembers.length}" if LatticeGridHelper.verbose?
  
  @AllMembers = Investigator.all_members()
  
  puts "count of all investigator memberships (all_members) is #{@AllMembers.length}" if LatticeGridHelper.verbose?
end

task :getAllInvestigatorsWithoutMembership => :environment do
  # load all organizations that have an investigator
  @InvestigatorsWithoutMembership = Investigator.not_members()
  
  puts "count of all investigators without a membership is #{@InvestigatorsWithoutMembership.length}" if LatticeGridHelper.verbose?
end

task :getAbstracts => :environment do
  # load all abstracts
  begin
    if Rails.env != 'production'
      @AllAbstracts = Abstract.find(:all, :order => 'id', :include => ["investigator_abstracts","investigators"])
    else
      @AllAbstracts = Abstract.find(:all, :order => 'id')
    end
  rescue
    @AllAbstracts = Abstract.find(:all, :order => 'id')
  end
  puts "count of all abstracts is #{@AllAbstracts.length}" if LatticeGridHelper.verbose?
  if LatticeGridHelper.verbose? then
    investigator_abstracts_length = @AllAbstracts.collect{|x| x.investigator_abstracts.length }.sum
    puts "count of all investigator_abstracts is #{investigator_abstracts_length}"
  end
end

task :getTags => :environment do
  # load all tags
  @AllTags = Tag.find(:all)
  puts "count of all tags is #{@AllTags.length}" if LatticeGridHelper.verbose?
end

task :getAwards => :environment do
  # load all tags
  @AllAwards = Proposal.all
  puts "count of all tags is #{@AllAwards.length}" if LatticeGridHelper.verbose?
end

task :getInvestigatorColleagues => :environment do
  # load all investigator_colleagues
  @AllInvestigatorColleagues = InvestigatorColleague.find(:all)
  puts "count of all investigator_colleagues is #{@AllInvestigatorColleagues.length}" if LatticeGridHelper.verbose?
end

task :updateOrganizationAbstractInformation => [:getAllOrganizationsWithInvestigators] do
  # load the test data
  block_timing("updateOrganizationAbstractInformation") {
    row_iterator(@AllInvestigatorAssociations) {  |unit_id|
      OrganizationAbstract.delete_all(['organizational_unit_id = :org_id', {:org_id => unit_id}])
      investigators = OrganizationalUnit.find(unit_id).primary_faculty+OrganizationalUnit.find(unit_id).associated_faculty
      puts "count of all investigators for organizational unit #{unit_id} is #{investigators.length}" if LatticeGridHelper.verbose?
      abstracts = Abstract.all_investigator_publications(investigators.collect(&:id)).uniq
      puts "count of all abstracts for organizational unit #{unit_id} is #{abstracts.length}" if LatticeGridHelper.verbose?
      abstracts.each do |abstract|
        UpdateOrganizationAbstract (unit_id,abstract.id)
      end
    }
  }
end

