# LatticeGrid prefs:
# turn on lots of output
@debug = false
# try multiple searches if a search returns too many or too few publications
@smart_filters = true
# print timing and completion information
@verbose = true
# limit searches to include the institutional_limit_search_string
@limit_to_institution = false
# build @institutional_limit_search_string to identify all the publications at your institution 
@institutional_limit_search_string = '( "Northwestern University"[affil] OR "Feinberg School"[affil] OR "Robert H. Lurie Comprehensive Cancer Center"[affil] OR "Northwestern Healthcare"[affil] OR "Children''s Memorial"[affil] OR "Northwestern Memorial"[affil] OR "Northwestern Medical"[affil])'
# these names will always be limited to the institutional search only even if @limit_to_institution is false
@last_names_to_limit = ["Brown","Chen","Das","Khan","Liu","Lu","Lee","Shen","Smith","Wang","Xia","Yang","Zhou"]
# these are for messages regarding the expected number of publications
@expected_min_pubs_per_year = 1
@expected_max_pubs_per_year = 30

# you shouldn't need to change these ...
@all_years = 10
@number_years = 1
@publication_years = @number_years


# these shouldn't be changed...
@AllInvestigators = nil
@AllInvestigatorColleagues = nil
@AllInvestigatorMeshTags = nil
@AllAbstractMeshTags = nil
@AllAbstracts = nil
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
