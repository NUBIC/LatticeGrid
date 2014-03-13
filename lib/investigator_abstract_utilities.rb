require "pubmed_utilities"
require "publication_utilities"

def CreateAbstractsFromArrayHash(data)
  # These are all validated inputs
  # assumed header values
	 # pmid
	 # employee_id
  pubmed_ids = []
  existing_pubmed_ids = Abstract.include_deleted.map(&:pubmed)
  puts "Total number of existing pubmed ids: #{existing_pubmed_ids.length}" if LatticeGridHelper.verbose?
  existing_employee_ids = Investigator.all.map(&:employee_id).compact.uniq
  puts "Total number of existing employee ids: #{existing_employee_ids.length}" if LatticeGridHelper.verbose?
  #puts "Existing employee ids: #{existing_employee_ids.inspect}" if LatticeGridHelper.verbose?
  cnt=0
  data.each do |data_row|
    cnt+=1
    pubmed_id = data_row["PMID"]
    next if pubmed_id.blank?
    employee_id = data_row["EMPLOYEE_ID"]
    next unless employee_id.blank? or existing_employee_ids.include?(employee_id.to_i)
    next if existing_pubmed_ids.include?(pubmed_id)
    pubmed_ids << pubmed_id
  end
  puts "Total number of  data rows: #{cnt}" if LatticeGridHelper.verbose?
  puts "Total number of  pubmed ids: #{pubmed_ids.length}" if LatticeGridHelper.verbose?
  pubmed_ids = pubmed_ids.sort.uniq
  puts "unique pubmed ids: #{pubmed_ids.length}" if LatticeGridHelper.verbose?
  puts "fetch_publication_data" if LatticeGridHelper.verbose?
  publications = fetch_publication_data(pubmed_ids)
  puts "InsertPubmedRecords #{publications.length}" if LatticeGridHelper.verbose?
  InsertPubmedRecords(publications)
  return pubmed_ids
end


def CreateInvestigatorAbstractsFromHash(data_row, pubmed_ids_to_process, existing_pubmed_ids, existing_employee_ids)
  # assumed header values
  # believe these investigator-abstract statements are true!
	 # pmid
	 # employee_id
  pubmed_id = data_row["PMID"]
  return unless pubmed_ids_to_process.blank? or pubmed_ids_to_process.include?(pubmed_id)
  employee_id = data_row["EMPLOYEE_ID"] # || data_row["NETID"] || data_row["USERNAME"]
  if pubmed_id.blank? || employee_id.blank? then
     puts "pubmed_id or employee_id was blank or missing. datarow="+data_row.inspect
     return
  end
  unless  existing_pubmed_ids.include?(pubmed_id) then
     puts "Not an existing Abstract. datarow="+data_row.inspect
     return
  end
  unless  existing_employee_ids.include?(employee_id.to_i) then
     return
  end
  abstract = Abstract.find_by_pubmed_include_deleted(pubmed_id)
  investigator = Investigator.find_by_employee_id(employee_id) || Investigator.find_by_username(employee_id)
  if  abstract.blank? then
     puts "Could not find Abstract. datarow="+data_row.inspect
     return
  end
  if investigator.blank? then
     puts "Could not find Investigator by employee_id or username. datarow="+data_row.inspect
      return
  end
  ia = InvestigatorAbstract.find(:first, :conditions=>
    ['abstract_id = :abstract_id and investigator_id = :investigator_id ',
      {:investigator_id => investigator.id, :abstract_id => abstract.id }])
  if ia.nil?
    ia = InsertInvestigatorPublication(abstract.id,
                                       investigator.id,
                                       (abstract.publication_date || abstract.electronic_publication_date || abstract.deposited_date),
                                       is_first_author?(abstract,investigator),
                                       is_last_author?(abstract,investigator),
                                       true)
  else
    ia.is_valid = true
    ia.save!
  end
  if not ia.nil? and (ia.last_reviewed_id.blank? or ia.last_reviewed_id == 0)
    before_abstract_save(ia, 'importInvestigatorPubmedIDs', investigator.id)
    ia.save!
    before_abstract_save(abstract, 'importInvestigatorPubmedIDs', investigator.id)
    abstract.save!
  end
  ia
end

def before_abstract_save(model, ip=nil, id=0)
  model.last_reviewed_ip = ip
  model.last_reviewed_at = Time.now
  model.last_reviewed_id = id
  model.reviewed_id ||= id
  model.reviewed_ip ||= ip
  model.reviewed_at ||= Time.now
end

