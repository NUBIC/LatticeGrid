# -*- coding: utf-8 -*-
# -*- ruby -*-

# need to refactor all Match/Find methods
def show_regexp(a, re)
  if a =~ re
    "#{$`}<<#{$&}>>#{$'}"
  else
    'no match'
  end
end

def SimpleFindREmatch(str, re)
  return false if str.blank?
  return true if str =~ re
  false
end

# abstract.authors string will look like: "Vorontsov, I. I.\nMinasov, G.\nBrunzelle, J. S.\nShuvalova, L.\nKiryukhina, O.\nCollart, F. R.\nAnderson, W. F."
# abstract.full_authors  string will look like: "Vorontsov, Ivan I\nMinasov, George\nBrunzelle, Joseph S\nShuvalova, Ludmilla\nKiryukhina, Olga\nCollart, Frank R\nAnderson, Wayne F"
# full_authors string:  "Munoz, Lenka\n Ranaivo, Hantamalala Ralay\n Roy, Saktimayee M\n Hu, Wenhui\n Craft, Jeffrey M\n McNamara, Laurie K\n Chico, Laura Wing\n Van Eldik, LJ\n Watterson, DM"
# full_authors string for some: "Shumaker, D K\nVann, L R\nGoldberg, M W\nAllen, T D\nWilson, K L" - this really looks like a authors string

def GetAuthor(string, is_full)
  if is_full
    re = /([^,\n\r]+), +([^;\n\r ]+) *([^;\n\r ]*)/
  else
    re = /([^,\n\r]+), +(.)\.? *([^;\n\r\. ]*)/
  end
  re.match(string)
  return [$1, $2] if $3.blank?
  [$1, $2, $3].compact
end

def AuthorRE(investigator, is_full)
  if is_full
    return /#{investigator.last_name}, #{investigator.first_name[0..3]}/i
  else
    return /#{investigator.last_name}, #{investigator.first_name.at(0)}/i
  end
end

# used when inserting InvestigatorAbstract record
def is_first_author?(abstract, investigator)
  puts "searching for first author using PI #{investigator.last_name}, #{investigator.first_name} "  if LatticeGridHelper.debug?
  auth_arry = abstract.author_array
  return true if auth_arry.length == 1
  SimpleFindREmatch(auth_arry.first, AuthorRE(investigator, abstract.has_full))
end

# used when inserting InvestigatorAbstract record
def is_last_author?(abstract, investigator)
  auth_arry = abstract.author_array
  return true if auth_arry.length == 1
  SimpleFindREmatch(auth_arry.last, AuthorRE(investigator,abstract.has_full))
end

def FindFirstAuthorInCitation(citation_investigators,abstract)
  auth = abstract.author_array.first
  is_full = abstract.has_full
  citation_investigators.each do |investigator|
    return investigator.id if SimpleFindREmatch(auth, AuthorRE(investigator, is_full))
  end
  0
end

def FindLastAuthorInCitation(citation_investigators,abstract)
  auth = abstract.author_array.last
  is_full = abstract.has_full
  citation_investigators.each do |investigator|
    return investigator.id if SimpleFindREmatch(auth, AuthorRE(investigator, is_full))
  end
  0
end

def GetInvestigatorIDfromAuthorRecord(author_rec, author_string="")
  return 0  if author_rec.compact.length < 2
  if author_rec.length > 2
    # search for last_name, first_name and middle_name
    investigators = Investigator.find(:all,
      :conditions=>["lower(last_name) = :last_name and lower(first_name) like :first_name  and lower(middle_name) like :middle_name  ",
          {:last_name => author_rec[0].downcase, :first_name => author_rec[1].downcase+'%', :middle_name => author_rec[2].downcase+'%'}] )
    if investigators.length == 0 and author_rec[1] != author_rec[1].first
      # now look for last_name first_initial and middle_initial
      investigators = Investigator.find(:all,
        :conditions=>["lower(last_name) = :last_name and lower(first_name) like :first_name and lower(middle_name) like :middle_name ",
            {:last_name => author_rec[0].downcase, :first_name => author_rec[1].first.downcase+'%', :middle_name => author_rec[2].first.downcase+'%'}] )
    end
    if investigators.length == 0
      # now look for last_name first_initial in entries where the middle name is blank!
      investigators = Investigator.find(:all,
        :conditions=>["lower(last_name) = :last_name and lower(first_name) like :first_name and (middle_name is NULL or middle_name = '') ",
            {:last_name => author_rec[0].downcase, :first_name => author_rec[1].first.downcase+'%'}] )
    end
  else # last_name and first_name only
    # search for last_name and first_name
    investigators = Investigator.find(:all, :conditions=>["lower(last_name) = :last_name and lower(first_name) like :first_name  ",
        {:last_name => author_rec[0].downcase, :first_name => author_rec[1].downcase+'%'}] )
    return investigators[0].id if investigators.length == 1
    if investigators.length == 0 && author_rec[1] != author_rec[1].first
      investigators = Investigator.find(:all, :conditions=>["lower(last_name) = :last_name and lower(first_name) like :first_name and (middle_name is NULL or middle_name = '')",
            {:last_name => author_rec[0].downcase, :first_name => author_rec[1].first.downcase+'%'}] )
    end
    if investigators.length == 0 && author_rec[1] != author_rec[1].first
      investigators = Investigator.find(:all, :conditions=>["lower(last_name) = :last_name and lower(first_name) like :first_name ",
            {:last_name => author_rec[0].downcase, :first_name => author_rec[1].first.downcase+'%'}] )
    end
  end
  puts "Multiple investigators matching #{author_rec.inspect} found. Author was #{author_string}" if investigators.length > 1 and LatticeGridHelper.debug?
  return investigators[0].id if investigators.length == 1
  0
end

def FindFirstAuthor(abstract)
  author_array = GetAuthor(abstract.author_array.first, abstract.has_full)
  return GetInvestigatorIDfromAuthorRecord(author_array)
end

def FindLastAuthor(abstract)
  author_array = GetAuthor(abstract.author_array.last, abstract.has_full)
  return GetInvestigatorIDfromAuthorRecord(author_array)
end

def MatchInvestigatorsInCitation(abstract)
  matched_ids = []
  author_array = abstract.author_array
  author_array.each do | author |
    author_ary = GetAuthor(author, abstract.has_full)
    author_id = GetInvestigatorIDfromAuthorRecord(author_ary, author)
    matched_ids.push(author_id) if author_id > 0
  end
  matched_ids
end

# takes an array of PubMed records
def InsertPubmedRecords(publications)
  publications.each { |publication| InsertPublication(publication) }
end

def updateAbstractWithPMCID(pubmed_record)
  InsertPublication(pubmed_record, true)
end

# takes a PubMed record, hashed, as an inputs
def InsertPublication(publication, update_if_pmc_exists = false)
  puts "InsertPublication: this shouldn't happen - publication was nil" if publication.nil?
  raise "InsertPublication: this shouldn't happen - publication was nil" if publication.nil?
  the_pub = nil
  medline = Bio::MEDLINE.new(publication) # convert retrieved format into the medline format
  reference = medline.reference
  pubmed_central_id = medline.pubmed_central
  pubmed_central_id = nil if pubmed_central_id.blank?
  if reference.pubmed.blank?
    puts "pubmed_id was blank for reference #{medline.inspect}"
    return nil
  end
  publication_date = check_date(medline.publication_date, medline.electronic_publication_date,  medline.deposited_date, reference.pubmed)
  the_pub = Abstract.find_by_pubmed_include_deleted(reference.pubmed)
  the_pub = Abstract.find_by_doi_include_deleted(medline.doi) if the_pub.nil? || the_pub.id < 1
  begin
    if the_pub.nil? || the_pub.id < 1
      the_pub = Abstract.create!(
        :endnote_citation => reference.endnote,
        :abstract => reference.abstract,
        :authors => reference.authors.join("\n"),
        :full_authors => medline.full_authors,
        :author_affiliations => medline.affiliations.is_a?(String) ? medline.affiliations : medline.affiliations.join(";\n"),
        :publication_date => publication_date,
        :electronic_publication_date => medline.electronic_publication_date,
        :deposited_date => medline.deposited_date,
        :status => medline.status,
        :publication_status => medline.publication_status,
        :title => reference.title,
        :publication_type => medline.publication_type[0],
        :journal => medline.full_journal[0..253],
        :journal_abbreviation => medline.ta, #journal Title Abbreviation
        :issn => medline.issn,
        :doi => medline.doi,
        :volume  => reference.volume,
        :issue   => reference.issue,
        :pages   => reference.pages,
        :year    => reference.year,
        :pubmed  => reference.pubmed,
        :pubmedcentral  => pubmed_central_id,
        :url     => reference.url,
        :mesh    => reference.mesh.is_a?(String) ? reference.mesh : reference.mesh.join(";\n"))
    else
      if the_pub.publication_date != publication_date || the_pub.status != medline.status || the_pub.publication_status != medline.publication_status || (the_pub.pubmedcentral != pubmed_central_id) || the_pub.issn != medline.issn || the_pub.doi != medline.doi || the_pub.year != reference.year
        the_pub.endnote_citation = reference.endnote
        the_pub.publication_date = publication_date unless publication_date.blank?
        the_pub.electronic_publication_date = medline.electronic_publication_date unless medline.electronic_publication_date.blank?
        the_pub.deposited_date = medline.deposited_date
        the_pub.publication_status = medline.publication_status
        the_pub.status  = medline.status
        the_pub.issn    = medline.issn unless medline.issn.blank?
        the_pub.doi     = medline.doi  unless medline.doi.blank?
        the_pub.volume  = reference.volume
        the_pub.issue   = reference.issue
        the_pub.pages   = reference.pages
        the_pub.year    = reference.year
        the_pub.pubmed  = reference.pubmed
        the_pub.pubmedcentral  = pubmed_central_id
        the_pub.url     = reference.url
        the_pub.author_affiliations = medline.affiliations.is_a?(String) ? medline.affiliations : medline.affiliations.join(";\n"),
        the_pub.mesh = reference.mesh.is_a?(String) ? reference.mesh : reference.mesh.join(";\n")
        the_pub.save!
      end
      # HandleMeshTerms(the_pub.mesh, the_pub.id)
    end
  rescue ActiveRecord::RecordInvalid  => exc
    if the_pub.nil? # something bad happened
      msg = "InsertPublication: unable to find or insert reference with the pubmed id of '#{reference.pubmed}. error message: #{exc.message}"
      puts msg
      raise msg
    end
  end
  the_pub
end

def UpdateOrganizationAbstract(unit_id, abstract_id)
  puts "UpdateOrganizationAbstract: this shouldn't happen - abstract_id was nil" if abstract_id.blank?
  puts "UpdateOrganizationAbstract: this shouldn't happen - unit_id was nil" if unit_id.blank?
  return if abstract_id.blank? || unit_id.blank?
  org_abstract = OrganizationAbstract.where('abstract_id = ? AND organizational_unit_id = ?', abstract_id, unit_id).first
  InsertOrganizationAbstract(unit_id, abstract_id) if org_abstract.nil?
end

def InsertOrganizationAbstract(unit_id, abstract_id)
  begin
     pub = OrganizationAbstract.create!(abstract_id: abstract_id, organizational_unit_id: unit_id)
   rescue ActiveRecord::RecordInvalid
     if pub.nil? # something bad happened
       puts "InsertOrganizationAbstract: unable to either insert or find a reference with the abstract_id '#{abstract_id}' and the unit_id '#{unit_id}'"
       return
     end
    end
   pub.id
end

# use this as a last minute check for a publication date.
def check_date(pub_date, edate, created_date, pubmed_id)
  if pub_date.blank?
    puts "pubdate for #{pubmed_id} was blank!"
    return nil
  end
  begin
    pub_date.to_date
  rescue
    today = Date.today
    if pub_date =~ /([0-9]+)-([a-zA-Z]+)-([0-9]+)/
      day   = $1
      month = $2
      year  = $3
      day   = 1 unless (day === (1..28))
      month = 'Jan' unless month =~ /jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec/i
      unless (year === (1800..today.year))
        year = edate.to_date.year unless edate.blank?
        year = created_date.to_date.year if year.blank? and !created_date.blank?
        year = today.year if year.blank?
      end
      puts "check_date ERROR handling: invalid date for #{pubmed_id} was #{pub_date} and is #{day}-#{month}-#{year}"
    else
      day   = '1'
      month = 'Jan'
      year  = edate.to_date.year unless edate.blank?
      year  = created_date.to_date.year if year.blank? and !created_date.blank?
      year  = today.year if year.blank?
      puts "check_date ERROR handling: INVALID DATE FORMAT: date for #{pubmed_id} was #{pub_date} and is #{day}-#{month}-#{year}"
    end
    pub_date = "#{day}-#{month}-#{year}"
  end
  pub_date
end
