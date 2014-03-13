# -*- coding: utf-8 -*-
require 'bio' # require bioruby!
require 'config'
require 'pubmedext'
begin
  Bio::NCBI.default_email = 'wakibbe@me.com'
rescue
  puts 'using old bioruby'
end

# these shouldn't be changed...
@publication_years = LatticeGridHelper.default_number_years

@all_investigators = nil
@all_investigator_colleagues = nil
@all_investigator_mesh_tags = nil
@all_abstract_mesh_tags = nil
@all_abstracts = nil
@all_awards = nil
@all_primary_appointments = nil
@all_investigator_associations = nil
@investigators_without_membership = nil
@all_members = nil
@all_organizations = nil
@all_tags = nil
@all_entries = nil
@all_publications = []
@total_taggings_count = 0
@total_publications = 0
@total_tagged_publications = 0
@total_tag_count = 0
