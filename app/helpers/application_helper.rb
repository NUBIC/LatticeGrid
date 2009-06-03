# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include TagsHelper

  def abstracts_per_year(abstracts, year_array)
    years=Array.new(year_array.length, 0)
    first_year = year_array[0]
    abstracts.each do |abs|
      pos = abs.year.to_i - first_year.to_i
      years[pos]=years[pos]+1 if pos >= 0
    end
    years
  end

  def isInvestigatorFirstAuthor(citation,investigator)
    if getFirstAuthorForCitation(citation) == investigator
      return true
    end
    return false
  end

  def isInvestigatorLastAuthor(citation,investigator)
    if getLastAuthorForCitation(citation) == investigator
      return true
    end
    return false
   end
  
  def setInvestigatorClass(citation,investigator)
    if isInvestigatorLastAuthor(citation,investigator) : "last_author" 
    elsif isInvestigatorFirstAuthor(citation,investigator) : "first_author"
    else
      "author"
    end
  end

  def link_to_collaborators(collaborators, delimiter=", ")
    collaborators.collect{|investigator| link_to( investigator.name, 
      investigator_path(investigator.username), # can't use this form for usernames including non-ascii characters
        :title => " #{investigator.total_pubs_last_five_years} pubs, "+(investigator.num_intraprogam_collaborators_last_five_years+investigator.num_extraprogram_collaborators_last_five_years).to_s+" collaborators")}.join(delimiter)
  end
  
  def link_to_investigator(citation, investigator, tag=nil) 
    tag=investigator.last_name if tag.blank?
    link_to tag, 
      investigator_path(investigator.username), # can't use this form for usernames including non-ascii characters
      :class => setInvestigatorClass(citation,investigator),
      :title => "Go to #{tag}: #{investigator.total_pubs_last_five_years} pubs, "+(investigator.num_intraprogam_collaborators_last_five_years+investigator.num_extraprogram_collaborators_last_five_years).to_s+" collaborators"
  end
  
  def getFirstAuthorIDForCitation(citation)
    citation.investigator_abstracts.each do |investigator_abstract|
      return investigator_abstract.investigator_id if investigator_abstract.is_first_author
    end
    return nil
  end

  def getFirstAuthorForCitation(citation)
    author_id = getFirstAuthorIDForCitation(citation)
    return nil if author_id.blank?
    citation.investigators.each do |investigator|
      return investigator if investigator.id == author_id
    end
    return nil
  end

  def getLastAuthorIDForCitation(citation)
    citation.investigator_abstracts.each do |investigator_abstract|
      return investigator_abstract.investigator_id if investigator_abstract.is_last_author
    end
    return nil
  end

  def getLastAuthorForCitation(citation)
    author_id = getLastAuthorIDForCitation(citation)
    return nil if author_id.blank?
    citation.investigators.each do |investigator|
      return investigator if investigator.id == author_id
    end
    return nil
  end

  def getMembershipMarker(citation,programID)
    intra=0
    inter=0
    marker=""
    citation.investigators.each do |investigator|
      if investigator.investigator_programs.has_program(programID) then
        intra+=1
      else
        inter+=1
      end
    end
    marker="*" if intra > 1
    marker=marker+" §" if inter > 0
    return marker
  end
  
  def highlightInvestigator(citation, authorList=nil)
    if authorList.blank?
      authors = citation.authors.gsub("\n","; ")
    else
      authors = authorList.gsub("\n","; ")
    end
    citation.investigators.each do |investigator|
      re = Regexp.new('('+investigator.last_name+', '+investigator.first_name.at(0)+'[^;]+)') 
      authors.gsub!(re){|match| link_to_investigator(citation, investigator, match)}
    end
    authors
  end
  
  def markProgramMembership(citation, programID)
    if citation.investigators.length > 1 then
      getMembershipMarker(citation,programID)
    end
  end

end
