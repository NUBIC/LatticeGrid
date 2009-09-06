# -*- ruby -*-

#need to refactor all Match/Find methods
def show_regexp(a, re) 
  if a =~ re 
    "#{$`}<<#{$&}>>#{$'}" 
  else 
    "no match" 
  end 
end 

def FindREmatch(str,re)
  string=str.gsub( /\n|\r/, ';')
  puts show_regexp(string, re) if @debug
  if string =~ re then
    return true
  end
  return false
end

def IsFirstAuthor(abstract,investigator)
  puts "searching for first author using PI #{investigator.last_name}, #{investigator.first_name} "  if @debug
  if abstract.full_authors.blank?
    return FindREmatch(abstract.authors,  /^#{investigator.last_name}, #{investigator.first_name.at(0)}/i)
  else
    return FindREmatch(abstract.full_authors,  /^#{investigator.last_name}, #{investigator.first_name[0..3]}/i) 
  end
  return false
end

def IsLastAuthor(abstract,investigator)
  if abstract.full_authors.blank?
    return FindREmatch(abstract.authors,  /#{investigator.last_name}, #{investigator.first_name.at(0)}[^;]*$/i)
  else
    return FindREmatch(abstract.full_authors,  /#{investigator.last_name}, #{investigator.first_name[0..3]}[^;]*$/i) 
  end
  return false
end


def FindFirstAuthorInCitation(all_investigators,abstract)
  all_investigators.each do |investigator|
    return investigator.id if IsFirstAuthor(abstract,investigator) 
  end
  0
end

def FindLastAuthorInCitation(all_investigators,abstract)
  all_investigators.each do |investigator|
    return investigator.id if IsLastAuthor(abstract,investigator) 
  end
  0
end

def IsAuthor(abstract,investigator)
  if abstract.full_authors.blank?
    abstract.authors.split("\n").each do |author|
      # author string will look like: "Vorontsov, I. I.\nMinasov, G.\nBrunzelle, J. S.\nShuvalova, L.\nKiryukhina, O.\nCollart, F. R.\nAnderson, W. F."
      return true if FindREmatch(author,  /^#{investigator.last_name}, #{investigator.first_name.at(0)}/i)
    end
  else
    abstract.full_authors.split("\n").each do |author|
      # full_author string will look like: "Vorontsov, Ivan I\nMinasov, George\nBrunzelle, Joseph S\nShuvalova, Ludmilla\nKiryukhina, Olga\nCollart, Frank R\nAnderson, Wayne F"
      return true if FindREmatch(author,  /^#{investigator.last_name}, #{investigator.first_name}/i) 
    end
  end
  return false
end

def MatchInvestigatorsInCitation(all_investigators,abstract)
  matched_ids=Array.new
  all_investigators.each do |investigator|
    if IsAuthor(abstract,investigator) then
      matched_ids.push(investigator.id)
    end
  end
  return matched_ids
end

# takes an array of PubMed records
def InsertPubmedRecords(publications)
  row_iterator(publications) { |publication|
    abstract = InsertPublication(publication)
  }
end

# takes a PubMed record, hashed, as an inputs
def InsertPublication (publication)
  puts "InsertPublication: this shouldn't happen - publication was nil" if publication.nil?
  raise "InsertPublication: this shouldn't happen - publication was nil" if publication.nil?
  thePub = nil
  medline = Bio::MEDLINE.new(publication) # convert retrieved format into the medline format
  reference = medline.reference
  thePub = Abstract.find_by_pubmed(reference.pubmed)
  begin 
    if thePub.nil? || thePub.id < 1 then
      thePub = Abstract.create! (
        :endnote_citation => reference.endnote, 
        :abstract => reference.abstract,
        :authors => reference.authors.join("\n"),
        :full_authors => medline.full_authors,
        :publication_date => medline.publication_date,
        :electronic_publication_date => medline.electronic_publication_date,
        :deposited_date => medline.deposited_date,
        :status => medline.status,
        :publication_status => medline.publication_status,
        :title   => reference.title,
        :publication_type => medline.publication_type[0],
        :journal => medline.full_journal[0..253],
        :journal_abbreviation => medline.ta, #journal Title Abbreviation
         :volume  => reference.volume,
        :issue   => reference.issue,
        :pages   => reference.pages,
        :year    => reference.year,
        :pubmed  => reference.pubmed,
        :url     => reference.url,
        :mesh    => reference.mesh.join(";\n")
      )
    else
      if thePub.publication_date != medline.publication_date || thePub.status != medline.status || thePub.publication_status != medline.publication_status then
          thePub.endnote_citation = reference.endnote
          thePub.publication_date = medline.publication_date
          thePub.electronic_publication_date = medline.electronic_publication_date
          thePub.deposited_date = medline.deposited_date
          thePub.publication_status = medline.publication_status
          thePub.status  = medline.status
          thePub.volume  = reference.volume
          thePub.issue   = reference.issue
          thePub.pages   = reference.pages
          thePub.year    = reference.year
          thePub.pubmed  = reference.pubmed
          thePub.url     = reference.url
          thePub.mesh    = reference.mesh.join(";\n")
          thePub.save!
        end
        # HandleMeshTerms(thePub.mesh, thePub.id)
    end
  rescue ActiveRecord::RecordInvalid
     if thePub.nil? then # something bad happened
      puts "InsertPublication: unable to find or insert reference with the pubmed id of '#{reference.pubmed}"
      raise "InsertPublication: unable to find or insert reference with the pubmed id of  '#{reference.pubmed}"
    end
  end 
  thePub
end

def UpdateOrganizationAbstract(unit_id, abstract_id)
  puts "UpdateOrganizationAbstract: this shouldn't happen - abstract_id was nil" if abstract_id.blank?
  puts "UpdateOrganizationAbstract: this shouldn't happen - unit_id was nil" if unit_id.blank?
  return if abstract_id.blank? || unit_id.blank?
  if OrganizationAbstract.find( :first,
    :conditions => [" abstract_id = :abstract_id AND organizational_unit_id = :unit_id",
        {:unit_id => unit_id, :abstract_id => abstract_id}]).nil?
    InsertOrganizationAbstract (unit_id, abstract_id)
  end
end

def InsertOrganizationAbstract (unit_id, abstract_id)
  begin 
     theOrgPub = OrganizationAbstract.create! (
       :abstract_id => abstract_id,
       :organizational_unit_id  => unit_id
     )
   rescue ActiveRecord::RecordInvalid
     if theOrgPub.nil? then # something bad happened
       puts "InsertOrganizationAbstract: unable to either insert or find a reference with the abstract_id '#{abstract_id}' and the unit_id '#{unit_id}'"
       return 
     end
    end
   theOrgPub.id
end

