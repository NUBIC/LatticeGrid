require "pubmed_utilities"
require "publication_utilities"

def CreateAbstractsFromArrayHash(data)
  # These are all validated inputs
  # assumed header values
	 # pmid
	 # employee_id
  pubmed_ids = [] 
   data.each do |data_row|
    pmid = data_row["PMID"]
    pubmed_ids << pmid if ! pmid.blank?
  end
  puts "Total number of  pubmed ids: #{pubmed_ids.length}" if LatticeGridHelper.verbose?
  pubmed_ids = pubmed_ids.sort.uniq
  puts "unique pubmed ids: #{pubmed_ids.length}" if LatticeGridHelper.verbose?
  novel_pubmed_ids = SubtractKnownPubmedIDs(pubmed_ids)
  puts "unknown pubmed ids: #{novel_pubmed_ids.length}" if LatticeGridHelper.verbose?
  puts "unknown pubmed ids #{novel_pubmed_ids.inspect}" if novel_pubmed_ids.length < 200
  publications = FetchPublicationData(novel_pubmed_ids)
  InsertPubmedRecords(publications)
  return novel_pubmed_ids
end


def CreateInvestigatorAbstractsFromHash(data_row, pubmed_ids_to_process)
  # assumed header values
  # believe these investigator-abstract statements are true!
	 # pmid
	 # employee_id
  pubmed_id = data_row["PMID"]
  return unless pubmed_ids_to_process.blank? or pubmed_ids_to_process.include?(pubmed_id)
  employee_id = data_row["EMPLOYEE_ID"] || data_row["NETID"] || data_row["USERNAME"]
  if pubmed_id.blank? || employee_id.blank? then
     puts "pubmed_id or employee_id was blank or missing. datarow="+data_row.inspect 
     return
  end  
  abstract = Abstract.find_by_pubmed_include_deleted(pubmed_id)
  investigator = Investigator.find_by_employee_id(employee_id) || Investigator.find_by_username(employee_id)
  if  abstract.blank? then
     puts "Could not find Abstract. datarow="+data_row.inspect
     return
  end
  if investigator.blank? then
     # puts "Could not find Investigator by employee_id or username. datarow="+data_row.inspect
      return
  end
  ia = InvestigatorAbstract.find(:first, :conditions=>
    ['abstract_id = :abstract_id and investigator_id = :investigator_id ', 
      {:investigator_id => investigator.id, :abstract_id => abstract.id }])
  if ia.nil?
    ia = InsertInvestigatorPublication(abstract.id, investigator.id, (abstract.publication_date||abstract.electronic_publication_date||abstract.deposited_date), IsFirstAuthor(abstract,investigator), IsLastAuthor(abstract,investigator), true)
  else
    ia.is_valid=true
    ia.save!
  end
  if not ia.nil? and (ia.last_reviewed_id.blank? or ia.last_reviewed_id == 0 ) then
    before_abstract_save(ia, 'importInvestigatorPubmedIDs', investigator.id)
    ia.save!
    before_abstract_save(abstract, 'importInvestigatorPubmedIDs', investigator.id)
    abstract.save!
  end
end

def before_abstract_save(model, ip=nil, id=0)
  model.last_reviewed_ip = ip
  model.last_reviewed_at = Time.now
  model.last_reviewed_id = id
  model.reviewed_id ||= id
  model.reviewed_ip ||= ip
  model.reviewed_at ||= Time.now
end   

