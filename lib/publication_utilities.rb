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
  puts show_regexp(string, re) if LatticeGridHelper.debug?
  if string =~ re then
    return true
  end
  return false
end

# abstract.authors string will look like: "Vorontsov, I. I.\nMinasov, G.\nBrunzelle, J. S.\nShuvalova, L.\nKiryukhina, O.\nCollart, F. R.\nAnderson, W. F."

# abstract.full_authors  string will look like: "Vorontsov, Ivan I\nMinasov, George\nBrunzelle, Joseph S\nShuvalova, Ludmilla\nKiryukhina, Olga\nCollart, Frank R\nAnderson, Wayne F"
# full_authors string:  "Munoz, Lenka\n Ranaivo, Hantamalala Ralay\n Roy, Saktimayee M\n Hu, Wenhui\n Craft, Jeffrey M\n McNamara, Laurie K\n Chico, Laura Wing\n Van Eldik, LJ\n Watterson, DM"

def GetAuthor(string, is_full)
  if is_full
    re = /([^,\n\r]+), +([^;\n\r ]+) *([^;\n\r ]*)/
  else
    re = /([^,\n\r]+), +(.) *([^;\n\r ]*)/
  end
  re.match(string)
  return [$1, $2] if $3.blank?
  return [$1, $2, $3].compact
end

# used when inserting InvestigatorAbstract record
def IsFirstAuthor(abstract,investigator)
  puts "searching for first author using PI #{investigator.last_name}, #{investigator.first_name} "  if LatticeGridHelper.debug?
  if abstract.full_authors.blank?
    return FindREmatch(abstract.authors,  /^#{investigator.last_name}, #{investigator.first_name.at(0)}/i)
  else
    return FindREmatch(abstract.full_authors,  /^#{investigator.last_name}, #{investigator.first_name[0..3]}/i) 
  end
  return false
end

# used when inserting InvestigatorAbstract record
def IsLastAuthor(abstract,investigator)
  if abstract.full_authors.blank?
    return FindREmatch(abstract.authors,  /#{investigator.last_name}, #{investigator.first_name.at(0)}[^;]*$/i)
  else
    return FindREmatch(abstract.full_authors,  /#{investigator.last_name}, #{investigator.first_name[0..3]}[^;]*$/i) 
  end
  return false
end

def FindFirstAuthorInCitation(citation_investigators,abstract)
  citation_investigators.each do |investigator|
    return investigator.id if IsFirstAuthor(abstract,investigator) 
  end
  0
end

def FindLastAuthorInCitation(citation_investigators,abstract)
  citation_investigators.each do |investigator|
    return investigator.id if IsLastAuthor(abstract,investigator) 
  end
  0
end

def GetInvestigatorIDfromAuthorRecord(author_rec, author_string="")
  return 0  if author_rec.compact.length < 2
  if author_rec.length > 2 then
    # search for last_name, first_name and middle_name
    investigators = Investigator.find(:all, 
      :conditions=>["lower(last_name) = :last_name and lower(first_name) like :first_name || '%' and lower(middle_name) like :middle_name || '%' ", 
          {:last_name => author_rec[0].downcase, :first_name => author_rec[1].downcase, :middle_name => author_rec[2].downcase}] )
    if investigators.length == 0 and author_rec[1] != author_rec[1].first then
      # now look for last_name first_initial and middle_initial
      investigators = Investigator.find(:all, 
        :conditions=>["lower(last_name) = :last_name and lower(first_name) like :first_name || '%' and lower(middle_name) like :middle_name || '%' ", 
            {:last_name => author_rec[0].downcase, :first_name => author_rec[1].first.downcase, :middle_name => author_rec[2].first.downcase}] )
    end
  else # last_name and first_name only
    # search for last_name and first_name
    investigators = Investigator.find(:all, :conditions=>["lower(last_name) = :last_name and lower(first_name) like :first_name || '%' ", 
        {:last_name => author_rec[0].downcase, :first_name => author_rec[1].downcase}] )
    return investigators[0].id if investigators.length == 1
    if investigators.length == 0 and author_rec[1] != author_rec[1].first then
      investigators = Investigator.find(:all, :conditions=>["lower(last_name) = :last_name and lower(first_name) like :first_name || '%' ", 
            {:last_name => author_rec[0].downcase, :first_name => author_rec[1].first.downcase}] )
    end
  end
  puts "Multiple investigators matching #{author_rec.inspect} found. Author was #{author_string}" if investigators.length > 1 and LatticeGridHelper.debug?
  return investigators[0].id if investigators.length == 1
  0
end  

def GetAuthorStringArray(abstract, is_full)
  if is_full
    abstract.full_authors.split("\n")
  else
    abstract.authors.split("\n")
  end
end

def FindFirstAuthor(abstract)
  is_full = ! abstract.full_authors.blank?
  author_array = GetAuthor(GetAuthorStringArray(abstract,is_full).first, is_full)
  return GetInvestigatorIDfromAuthorRecord(author_array)
end

def FindLastAuthor(abstract)
  is_full = ! abstract.full_authors.blank?
  author_array = GetAuthor(GetAuthorStringArray(abstract,is_full).last, is_full)
  return GetInvestigatorIDfromAuthorRecord(author_array)
end

def MatchInvestigatorsInCitation(abstract)
  matched_ids = []
  is_full = ! abstract.full_authors.blank?
  author_array = GetAuthorStringArray(abstract,is_full)
  author_array.each do | author |
    author_ary = GetAuthor(author, is_full)
    author_id = GetInvestigatorIDfromAuthorRecord(author_ary, author)
    matched_ids.push(author_id) if author_id > 0
  end
  return matched_ids
end

# takes an array of PubMed records
def InsertPubmedRecords(publications)
  publications.each do |publication|
    abstract = InsertPublication(publication)
  end
end

def updateAbstractWithPMCID(pubmed_record)
  InsertPublication(pubmed_record, true)
end


# takes a PubMed record, hashed, as an inputs
def InsertPublication(publication, update_if_pmc_exists=false)
  puts "InsertPublication: this shouldn't happen - publication was nil" if publication.nil?
  raise "InsertPublication: this shouldn't happen - publication was nil" if publication.nil?
  thePub = nil
  medline = Bio::MEDLINE.new(publication) # convert retrieved format into the medline format
  reference = medline.reference
  pubmed_central_id = medline.pubmed_central
  pubmed_central_id = nil if pubmed_central_id.blank?

  thePub = Abstract.find_by_pubmed_include_deleted(reference.pubmed)
  begin 
    if thePub.nil? || thePub.id < 1 then
      thePub = Abstract.create!(
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
        :issn => medline.issn,
        :volume  => reference.volume,
        :issue   => reference.issue,
        :pages   => reference.pages,
        :year    => reference.year,
        :pubmed  => reference.pubmed,
        :pubmedcentral  => pubmed_central_id,
        :url     => reference.url,
        :mesh    => reference.mesh.is_a?(String) ? reference.mesh : reference.mesh.join(";\n")
      )
    else
      if thePub.publication_date != medline.publication_date || thePub.status != medline.status || thePub.publication_status != medline.publication_status || (thePub.pubmedcentral != pubmed_central_id) || thePub.issn != medline.issn then
          thePub.endnote_citation = reference.endnote
          thePub.publication_date = medline.publication_date
          thePub.electronic_publication_date = medline.electronic_publication_date
          thePub.deposited_date = medline.deposited_date
          thePub.publication_status = medline.publication_status
          thePub.status  = medline.status
          thePub.issn    = medline.issn if ! medline.issn.blank?
          thePub.volume  = reference.volume
          thePub.issue   = reference.issue
          thePub.pages   = reference.pages
          thePub.year    = reference.year
          thePub.pubmed  = reference.pubmed
          thePub.pubmedcentral  = pubmed_central_id
          thePub.url     = reference.url
          thePub.mesh    = reference.mesh.is_a?(String) ? reference.mesh : reference.mesh.join(";\n")
          thePub.save!
        end
        # HandleMeshTerms(thePub.mesh, thePub.id)
    end
  rescue ActiveRecord::RecordInvalid  => exc
     if thePub.nil? then # something bad happened
      puts "InsertPublication: unable to find or insert reference with the pubmed id of '#{reference.pubmed}. error message: #{exc.message}"
      raise "InsertPublication: unable to find or insert reference with the pubmed id of  '#{reference.pubmed}. error message: #{exc.message}"
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
    InsertOrganizationAbstract(unit_id, abstract_id)
  end
end

def InsertOrganizationAbstract(unit_id, abstract_id)
  begin 
     theOrgPub = OrganizationAbstract.create!(
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

