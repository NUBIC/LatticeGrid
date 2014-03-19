# -*- coding: utf-8 -*-
require 'pubmed_config' # look here to change the default time spans
require 'utilities'

require 'rubygems'

task :setAllYears => :environment do
  @publication_years = LatticeGridHelper.all_years
end

task :get_investigators => :environment do
  # load all investigators
  begin
    @all_investigators = Investigator.includes(['abstracts']).order('id').to_a
  rescue
    @all_investigators = Investigator.order('id').to_a
  end

  # @all_investigators = Investigator.find(:all, :conditions => "id=1")
  puts "count of all investigators is #{@all_investigators.length}" if LatticeGridHelper.verbose?
end

task :getMeshTags => :environment do
  @all_investigator_mesh_tags = Tagging.find(:all, :joins => :tag, :select=> "distinct information_content, tag_id, tags.name", :conditions=>"taggable_type='Investigator'")
  puts "count of all investigator MeSH tags is #{@all_investigator_mesh_tags.length}" if LatticeGridHelper.verbose?
  @all_abstract_mesh_tags = Tagging.find(:all, :joins => :tag, :select=> "distinct information_content, tag_id, tags.name", :conditions=>"taggable_type='Abstract'")
  puts "count of all abstract MeSH tags is #{@all_abstract_mesh_tags.length}" if LatticeGridHelper.verbose?
end

task :getPrimaryAppointments => :environment do
  # load distinct Departments from Investigators
  @all_primary_appointments = Investigator.distinct_primary_appointments

   puts "count of all investigator home appointments is #{@all_primary_appointments.length}" if LatticeGridHelper.verbose?
end

task :getAllOrganizations => :environment do
  # load all organizations that have an investigator
  @all_organizations = OrganizationalUnit.find(:all)

  puts "count of all organizations is #{@all_organizations.length}" if LatticeGridHelper.verbose?
end

task :getAllOrganizationsNotUpdated => :environment do
  # load all organizations that have an investigator
  directly_updated = OrganizationalUnit.all(:conditions=> ['updated_at >= :recently', {:recently => Date.yesterday}]).compact
  parents = directly_updated.collect{|org| org.parent}.compact
  grandparents = parents.collect{|org| org.parent}.compact
  all_organizations_updated = (directly_updated + parents + OrganizationalUnit.roots + grandparents).sort.uniq

  @all_organizationsNotUpdated = OrganizationalUnit.all(:conditions=> ['id NOT IN (:ids)', {:ids => all_organizations_updated.collect(&:id)}] ).compact

  puts "Updated Orgs: #{all_organizations_updated.collect(&:abbreviation).join(", ")}" if LatticeGridHelper.verbose?
  puts "Unupdated Orgs: #{@all_organizationsNotUpdated.collect(&:abbreviation).join(", ")}" if LatticeGridHelper.verbose?
  puts "count of all organizations not updated is #{@all_organizationsNotUpdated.length}" if LatticeGridHelper.verbose?
end

task :getAllOrganizationsWithInvestigators => :environment do
  # load all organizations that have an investigator
  @all_investigator_associations = Investigator.distinct_all_appointments_and_memberships

  puts "count of all organizations with investigators (including primary appointments) is #{@all_investigator_associations.length}" if LatticeGridHelper.verbose?
end

task :getAllMembers => :environment do
  @all_members = Investigator.all_with_membership
  puts "count of all_with_membership is #{@all_members.length}" if LatticeGridHelper.verbose?

  @all_members = Investigator.all_members
  puts "count of all investigator memberships (all_members) is #{@all_members.length}" if LatticeGridHelper.verbose?
end

task :getAllInvestigatorsWithoutMembership => :environment do
  @investigators_without_membership = Investigator.not_members
  puts "count of all investigators without a membership is #{@InvestigatorsWithoutMembership.length}" if LatticeGridHelper.verbose?
end

task :getAbstracts => :environment do
  begin
    if Rails.env != 'production'
      @all_abstracts = Abstract.find(:all, :order => 'id', :include => ["investigator_abstracts","investigators"])
    else
      @all_abstracts = Abstract.find(:all, :order => 'id')
    end
  rescue
    @all_abstracts = Abstract.find(:all, :order => 'id')
  end
  puts "count of all abstracts is #{@all_abstracts.length}" if LatticeGridHelper.verbose?
  if LatticeGridHelper.verbose?
    investigator_abstracts_length = @all_abstracts.map{ |x| x.investigator_abstracts.length }.sum
    puts "count of all investigator_abstracts is #{investigator_abstracts_length}"
  end
end

task :getTags => :environment do
  @all_tags = Tag.find(:all)
  puts "count of all tags is #{@all_tags.length}" if LatticeGridHelper.verbose?
end

task :getAwards => :environment do
  @all_awards = Proposal.all
  puts "count of all tags is #{@all_awards.length}" if LatticeGridHelper.verbose?
end

task :getInvestigatorColleagues => :environment do
  @all_investigator_colleagues = InvestigatorColleague.find(:all)
  puts "count of all investigator_colleagues is #{@all_investigator_colleagues.length}" if LatticeGridHelper.verbose?
end

task :updateOrganizationAbstractInformation => [:getAllOrganizationsWithInvestigators] do
  # load the test data
  block_timing("updateOrganizationAbstractInformation") do
    row_iterator(@all_investigator_associations) do |unit_id|
      OrganizationAbstract.delete_all([ 'organizational_unit_id = :org_id', { :org_id => unit_id } ])
      investigators = OrganizationalUnit.find(unit_id).primary_faculty + OrganizationalUnit.find(unit_id).associated_faculty
      puts "count of all investigators for organizational unit #{unit_id} is #{investigators.length}" if LatticeGridHelper.verbose?
      abstracts = Abstract.all_investigator_publications(investigators.map(&:id)).uniq
      puts "count of all abstracts for organizational unit #{unit_id} is #{abstracts.length}" if LatticeGridHelper.verbose?
      abstracts.each { |abstract| UpdateOrganizationAbstract(unit_id,abstract.id) }
    end
  end
end
