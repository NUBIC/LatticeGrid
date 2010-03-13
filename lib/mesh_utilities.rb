# -*- ruby -*-

def RearrangeTermsWithCommas(term)
  a = term.split(",").collect{|x| x.strip}
  if a.length > 1 then
    d = a[1]+" "+a[0]
    a.shift
    a[0]=d
  end
  return a.join("-").sub(/(.*)( as Topic)(.*)/i,'\1\3\2')
end
  
def CleanMeshTerm(mesh_term)
  # mesh terms appear to be composite - term root plus one or more categories. For now strip off everything after root
  return [] if mesh_term !~ /\*/
  mesh_array = mesh_term.split(/\//).collect{ |a| a.gsub(/\*/,'')}
  mesh_array.delete("Humans")
  mesh_array.delete("Animals")
  return mesh_array.collect{ |term| RearrangeTermsWithCommas(term)}
end

def CleanMeshTerms(mesh_array)
  # mesh terms appear to be composite - term root plus one or more categories. For now strip off everything after root
  mesh_array.collect{ |mesh_term| CleanMeshTerm(mesh_term)}.flatten.uniq
end

def AddMeshTermstoObject(obj, mesh_array)
  obj.tag_list = mesh_array
  obj.save
end

def TagAbstractWithMeSH(abstract)
  AddMeshTermstoObject(abstract,CleanMeshTerms(abstract.mesh.split(";\n")))
end

def TagInvestigatorWithMeSH(investigator)
  AddMeshTermstoObject(investigator,investigator.abstracts.collect(&:tag_list).flatten.uniq)
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

def SetMeshInformationContent(tag)
  # lets assume that the information content follows a normal distribution, with most tags having little information. Need to normalize to 100
  # Math.log10(@total_tagged_publications) is the largest possible number. For the cancer center the number is about 8000 pubs with MeSH tags
  tag_id=GetTag(tag)
  tagged_abstracts_count=Abstract.find_tagged_with(tag).length
  information_content = 0
  if tagged_abstracts_count > 0
    information_content = 500/(tagged_abstracts_count+4)
  end
  SetTaggings(tag_id,'Abstract',information_content)
  tagged_investigator_count=Investigator.find_tagged_with(tag).length
  information_content = 0
  if tagged_investigator_count > 0
    information_content = 500/(tagged_investigator_count+4)
  end
  SetTaggings(tag_id,'Investigator',information_content)
end

def GetSumTaggedInformationContent(mesh_tag_ids, tag_type, single_id)
  Tagging.find(:all, :conditions => [" taggable_type = :tag_type AND tag_id IN (:tag_ids) AND taggable_id = :taggable_id", {:tag_type => tag_type, :taggable_id => single_id, :tag_ids => mesh_tag_ids}]).collect(&:information_content).sum
end


def GetSumTagInformationContent(mesh_tag_ids, tag_type, abstract_ids)
  Tagging.find(:all, :conditions => [" taggable_type = :tag_type AND tag_id IN (:tag_ids) AND taggable_id IN (:taggable_ids)", {:tag_type => tag_type, :taggable_ids => abstract_ids, :tag_ids => mesh_tag_ids}]).collect(&:information_content).sum
end

def CalculateMeSHinformationContent(investigator,colleague, mesh_tag_ids)
  # these two methods are similar except the tag_list calls the database
  # for all FSM takes about 4 minutes per 10 investigators

  if mesh_tag_ids.length < 1
    return 0
  end
  abstract_ids1 = investigator.abstracts.collect(&:id)
  abstract_ids2 = colleague.abstracts.collect(&:id)
  if abstract_ids1.length < 1 or abstract_ids2.length < 1
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
  
  # Now sum up the number of each tags for each investigator

  ic1 = GetSumTagInformationContent(mesh_tag_ids, "Abstract", abstract_ids1)
  ic2 = GetSumTagInformationContent(mesh_tag_ids, "Abstract", abstract_ids2)
  ic_pi = GetSumTaggedInformationContent(mesh_tag_ids, "Investigator", investigator.id)
  (ic1*ic1+ic2*ic2)/(ic_pi+abstract_ids1.length+abstract_ids2.length+mesh_tag_ids.length)

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
  if (citation_overlap != [] && !citation_overlap.last.blank?)
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
  if (mesh_information_content > 500) then
    return true
  end
  return false
end

def BuildInvestigatorColleague(investigator, colleague, update_only=true)
  if update_only && !InvestigatorColleague.find( :first,
    :conditions => [" investigator_id = :investigator_id AND colleague_id = :colleague_id",
        {:investigator_id => investigator.id, :colleague_id => colleague.id}]).nil?
    return
  end
  citation_overlap = investigator.abstracts.collect{|x| x.id}.flatten & colleague.abstracts.collect{|x| x.id}.flatten
  citation_overlap = citation_overlap.uniq.compact
  mesh_tag_ids = investigator.abstracts.collect{|x| x.tags.collect(&:id)}.flatten & colleague.abstracts.collect{|x| x.tags.collect(&:id)}.flatten
  
  mesh_information_content=CalculateMeSHinformationContent(investigator, colleague, mesh_tag_ids)

  if InvestigatorColleagueInclusionCriteria(citation_overlap,mesh_information_content) then
    InsertUpdateInvestigatorColleague(investigator.id,colleague.id,citation_overlap,mesh_tag_ids,mesh_information_content)
    #repeat as inverse
    InsertUpdateInvestigatorColleague(colleague.id,investigator.id,citation_overlap,mesh_tag_ids,mesh_information_content) 
    #puts "Found relationship: #{investigator.name} and #{colleague.name}: citations: #{citation_overlap.join(', ')}; mesh_ic: #{mesh_information_content} " if @verbose && citation_overlap.length > 0 
  end
end

def InsertUpdateInvestigatorColleague(investigator_id,colleague_id,citation_overlap,mesh_overlap,mesh_information_content )
  ir = InvestigatorColleague.find( :first,
    :conditions => [" investigator_id = :investigator_id AND colleague_id = :colleague_id",
        {:investigator_id => investigator_id, :colleague_id => colleague_id}])
    if ir.nil?
      InsertInvestigatorColleague(investigator_id,colleague_id,citation_overlap,mesh_overlap,mesh_information_content )
    else
      UpdateInvestigatorColleague(ir,citation_overlap,mesh_overlap,mesh_information_content )
    end
end

def UpdateInvestigatorColleague(ir,citation_overlap,mesh_overlap,mesh_information_content )
  begin 
    ir.mesh_tags_cnt = mesh_overlap.length
    ir.mesh_tags_ic = mesh_information_content
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

def InsertInvestigatorColleague(investigator_id,colleague_id,citation_overlap,mesh_overlap,mesh_information_content )
  begin 
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

