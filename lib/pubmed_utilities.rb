require 'pubmed_config'

def limit_pubmed_search_to_institution(set_value=nil)
  if set_value.blank? and @local_limit_pubmed_search_to_institution.blank?
     @local_limit_pubmed_search_to_institution = LatticeGridHelper.global_limit_pubmed_search_to_institution?
  elsif ! set_value.blank?
    @local_limit_pubmed_search_to_institution = set_value
  end
  return @local_limit_pubmed_search_to_institution
end

def limit_to_institution(pi)
#  logger.warn "limit_to_institution: limit_pubmed_search_to_institution= #{limit_pubmed_search_to_institution()}; LatticeGridHelper.global_limit_pubmed_search_to_institution?=#{LatticeGridHelper.global_limit_pubmed_search_to_institution?} "
  if pi.pubmed_limit_to_institution || limit_pubmed_search_to_institution() || LatticeGridHelper.last_names_to_limit().include?(pi.last_name) then
    return true 
  end
  false
end

def build_pi_search_string(pi, full_first_name=true)
  return "" if pi.blank? or pi.last_name.blank?
  return pi.pubmed_search_name if !pi.pubmed_search_name.blank?
  result = pi.last_name
  if full_first_name then
    result = result + ", " + pi.first_name
    if !pi.middle_name.blank?  then
      result = result + " " + pi.middle_name[0,1]
    end
  else
    result = result + " " + pi.first_name[0,1]
    if !pi.middle_name.blank?  then
      result = result + pi.middle_name[0,1]
    end
  end
  result
end

def build_auto_pi_search_string(pi, full_first_name=true)
  return "" if pi.blank? or pi.last_name.blank?
  result = pi.last_name
  if full_first_name then
    result = result + ", " + pi.first_name
    if !pi.middle_name.blank?  then
      result = result + " " + pi.middle_name[0,1]
    end
  else
    result = result + " " + pi.first_name[0,1]
    if !pi.middle_name.blank?  then
      result = result + pi.middle_name[0,1]
    end
  end
  result
end

def BuildPISearch(pi, full_first_name=true)
  result = build_pi_search_string(pi, full_first_name)
  result = result + '[auth]' unless result =~ /\[auth|\(/
  if limit_to_institution(pi) then
    result = LimitSearchToInstitution(result, pi)
  end
  result= LimitSearchToMeSHterms(result)
  result
end

def LimitSearchToMeSHterms(phrase_to_limit)
  if LatticeGridHelper.limit_to_MeSH_terms? and not LatticeGridHelper.MeSH_terms_array.blank?
    terms = LatticeGridHelper.MeSH_terms_array.map{|a| "(#{a})"}.join(" OR ")
    return "(#{phrase_to_limit}) AND (#{terms})"
  end
  return phrase_to_limit
end

def LimitSearchToInstitution(term, pi)
  # temporarily reverse logic limit by institution
  # term + " NOT " + LatticeGridHelper.institutional_limit_search_string()
  if LatticeGridHelper.build_institution_search_string_from_department?
    "(" + term + ") AND (" + BuildAffiliationLimitString(pi) +")"
  else
    "(" + term + ") AND (" + LatticeGridHelper.institutional_limit_search_string() + ")"
  end
end

def BuildSearchOptions (number_years, max_num_records=500)
  {
   #   'mindate' => '2003/05/31',
   #   'maxdate' => '2003/05/31',
     'reldate' => (365*number_years).to_i,
     'retmax' => max_num_records,
  }
end

def BuildAffiliationLimitString(pi)
  str = pi.home_department_name
  unless pi.home_department.blank? or pi.home_department.pubmed_search_name.blank?
    str = pi.home_department.pubmed_search_name
  end
  return "" if str.blank?
  if str =~ /[\(\)]/
    return str
  end
  str_arr = str.split(" ")
  out_arr = []
  str_arr.each do |txt|
    next if txt.length < 4
    out_arr << txt+"[affil]"
  end
  out_arr << str+"[affil]" if out_arr.blank?
  out_arr.join(" AND ")
end


def FindPubMedIDs (all_investigators, options, number_years, debug=false, smart_filters=false)
  theCnt = 0
  all_investigators.each do |investigator|
    #reset counters
    attempt=0
    repeatCnt=0
    entries = nil
    perform_esearch=true
    keywords = BuildPISearch(investigator, LatticeGridHelper.global_pubmed_search_full_first_name?() )
    investigator["mark_pubs_as_valid"]= limit_to_institution(investigator) 
    while perform_esearch && repeatCnt < 3 && attempt < 4
      begin
         #puts "esearch keywords = #{keywords}; repeatCnt=#{repeatCnt}"
        entries = Bio::PubMed.esearch(keywords, options)
        #puts "esearch results: #{entries.length} pubs for investigator #{investigator.first_name} #{investigator.last_name} using the keywords #{keywords} were found"
        if entries.length < 1 && smart_filters && ! LatticeGridHelper.global_pubmed_search_full_first_name?() then
          keywords = BuildPISearch(investigator,false)
        elsif entries.length > (LatticeGridHelper.expected_max_pubs_per_year*number_years) && smart_filters && repeatCnt < 3 && ! limit_pubmed_search_to_institution() then
          keywords = LimitSearchToInstitution(keywords, investigator)
        else
          if LatticeGridHelper.mark_full_name_searches_as_valid? and repeatCnt == 0
            investigator["mark_pubs_as_valid"]=true
          end
          perform_esearch=false
        end
       rescue Timeout::Error => exc
         if attempt < 4 then 
           puts "esearch Failed call with keywords: " + keywords.to_s + "; options: " + options.to_s + "; for investigator #{investigator.first_name} #{investigator.last_name}"
           puts "exception = #{exc.message}"
           puts "trying again!"
           retry
         end
         raise "Failed call with keywords: " + keywords.to_s + "; options: " + options.to_s + "; for investigator #{investigator.first_name} #{investigator.last_name}"
       rescue Exception => error
        attempt+=1
        puts "Failed call with keywords: " + keywords.to_s + "; options: " + options.to_s + "; for investigator #{investigator.first_name} #{investigator.last_name}"
        retry if attempt < 3
        raise
      end
      repeatCnt +=1
    end 
    # leaving perform_esearch
    investigator["entries"] = entries
    if entries.length < 1 then
      puts "No publications found for investigator #{investigator.first_name} #{investigator.last_name} using the keywords #{keywords}" if debug
    elsif entries.length > (LatticeGridHelper.expected_max_pubs_per_year*number_years) then
      puts "Too many hits??: #{entries.length} pubs for investigator #{investigator.first_name} #{investigator.last_name} using the keywords #{keywords} were found. RepeatCnt=#{repeatCnt}"
    elsif entries.length < number_years then
      puts "Too few found: #{entries.length} pubs for investigator #{investigator.first_name} #{investigator.last_name} using the keywords #{keywords} were found" if debug
      investigator["entries"] = entries
    else
      puts "#{entries.length} pubs for investigator #{investigator.first_name} #{investigator.last_name} using the keywords #{keywords} were found" if debug
      investigator["entries"] = entries
    end
    #reset these if we make it this far

    #puts "Done with investigator #{investigator.first_name} #{investigator.last_name}"
    theCnt=theCnt+entries.length
  end
  theCnt
end


def GetPubsForInvestigators(investigators)
  investigators.each do |investigator|
    if investigator.entries.length > 0
      fetchcnt=0
      begin
        puts "looking up #{investigator.entries.length} pubs for investigator #{investigator.first_name} #{investigator.last_name}" if LatticeGridHelper.debug?
        pubs = Bio::PubMed.efetch(investigator.entries)
        raise "error fetching publications array from efetch. investigator.entries = #{investigator.entries.inspect}" if pubs.nil?
        investigator["publications"] = pubs
      rescue Timeout::Error => exc
        if fetchcnt < 4 then 
          puts "efetch timeout looking up #{investigator.entries.length} pubs for investigator #{investigator.first_name} #{investigator.last_name}"
          puts "exception = #{exc.message}"
          puts "trying again!"
          fetchcnt+=1
          retry
        end
        raise "efetch timeout looking up #{investigator.entries.length} pubs for investigator #{investigator.first_name} #{investigator.last_name}"
      rescue  Exception => exc 
        if fetchcnt < 4 then 
          puts "Error looking up #{investigator.entries.length} pubs for investigator #{investigator.first_name} #{investigator.last_name}"
          puts "exception = #{exc.message}"
          puts "trying again!"
          fetchcnt+=1
          retry
        end
        raise "efetch timeout looking up #{investigator.entries.length} pubs for investigator #{investigator.first_name} #{investigator.last_name}"
      end
    else
      puts "no publications found for investigator #{investigator.first_name} #{investigator.last_name}" if LatticeGridHelper.debug?
      investigator["publications"] = nil
    end
  end
  return investigators
end

def InsertInvestigatorPublication(abstract_id, investigator_id, publication_date, is_first_author=false, is_last_author=false, is_valid=false)
  puts "InsertInvestigatorPublication: this shouldn't happen - abstract_id was nil" if abstract_id.nil?
  return if abstract_id.nil?
  puts "InsertInvestigatorPublication: this shouldn't happen - investigator_id was nil" if investigator_id.nil?
  return if investigator_id.nil?
  thePIPub = InvestigatorAbstract.find(:first, 
           :conditions => ["abstract_id = :abstract_id and investigator_id = :investigator_id", {:abstract_id => abstract_id, :investigator_id => investigator_id} ] )
  if thePIPub.nil? then
    begin 
       thePIPub = InvestigatorAbstract.create!(
         :abstract_id     => abstract_id,
         :investigator_id => investigator_id,
         :is_first_author => is_first_author,
         :is_last_author  => is_last_author,
         :is_valid        => is_valid,
         :reviewed_ip     => "inserted from pubmed",
         :publication_date => publication_date
       )
      rescue ActiveRecord::RecordInvalid
       if thePIPub.nil? then # something bad happened
         puts "InsertInvestigatorPublication: unable to either insert or find a reference with the abstract_id '#{abstract_id}' and the investigator_id '#{investigator_id}'"
         return nil
       end
     end 
   end
   thePIPub
end

def UpdateCitationInvestigatorInformation(abstract_id, investigator_ids, first_author_id, last_author_id, is_valid=nil)
  puts "UpdateCitationInvestigatorInformation: this shouldn't happen - abstract_id was nil" if abstract_id.nil?
  return if abstract_id.nil?
  puts "UpdateCitationInvestigatorInformation: this shouldn't happen - investigator_ids was nil" if investigator_ids.nil?
  return if investigator_ids.nil?
  investigator_ids.each do |investigator_id|
    UpdateInvestigatorPublication(abstract_id, investigator_id, !!(first_author_id == investigator_id),  !!(last_author_id == investigator_id), is_valid)
   end
end

def UpdateInvestigatorCitationInformation(investigator)
  investigator.num_intraunit_collaborators_last_five_years=Investigator.intramural_collaborators_since_date_cnt(investigator.id)
  investigator.num_extraunit_collaborators_last_five_years=Investigator.other_collaborators_since_date_cnt(investigator.id)
  investigator.total_publications_last_five_years=investigator.abstract_last_five_years_count()
  investigator.num_first_pubs_last_five_years=investigator.first_author_publications_since_date_cnt()
  investigator.num_last_pubs_last_five_years=investigator.last_author_publications_since_date_cnt()
  investigator.num_intraunit_collaborators=Investigator.intramural_collaborators_cnt(investigator.id)
  investigator.num_extraunit_collaborators=Investigator.other_collaborators_cnt(investigator.id)
  investigator.total_publications=investigator.abstracts.length
  investigator.num_first_pubs=investigator.first_author_publications_cnt()
  investigator.num_last_pubs=investigator.last_author_publications_cnt()
  investigator.home_department_name=investigator.home_department.name if !investigator.home_department.blank?

  investigator.total_studies = investigator.investigator_studies.length
  collabs = investigator.investigator_studies.map{|inv| inv.study.investigators.map(&:id)}.flatten.uniq
  investigator.total_studies_collaborators = collabs.length - 1
   
  investigator.total_pi_studies = investigator.investigator_pi_studies.length
  collabs = investigator.investigator_pi_studies.map{|inv| inv.study.investigators.map(&:id)}.flatten.uniq
  investigator.total_pi_studies_collaborators = collabs.length - 1
  
  investigator.total_awards = investigator.investigator_proposals.length
  collabs = investigator.investigator_proposals.map{|inv| inv.proposal.investigators.map(&:id)}.flatten.uniq
  investigator.total_awards_collaborators = collabs.length - 1
   
  investigator.total_pi_awards = investigator.investigator_pi_proposals.length
  collabs = investigator.investigator_pi_proposals.map{|inv| inv.proposal.investigators.map(&:id)}.flatten.uniq
  investigator.total_pi_awards_collaborators = collabs.length - 1
  investigator.save!
end

def UpdateInvestigatorPublication(abstract_id, investigator_id, is_first_author, is_last_author, is_valid=nil )
  puts "UpdateInvestigatorPublication: this shouldn't happen - abstract_id was nil" if abstract_id.nil?
  return if abstract_id.nil?
  puts "UpdateInvestigatorPublication: this shouldn't happen - investigator_id was nil" if investigator_id.nil?
  return if investigator_id.nil?
  thePIPub = InvestigatorAbstract.find(:first, 
           :conditions => ["abstract_id = :abstract_id and investigator_id = :investigator_id", {:abstract_id => abstract_id, :investigator_id => investigator_id} ] )
  if thePIPub.nil? then
    puts "UpdateInvestigatorPublication: this shouldn't happen - didn't find an InvestigatorAbstract"
    return
  else
    begin 
       thePIPub.is_first_author = is_first_author
       thePIPub.is_last_author = is_last_author
       thePIPub.is_valid = is_valid if ! is_valid.nil?
       thePIPub.save!
    rescue ActiveRecord::RecordInvalid
       puts "UpdateInvestigatorPublication: unable to update an InvestigatorAbstract with the abstract_id '#{abstract_id}' and the investigator_id '#{investigator_id}'"
       return 
     end
   end
   thePIPub.id
end

def SubtractKnownPubmedIDs(pubmed_ids)
  novel_pubmed_ids=[]
  start_slice = 0
  slice_size = 500
  while start_slice < pubmed_ids.length
    the_ids = pubmed_ids.slice(start_slice,slice_size)
    start_slice+=slice_size
    found_abs = Abstract.find_all_by_pubmed_include_deleted(the_ids)
    next if found_abs.length < 1
    found_ids = found_abs.map(&:pubmed)
    novel_ids = the_ids - found_ids
    novel_pubmed_ids += novel_ids unless novel_ids.blank?
  end
  return novel_pubmed_ids
end 

# fetch pubmed record data based on array of pubmed_ids
def FetchPublicationData(pubmed_ids)
  theCnt = 0
  theSize = 499
  theEnd = 0
  foundPubs=[]
  while theCnt < pubmed_ids.length do
    theEnd = theCnt+theSize
    theEnd = pubmed_ids.length-1 if theEnd > pubmed_ids.length-1 
    puts "Slicing all_entries from #{theCnt} to #{theEnd}" if LatticeGridHelper.debug?
    mySlice = pubmed_ids[theCnt..theEnd]
    puts "looking up #{mySlice.length} pubs from #{theCnt} to #{theEnd}" if LatticeGridHelper.debug?
    theCnt = theEnd+1
    printSlice(mySlice) if LatticeGridHelper.debug?
    pubs = Bio::PubMed.efetch(mySlice)
    inspectObject(pubs[0]) if LatticeGridHelper.debug?
    puts "found #{pubs.length} pubs" if LatticeGridHelper.debug?
    foundPubs =  foundPubs + pubs
  end
  foundPubs
end

# put in the investigatorColleague entries for an investigator
def BuildCoauthors(investigator)
  coauthor_ids = investigator.abstracts.collect{|x| x.investigator_abstracts.collect(&:investigator_id)}.flatten.uniq
  coauthor_ids.delete(investigator.id)
  coauthor_ids.each do |coauthor_id|
    colleague=Investigator.include_deleted(coauthor_id)
    next if !colleague.deleted_at.nil?
    citation_overlap = investigator.abstracts.collect{|x| x.id}.flatten & colleague.abstracts.collect{|x| x.id}.flatten
    citation_overlap = citation_overlap.uniq.compact
    InsertUpdateInvestigatorColleague(investigator.id,coauthor_id,citation_overlap)
    InsertUpdateInvestigatorColleague(coauthor_id,investigator.id,citation_overlap)
  end
end
