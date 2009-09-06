require "pubmed_utilities"
require "publication_utilities"

def CreateAbstractsFromArrayHash(data)
  # assumed header values
	 # pmid
	 # employee_id
  pubmed_ids = [] 
   data.each do |data_row|
    pmid = data_row["PMID"]
    pubmed_ids << pmid if ! pmid.blank?
  end
  puts "Total number of  abstracts: #{pubmed_ids.length}" if @verbose
  pubmed_ids = pubmed_ids.sort.uniq
  puts "unique abstracts: #{pubmed_ids.length}" if @verbose
  publications = FetchPublicationData(pubmed_ids)
  InsertPubmedRecords(publications)
end


def CreateInvestigatorAbstractsFromHash(data_row)
  # assumed header values
	 # pmid
	 # employee_id
  pubmed_id = data_row["PMID"]
  employee_id = data_row["EMPLOYEE_ID"]
  if pubmed_id.blank? || employee_id.blank? then
     puts "pubmed_id or employee_id was blank or missing. datarow="+data_row.inspect
     return
  end  
  abstract = Abstract.find_by_pubmed(pubmed_id)
  investigator = Investigator.find_by_employee_id(employee_id)
  if  abstract.blank? then
     puts "Could not find Abstract. datarow="+data_row.inspect
     return
  end
  if investigator.blank? then
      puts "Could not find Investigator by employee_id. datarow="+data_row.inspect
      return
  end
  investigator_abstract = InvestigatorAbstract.new(:abstract_id=>abstract.id, :investigator_id=>investigator.id)
  exists = InvestigatorAbstract.find(:first, :conditions=>
    ['abstract_id = :abstract_id and investigator_id = :investigator_id ', 
      {:investigator_id => investigator_abstract.investigator_id, :abstract_id => investigator_abstract.abstract_id }])
  if exists.nil?
    investigator_abstract.save
  end
end
