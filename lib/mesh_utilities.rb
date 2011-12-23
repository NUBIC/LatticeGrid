# -*- ruby -*-

# added downcase to make sure all terms are atomic and not multi-cased!
def RearrangeTermsWithCommas(term)
  a = term.split(",").collect{|x| x.strip}
  if a.length > 1 then
    d = a[1]+" "+a[0]
    a.shift
    a[0]=d
  end
  return a.join("-").sub(/(.*)( as Topic)(.*)/i,'\1\3\2').strip.downcase
end
  
def CleanMeshTerm(mesh_term)
  # mesh terms appear to be composite - term root plus one or more categories. For now strip off everything after root
  return [] if mesh_term !~ /\*/ or mesh_term.blank? or mesh_term.length < 3
  mesh_term = mesh_term.gsub(/\(|\)|\#|\!|\&|\./,'')
  return [] if mesh_term.blank? or mesh_term.length < 3
  
  mesh_array = mesh_term.downcase.split(/\//).collect{ |a| a.gsub(/\*/,'')}
  mesh_array.delete("humans")
  mesh_array.delete("animals")
  mesh_array.delete("metabolism")
  mesh_array = mesh_array.collect{|term| (term.blank? or term.length < 3 or mesh_term.length > 80) ? nil : term}
  #mesh_array.compact
  return mesh_array.collect{ |term| RearrangeTermsWithCommas(term)}
end

def CleanMeshTerms(mesh_array)
  # mesh terms appear to be composite - term root plus one or more categories. For now strip off everything after root
  mesh_array.collect{ |mesh_term| CleanMeshTerm(mesh_term)}.flatten.uniq
end

def AddMeshTermstoObject(obj, mesh_array)
  obj.tag_list = obj.tag_list | mesh_array
  obj.save
end

def TagAbstractWithMeSH(abstract)
  return if abstract.blank?
  AddMeshTermstoObject(abstract,CleanMeshTerms(abstract.mesh.split(";\n"))) if !abstract.mesh.blank? #don't add the blank ones
end

def LimitedTagInvestigatorWithMeSH(investigator) # not using this one anymore
  invpubs = (investigator.investigator_abstracts.first_author_publications + investigator.investigator_abstracts.last_author_publications).uniq
  if (invpubs.length > 7)
    AddMeshTermstoObject(investigator,Abstract.by_ids(invpubs.collect(&:abstract_id)).collect(&:tag_list).flatten.uniq)
  else
    AddMeshTermstoObject(investigator,investigator.abstracts.collect(&:tag_list).flatten.uniq)
  end
end

def TagInvestigatorWithMeSH(investigator)
  AddMeshTermstoObject(investigator,investigator.abstracts.collect(&:tag_list).flatten.uniq)
end

def TagInvestigatorWithKeywords(investigator)
  if ! investigator.faculty_keywords.blank?
    AddMeshTermstoObject(investigator,investigator.faculty_keywords.split(",").collect{|kw| kw.strip.downcase })
  end
  if ! investigator.faculty_interests.blank?
    AddMeshTermstoObject(investigator,investigator.faculty_interests.split(",").collect{|kw| kw.strip.downcase })
  end
end

def GetTag(name)
   Tag.find_by_name(name)
end

def GetTagInformationContent(tag, tag_type)
  Tagging.find(:first,:joins=>[:tag], :conditions => [" taggable_type = :type AND tags.name = :tag",
     {:type => tag_type, :tag => tag}]).information_content
end


def SetTaggings(tag_id,taggable_type, information_content)
  Tagging.update_all( {:information_content => information_content}, {:tag_id => tag_id, :taggable_type => taggable_type})
end


def SetMeshInformationContent(tag_count, total_count, taggable_type)
  # lets assume that the information content follows a normal distribution, with most tags having little information. Need to normalize to 100
  # Math.log10(@total_tagged_publications) is the largest possible number. For the cancer center the number is about 8000 pubs with MeSH tags
  # 500*(1-tagged_count/total_count)
  tag_id=tag_count.id
  tagged_count=tag_count.count
  information_content = 0
  # total count / (tagged count +9) - max is 1/10th total count
  # to get to 100, (500/total_count) * total_count/ (tagged_count +4)
  # for cancer center, out 6000 MeSH terms 2500 are unique, 1000 have 2, 500 have 3, 400 have 4, 250 have 5, 200 have 6, 150 have 7, 100 have 8, 100 have 9, 
  # for FSM, out of 9318 MeSH terms, 3024 are unique, 1500 have 2, 900 have 3, 600 have 4, 440 have 5, 350 have 6, 260 have 7, 220 have 8, 190 have 9, 
  #    145 have 10, 155 have 11, 140 have 12, 115 have 13, 102 have 14, 75 have 15, and the last 1100 have more
  if tagged_count > 0
    information_content = (2500.0/ (tagged_count + 4)).round
    #information_content = (500.0 * (1.0 - tagged_count.to_f/total_count)).round
  end
  SetTaggings(tag_id,taggable_type,information_content)
end

def GetSumTaggedInformationContent(mesh_tag_ids, tag_type, single_id)
  Tagging.find(:all, :conditions => [" taggable_type = :tag_type AND tag_id IN (:tag_ids) AND taggable_id = :taggable_id", {:tag_type => tag_type, :taggable_id => single_id, :tag_ids => mesh_tag_ids}]).collect(&:information_content).sum
end


def GetSumTagInformationContent(mesh_tag_ids, tag_type, abstract_ids)
  Tagging.find(:all, :conditions => [" taggable_type = :tag_type AND tag_id IN (:tag_ids) AND taggable_id IN (:taggable_ids)", {:tag_type => tag_type, :taggable_ids => abstract_ids, :tag_ids => mesh_tag_ids}]).collect(&:information_content).sum
end

def CalculateMeSHinformationContent(investigator,colleague, mesh_tag_ids, citation_overlap)
  # these two methods are similar except the tag_list calls the database
  # for all FSM takes about 4 minutes per 10 investigators

  if mesh_tag_ids.length < 4
    return 0
  end
  abstract_ids1 = investigator.abstracts.collect(&:id)
  abstract_ids2 = colleague.abstracts.collect(&:id)
  if abstract_ids1.length < 3 or abstract_ids2.length < 3
    return 0
  end

  # let us assume that Abstract.tag.information_content is a log normalized 0-100 value based on the total 
  # number of articles indexed/number with this tag. That is, if every publication had a given tag, its information
  # content would be zero. For a compendium of 10,000 tagged articles, if a tag was found in 5000 it would have a 
  # score of 7.5. If  1000 were tagged, it would be 25. If 100 were tagged it would have a score of 50. If 10 were tagged 
  # it would have a score of 75. If only one was tagged, it would have a score of 100
  # this may overly penalize rare MeSH terms and over-represent middle-ranked MeSH terms. 
  
  # Now for a given comparison, we intersect the tag clouds for the investigators:
  #this is already unique
  
  #(ic1*ic1+ic2*ic2)/(ic_pi+abstract_ids1.length+abstract_ids2.length+mesh_tag_ids.length)
  
  
  # Now sum up the number of each tags for each investigator

  ic1 = GetSumTagInformationContent(mesh_tag_ids, "Abstract", abstract_ids1)
  ic2 = GetSumTagInformationContent(mesh_tag_ids, "Abstract", abstract_ids2)
  ic_overlap = GetSumTagInformationContent(mesh_tag_ids, "Abstract", citation_overlap) 
  ic_pi = GetSumTaggedInformationContent(mesh_tag_ids, "Investigator", investigator.id)
  
  #simplify as 
  # ic1+ic2+(2*ic_pi)
  # ((ic1+ic2+(2*ic_pi))/[abstract_ids1.length,abstract_ids2.length].min).round
  # distribution of meshtags averages around 7. 
  ((ic1+ic2+ic_overlap+(2*ic_pi))*10/(5+mesh_tag_ids.length)).round  

end

def CalculateMeSHinformationContent_old(mesh_array)
  # takes about 4 minutes per 10 investigators for all FSM
  ic=0
  mesh_array.each do |tag|
    mesh_abstract_ic=@AllAbstractMeshTags.find{|x| x.name == tag}.information_content
    mesh_investigator_ic=@AllInvestigatorMeshTags.find{|x| x.name == tag}.information_content
    ic+=mesh_abstract_ic
    ic+=mesh_investigator_ic
  end
  ic
end

def CalculateMeSHinformationContent_older(mesh_array)
  # takes about 6 minutes per 10 investigators for all FSM
  ic=0
  mesh_array.each do |tag|
    mesh_abstract_ic=GetTagInformationContent(tag, 'Abstract')
    mesh_investigator_ic=GetTagInformationContent(tag, 'Investigator')
    ic+=mesh_abstract_ic
    ic+=mesh_investigator_ic
  end
  ic
end

def InvestigatorColleagueInclusionCriteria(citation_overlap,mesh_information_content)
  if (citation_overlap != [] )
    # always include if they copublish
    return true
  end
#  if  (mesh_overlap.length != [] && !mesh_overlap.last.blank?) then
    # looking across 2100 fsm members, there are more than 300,000 mesh_information_content 'hits' with no publication overlap
    # at an ic > 200 there are still 150,000 entries, and at 500 there are 100,000 entries. At 1000 there are 66,000 entries
    # so for an ic > 500 there are still 50 entries per person on average. The number is slightly higher, as only 1500 of the 2100
    # fsm members have publications in PubMed
    
    # for the latest log based information content analysis for RHLCCC, there are 77373 full entries for 280 members of these, all had at least an ic of 50. 73102 had an ic of 500
    # 68000 had a ic of >1000
    # 60300 had an ic of >2000
    # 42000 had an ic of >5000
    # 24000 had an ic of >10000
    # 8500 had an ic of >20000
    # 720 had an ic > 50000
    # 40 had an ic > 100000
    
    # latest score is a bit different. 10,000 is very high score
    #110 had an ic > 20,000
    #320 had an ic > 10,000
    
    
    # for now cut at 10000
  if (mesh_information_content > 150) then
    return true
  end
  return false
end

def AnalyzeInvestigatorColleague(investigator, update_only=true)
  
  # this is the call that converts the problem from an N squared to a linear problem!
  tag_ids = investigator.tags.collect(&:id)
  return if tag_ids.blank?
  ic_tags = Investigator.information_cloud(tag_ids, :limit=>500)
  ic_tags.each do |ic_tag|
    next if ic_tag.taggable_id.to_i <= investigator.id.to_i
    return if ic_tag.total.to_i < 250
    colleague = Investigator.include_deleted(ic_tag.taggable_id)
    next if colleague.nil?
    BuildInvestigatorColleague(investigator, colleague, update_only) if colleague.deleted_at.nil?
  end
end


def BuildInvestigatorColleague(investigator, colleague, update_only=true)
  return if investigator.id == colleague.id
  if update_only && !InvestigatorColleague.find( :first,
    :conditions => [" investigator_id = :investigator_id AND colleague_id = :colleague_id",
        {:investigator_id => investigator.id, :colleague_id => colleague.id}]).nil?
    return
  end
  
  
  #pi = Investigator.find(174)
  #tag_ids = pi.tags.collect(&:id)
  #Investigator.information_cloud(tag_ids, :limit=>30).collect(&:taggable_id)
  #Investigator.information_cloud(tag_ids, :limit=>30).collect(&:total)
  #Investigator.information_cloud(tag_ids, :limit=>30).collect(&:count)

  citation_overlap = investigator.abstracts.collect{|x| x.id}.flatten & colleague.abstracts.collect{|x| x.id}.flatten
  citation_overlap = citation_overlap.uniq.compact
  mesh_tag_ids = investigator.abstracts.collect{|x| x.tags.collect(&:id)}.flatten & colleague.abstracts.collect{|x| x.tags.collect(&:id)}.flatten
  
  mesh_information_content=CalculateMeSHinformationContent(investigator, colleague, mesh_tag_ids, citation_overlap)

  if InvestigatorColleagueInclusionCriteria(citation_overlap,mesh_information_content) then
    InsertUpdateInvestigatorColleague(investigator.id,colleague.id,citation_overlap,mesh_tag_ids,mesh_information_content)
    #repeat as inverse
    InsertUpdateInvestigatorColleague(colleague.id,investigator.id,citation_overlap,mesh_tag_ids,mesh_information_content) 
    #puts "Found relationship: #{investigator.name} and #{colleague.name}: citations: #{citation_overlap.join(', ')}; mesh_ic: #{mesh_information_content} " if LatticeGridHelper.verbose? && citation_overlap.length > 0 
  end
end

def InsertUpdateInvestigatorColleague(investigator_id,colleague_id,citation_overlap,mesh_overlap=nil,mesh_information_content=nil )
  return if investigator_id == colleague_id
  ir = InvestigatorColleague.find( :first,
    :conditions => [" investigator_id = :investigator_id AND colleague_id = :colleague_id",
        {:investigator_id => investigator_id, :colleague_id => colleague_id}])
    if ir.nil?
      InsertInvestigatorColleague(investigator_id,colleague_id,citation_overlap,mesh_overlap,mesh_information_content )
    else
      UpdateInvestigatorColleague(ir,citation_overlap,mesh_overlap,mesh_information_content )
    end
end

def UpdateInvestigatorColleague(ir,citation_overlap,mesh_overlap=nil,mesh_information_content=nil )
  begin 
    ir.mesh_tags_cnt = mesh_overlap.length if !mesh_overlap.nil?
    ir.mesh_tags_ic = mesh_information_content if ! mesh_information_content.nil?
    ir.publication_cnt = citation_overlap.length
    ir.publication_list = citation_overlap.join(',')
    ir.save!
  rescue ActiveRecord::RecordInvalid
    if ir.nil? then # something bad happened
      puts "UpdateInvestigatorColleague: unable to find a reference "
      return 
    end
  end
end

def InsertInvestigatorColleague(investigator_id,colleague_id,citation_overlap,mesh_overlap=nil,mesh_information_content=nil )
  begin 
    mesh_information_content = 0.0 if mesh_information_content.nil? 
    mesh_overlap = [] if mesh_overlap.nil? 
    ir = InvestigatorColleague.create!(
       :investigator_id => investigator_id,
       :colleague_id  => colleague_id,
       :mesh_tags_cnt => mesh_overlap.length,
       :mesh_tags_ic => mesh_information_content,
       :publication_cnt => citation_overlap.length,
       :publication_list => citation_overlap.join(',')
     )
  rescue ActiveRecord::RecordInvalid
    if ir.nil? then # something bad happened
       puts "InsertInvestigatorColleague: unable to either insert a reference with the investigator_id '#{investigator_id}' and the colleague_id '#{colleague_id}'"
       return 
    end
  end
end

def find_cutoff(initial_number, ideal_number, cutoff_start)
  mesh_cutoff = cutoff_start
  #do we need to adjust up or down
  if initial_number > ideal_number
    while initial_number > ideal_number
      mesh_cutoff += 10
      initial_number = InvestigatorColleague.find(:all, 
              :conditions => ['investigator_colleagues.mesh_tags_ic > :mesh_cutoff', {:mesh_cutoff => mesh_cutoff}]).length
    end
  else
    while initial_number < ideal_number
      mesh_cutoff -= 10
      initial_number = InvestigatorColleague.find(:all, 
              :conditions => ['investigator_colleagues.mesh_tags_ic > :mesh_cutoff', {:mesh_cutoff => mesh_cutoff}]).length
    end
  end
  mesh_cutoff
end

def findDuplicateTags()
  tags = Tag.all
  innercnt = 0
  last = tags.length-1
  tags.each do |the_tag|
    innercnt +=1
    if the_tag.name.strip != the_tag.name
      puts "Found tag name with spaces: '#{the_tag.name}' id:#{the_tag.id} with #{the_tag.taggings.count} taggings"
    end
    if the_tag.name.length < 4
      puts "Found short tag name: '#{the_tag.name}' id:#{the_tag.id} with #{the_tag.taggings.count} taggings"
    end
    if the_tag.name =~ /^[0-9]/ 
      puts "Found tag starting with numeric: '#{the_tag.name}' id:#{the_tag.id} with #{the_tag.taggings.count} taggings"
    end
    tags[innercnt..last].each do |inner_tag|
      if the_tag.name.downcase == inner_tag.name.downcase
        puts "Found duplicate tag: #{the_tag.name}-id:#{the_tag.id} and #{inner_tag.name}-id:#{inner_tag.id}"
      end
    end
   end
end

def resolveMisformedTags()
  tags = Tag.all
  tags_to_delete = []
  tags.each do |the_tag|
    if the_tag.name.strip != the_tag.name
      puts "Found tag name with spaces: '#{the_tag.name}' id:#{the_tag.id} with #{the_tag.taggings.count} taggings"
      the_tag.name = the_tag.name.strip
      the_tag.save!
    end
    if the_tag.name =~ /\(|\)|\#|\!|\&|\./
      puts "Found tag name with bad characters: '#{the_tag.name}' id:#{the_tag.id} with #{the_tag.taggings.count} taggings"
      the_tag.name = the_tag.name.gsub(/\(|\)|\#|\!|\&|\./,'')
      begin
        the_tag.save!
      rescue
        puts "Duplicate tag exists: '#{the_tag.name}' deleting"
        tags_to_delete << the_tag
      end
    end
    if the_tag.name.length < 3
      puts "Found short tag name: '#{the_tag.name}' id:#{the_tag.id} with #{the_tag.taggings.count} taggings"
      tags_to_delete << the_tag
    end
  end
  deleteTags(tags_to_delete)
end

def resolveDuplicateTags()
  tags = Tag.all
  tags_to_delete = []
  innercnt = 0
  last = tags.length-1
  puts "Processing #{tags.length} tags for duplications"
  tags.each do |the_tag|
    innercnt +=1
    tags[innercnt..last].each do |inner_tag|
      if the_tag.name.downcase == inner_tag.name.downcase
        puts "Found duplicate tag: #{the_tag.name}-id:#{the_tag.id} and #{inner_tag.name}-id:#{inner_tag.id}"
        if inner_tag.name.downcase == inner_tag.name
          tags_to_delete << MoveTagsFromTo(the_tag,inner_tag)
        else
          tags_to_delete << MoveTagsFromTo(inner_tag,the_tag)
        end
      end
    end
  end
  deleteTags(tags_to_delete)
  tags = Tag.all
  puts "Processing #{tags.length} tags for uppercase issues"
  tags.each do |the_tag|
    if the_tag.name.downcase != the_tag.name
      puts "Found tag name with caps: '#{the_tag.name}' id:#{the_tag.id} with #{the_tag.taggings.count} taggings. Making lowercase"
      the_tag.name = the_tag.name.downcase
      the_tag.save!
    end
  end
  puts "Completed processing #{tags.length} tags"
  
end

def deleteTags(tags_to_delete)
  tags_to_delete = tags_to_delete.sort{|x,y| x.id <=> y.id}.uniq
  puts "deleting #{tags_to_delete.length} tags"
  tags_to_delete.each do |the_tag|
    the_tag.taggings.each do |the_tagging|
      the_tagging.delete
    end
    the_tag.delete
  end
end

def MoveTagsFromTo(tag1,tag2)
  taggings1 = tag1.taggings.map(&:taggable_id)
  taggings2 = tag2.taggings.map(&:taggable_id)
  tag2.name = tag2.name.downcase
  tag2.save
  return tag1 if taggings1.length == 0
  tag1.taggings.each do |the_tagging|
    if taggings2.include?(the_tagging.taggable_id)
      the_tagging.delete
    else
      the_tagging.tag_id = tag2.id
      the_tagging.save!
    end
  end
  puts "deleting tag #{tag1.id}:#{tag1.name}. Moved #{(taggings1-taggings2).length} tags, removed #{(taggings1&taggings2).length} tags"
  tag1
end
