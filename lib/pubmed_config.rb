require 'bio' #require bioruby!
require 'config'
require 'pubmedext'
begin
  Bio::NCBI.default_email = "wakibbe@me.com"
rescue
  puts "using old bioruby"
end

# these shouldn't be changed...
@publication_years = LatticeGridHelper.default_number_years

@AllInvestigators = nil
@AllInvestigatorColleagues = nil
@AllInvestigatorMeshTags = nil
@AllAbstractMeshTags = nil
@AllAbstracts = nil
@AllAwards = nil
@AllPrimaryAppointments = nil
@AllInvestigatorAssociations = nil
@InvestigatorsWithoutMembership = nil
@AllMembers = nil
@AllOrganziations = nil
@AllTags = nil
@all_entries = nil
@all_publications = Array.new
@total_taggings_count=0
@total_publications = 0
@total_tagged_publications = 0
@total_tag_count=0
