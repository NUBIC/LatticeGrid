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
  tag_id=GetTag(tag)
  abstracts_count=Abstract.find_tagged_with(tag).length
  if abstracts_count > 0
  information_content = @total_tagged_publications/abstracts_count
  else
    information_content = 0
  end
  SetTaggings(tag_id,'Abstract',information_content)
  tagged_investigator_count=Investigator.find_tagged_with(tag).length
  if tagged_investigator_count > 0
  information_content = @total_investigators/tagged_investigator_count
  else
    information_content = 0
  end
  SetTaggings(tag_id,'Investigator',information_content)
end

def CalculateMeSHinformationContent(mesh_array)
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

def CalculateMeSHinformationContent_old(mesh_array)
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

def InvestigatorColleagueInclusionCriteria(citation_overlap,mesh_overlap,mesh_information_content)
  if (citation_overlap != [] && !citation_overlap.last.blank?)
    # always include if they copublish
    return true
  end
#  if  (mesh_overlap.length != [] && !mesh_overlap.last.blank?) then
    # looking across 2100 fsm members, there are more than 300,000 mesh_information_content 'hits' with no publication overlap
    # at an ic > 200 there are still 150,000 entries, and at 500 there are 100,000 entries. At 1000 there are 66,000 entries
    # so for an ic > 500 there are still 50 entries per person on average. The number is slightly higher, as only 1500 of the 2100
    # fsm members have publications in PubMed
  if (mesh_information_content > 2000) then
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
  # these two methods are similar except the tag_list calls the database
  # for all FSM takes about 4 minutes per 10 investigators
  mesh_overlap = investigator.abstracts.collect{|x| x.tag_list}.flatten & colleague.abstracts.collect{|x| x.tag_list}.flatten
  # this one does a lot of processing and is slower about 5 minutes per 10 investigators
  # mesh_overlap = investigator.abstracts.collect{|x| CleanMeshTerms(x.mesh.split(";\n"))}.flatten & colleague.abstracts.collect{|x| CleanMeshTerms(x.mesh.split(";\n"))}.flatten
  mesh_overlap = mesh_overlap.uniq.compact
  mesh_information_content=0
  if (mesh_overlap.length != [] && !mesh_overlap.last.blank?) then
     mesh_information_content=CalculateMeSHinformationContent(mesh_overlap)
  end
  if InvestigatorColleagueInclusionCriteria(citation_overlap,mesh_overlap,mesh_information_content) then
    InsertUpdateInvestigatorColleague(investigator.id,colleague.id,citation_overlap,mesh_overlap,mesh_information_content)
    #repeat as inverse
    InsertUpdateInvestigatorColleague(colleague.id,investigator.id,citation_overlap,mesh_overlap,mesh_information_content) 
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
    if ir.updated_at < 7.days.ago
     ir.mesh_tags_cnt = mesh_overlap.length
     ir.mesh_tags_ic = mesh_information_content
     ir.publication_cnt = citation_overlap.length
     ir.publication_list = citation_overlap.join(',')
     ir.save!
   end
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

