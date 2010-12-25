# -*- ruby -*-
require 'pubmed_config'


def BuildPISearch(pi, full_first_name=true, limit_to_institution=true)
  result = ""
  if !pi.pubmed_search_name.blank?  then
    result = pi.pubmed_search_name
  else 
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
  end
  result = result + '[auth]' unless result =~ /\[auth|\(/
  if pi.pubmed_limit_to_institution || limit_to_institution || @last_names_to_limit.include?(pi.last_name) then
    result = LimitSearchToInstitution(result)
  end
  result
end

def InstitutionalSearchTerms
  return @institutional_limit_search_string
end

def LimitSearchToInstitution(term)
  # temporarily reverse logic limit by institution
  # term + " NOT " + InstitutionalSearchTerms()
  "(" + term + ") AND (" + InstitutionalSearchTerms() + ")"
end

def BuildSearchOptions (number_years, max_num_records=500)
  {
   #   'mindate' => '2003/05/31',
   #   'maxdate' => '2003/05/31',
     'reldate' => (365*number_years).to_i,
     'retmax' => max_num_records,
  }
end


def FindPubMedIDs (all_investigators, options, number_years, limit_to_institution=true, debug=false, smart_filters=false)
  theCnt = 0
  expected_max_pubs_per_year = @expected_max_pubs_per_year
  expected_min_pubs_per_year = @expected_min_pubs_per_year
  all_investigators.each do |investigator|
    #reset counters
    attempt=0
    repeatCnt=0
    entries = nil
    perform_esearch=true
    keywords = BuildPISearch(investigator, true, limit_to_institution)
    while perform_esearch && repeatCnt < 3 && attempt < 4
      begin
         #puts "esearch keywords = #{keywords}; repeatCnt=#{repeatCnt}"
        entries = Bio::PubMed.esearch(keywords, options)
        #puts "esearch results: #{entries.length} pubs for investigator #{investigator.first_name} #{investigator.last_name} using the keywords #{keywords} were found"
        if entries.length < 1 && smart_filters then
          keywords = BuildPISearch(investigator,false, limit_to_institution)
        elsif entries.length > (expected_max_pubs_per_year*number_years) && smart_filters && repeatCnt < 3 && !limit_to_institution then
          keywords = LimitSearchToInstitution(keywords)
        else
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
    elsif entries.length > (expected_max_pubs_per_year*number_years) then
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
        puts "looking up #{investigator.entries.length} pubs for investigator #{investigator.first_name} #{investigator.last_name}" if @debug
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
      puts "no publications found for investigator #{investigator.first_name} #{investigator.last_name}" if @debug
      investigator["publications"] = nil
    end
  end
  return investigators
end


def InsertInvestigatorPublication(abstract_id, investigator_id, is_first_author=false, is_last_author=false)
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
         :is_last_author  => is_last_author
       )
      rescue ActiveRecord::RecordInvalid
       if thePIPub.nil? then # something bad happened
         puts "InsertInvestigatorPublication: unable to either insert or find a reference with the abstract_id '#{abstract_id}' and the investigator_id '#{investigator_id}'"
         return 
       end
     end 
   end
   thePIPub.id
end

def UpdateCitationInvestigatorInformation(abstract_id, investigator_ids, first_author_id, last_author_id)
  puts "UpdateCitationInvestigatorInformation: this shouldn't happen - abstract_id was nil" if abstract_id.nil?
  return if abstract_id.nil?
  puts "UpdateCitationInvestigatorInformation: this shouldn't happen - investigator_ids was nil" if investigator_ids.nil?
  return if investigator_ids.nil?
  investigator_ids.each do |investigator_id|
    UpdateInvestigatorPublication(abstract_id, investigator_id, !!(first_author_id == investigator_id),  !!(last_author_id == investigator_id))
   end
end

def UpdateInvestigatorCitationInformation(investigator)
  investigator.num_intraunit_collaborators_last_five_years=Investigator.intramural_collaborators_since_date_cnt(investigator.id)
  investigator.num_extraunit_collaborators_last_five_years=Investigator.other_collaborators_since_date_cnt(investigator.id)
  investigator.total_pubs_last_five_years=investigator.abstract_last_five_years_count()
  investigator.num_first_pubs_last_five_years=investigator.first_author_publications_since_date_cnt()
  investigator.num_last_pubs_last_five_years=investigator.last_author_publications_since_date_cnt()
  investigator.num_intraunit_collaborators=Investigator.intramural_collaborators_cnt(investigator.id)
  investigator.num_extraunit_collaborators=Investigator.other_collaborators_cnt(investigator.id)
  investigator.total_pubs=investigator.abstracts.length
  investigator.num_first_pubs=investigator.first_author_publications_cnt()
  investigator.num_last_pubs=investigator.last_author_publications_cnt()
  investigator.save!
end

def UpdateInvestigatorPublication(abstract_id, investigator_id, is_first_author, is_last_author)
  puts "UpdateInvestigatorPublication: this shouldn't happen - abstract_id was nil" if abstract_id.nil?
  return if abstract_id.nil?
  puts "InsertInvestigatorPublication: this shouldn't happen - investigator_id was nil" if investigator_id.nil?
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
       thePIPub.save!
    rescue ActiveRecord::RecordInvalid
       puts "UpdateInvestigatorPublication: unable to update an InvestigatorAbstract with the abstract_id '#{abstract_id}' and the investigator_id '#{investigator_id}'"
       return 
     end
   end
   thePIPub.id
end

def UpdateInvestigatorRecords(abstract_id, investigator_id, is_first_author, is_last_author)
  puts "UpdateInvestigatorPublication: this shouldn't happen - abstract_id was nil" if abstract_id.nil?
  return if abstract_id.nil?
  puts "InsertInvestigatorPublication: this shouldn't happen - investigator_id was nil" if investigator_id.nil?
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
       thePIPub.save!
    rescue ActiveRecord::RecordInvalid
       puts "UpdateInvestigatorPublication: unable to update an InvestigatorAbstract with the abstract_id '#{abstract_id}' and the investigator_id '#{investigator_id}'"
       return 
     end
   end
   thePIPub.id
end


def AddInvestigatorsToCitation(abstract_id, investigator_ids, first_author_id, last_author_id)
  puts "AddInvestigatorToCitation: this shouldn't happen - abstract_id was nil" if abstract_id.nil?
  return if abstract_id.nil?
  puts "AddInvestigatorToCitation: this shouldn't happen - investigator_ids was nil" if investigator_ids.nil?
  return if investigator_ids.blank?
  return if investigator_ids.length < 1
  investigator_ids.each do |investigator_id|
    if InvestigatorAbstract.find( :first,
      :conditions => [" abstract_id = :abstract_id AND investigator_id = :investigator_id",
          {:investigator_id => investigator_id, :abstract_id => abstract_id}])
      # puts "found investigator/abstract pair"
      if (last_author_id > 0 || first_author_id > 0) then 
        UpdateInvestigatorRecords(abstract_id, investigator_id, !!(first_author_id == investigator_id),  !!(last_author_id == investigator_id))
      end
    else
      puts "adding new investigator/abstract pair (investigator: #{Investigator.find(investigator_id).last_name}; abstract pubmed_id: #{Abstract.find(abstract_id).pubmed})" if @verbose
      InsertInvestigatorPublication(abstract_id, investigator_id, !!(first_author_id == investigator_id),  !!(last_author_id == investigator_id))
    end
  end
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
    puts "Slicing all_entries from #{theCnt} to #{theEnd}" if @debug
    mySlice = pubmed_ids[theCnt..theEnd]
    puts "looking up #{mySlice.length} pubs from #{theCnt} to #{theEnd}" if @debug
    theCnt = theEnd+1
    printSlice(mySlice) if @debug
    pubs = Bio::PubMed.efetch(mySlice)
    inspectObject(pubs[0]) if @debug
    puts "found #{pubs.length} pubs" if @debug
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
