require 'csv'

namespace :export do

  task :uuidify => :environment do 
    [Investigator, OrganizationalUnit, InvestigatorAppointment, Abstract, InvestigatorAbstract].each do |cls|
      cls.all.each { |record| record.save! }
    end
  end

  def create_abstracts_csv(csv, records)
    cols = %w(id uuid abstract title pubmed pubmedcentral full_authors isbn)
    csv << cols
    records.each do |abstract|
      arr = []
      cols.each do |col| 
        val = abstract.send(col.to_sym)
        val = val.gsub(/\n/, '; ') if col == 'full_authors'
        arr << val
      end
      csv << arr.map(&:to_s)
    end
  end

  task :documents => :environment do 
    CSV.open("#{Rails.root}/tmp/documents.csv", 'wb', :col_sep => ',') do |csv|
      create_abstracts_csv(csv, Abstract.all)
    end
  end

  task :articles => :environment do
    CSV.open("#{Rails.root}/tmp/articles.csv", 'wb', :col_sep => ',') do |csv|
      create_abstracts_csv(csv, Abstract.where("publication_type LIKE '%Article%'").to_a)
    end
  end

  task :abstracts => :environment do
    CSV.open("#{Rails.root}/tmp/abstracts.csv", 'wb', :col_sep => ',') do |csv|
      create_abstracts_csv(csv, Abstract.where("publication_type NOT LIKE '%Article%'").to_a)
    end
  end

  def create_investigator_abstracts_csv(csv, records)
    cols = %w(id uuid investigator_uuid abstract_uuid)
    csv << cols
    records.each do |ia|
      arr = []
      cols.each { |col| arr << abstract.send(col.to_sym) }
      csv << arr.map(&:to_s)
    end
  end

  task :investigator_abstracts => :environment do 
    CSV.open("#{Rails.root}/tmp/investigator_abstracts.csv", 'wb', :col_sep => ',') do |csv|
      create_abstracts_csv(csv, InvestigatorAbstract.all)
    end
  end

  def create_organizational_unit_csv(csv, records)
    cols = %w(id uuid abbreviation campus department_id division_id name organization_classification organization_phone organization_url search_name type)
    csv << cols
    records.each do |ou|
      arr = []
      cols.each { |col| arr << ou.send(col.to_sym) }
      csv << arr.map(&:to_s)
    end
  end

  task :departments => :environment do
    CSV.open("#{Rails.root}/tmp/departments.csv", 'wb', :col_sep => ',') do |csv|
      create_organizational_unit_csv(csv, Department.all)
    end
  end

  task :divisions => :environment do
    CSV.open("#{Rails.root}/tmp/divisions.csv", 'wb', :col_sep => ',') do |csv|
      create_organizational_unit_csv(csv, Division.all)
    end
  end

  task :centers => :environment do
    CSV.open("#{Rails.root}/tmp/centers.csv", 'wb', :col_sep => ',') do |csv|
      create_organizational_unit_csv(csv, Center.all)
    end
  end

  task :investigators => :environment do
    cols = %w(id uuid appointment_basis appointment_type campus degrees email employee_id faculty_interests faculty_research_summary name first_name last_name middle_name suffix title username)
    CSV.open("#{Rails.root}/tmp/investigators.csv", 'wb', :col_sep => ',') do |csv|
      csv << cols
      Investigator.all.each do |pi|
        arr = []
        cols.each { |col| arr << pi.send(col.to_sym) }
        csv << arr.map(&:to_s)
      end
    end
  end

  task :investigator_appointments => :environment do
    cols = %w(id uuid investigator_uuid organizational_unit_uuid type)
    CSV.open("#{Rails.root}/tmp/investigator_appointments.csv", 'wb', :col_sep => ',') do |csv|
      csv << cols
      InvestigatorAppointment.all.each do |ia|
        next if ia.investigator.blank? || ia.organizational_unit.blank?
        arr = []
        cols.each { |col| arr << ia.send(col.to_sym)  }
        csv << arr.map(&:to_s)
      end
      Investigator.all.each do |i|
        next if i.home_department.blank?
        arr = []
        arr << 100000 + i.id          # id
        arr << i.uuid                 # investigator_id
        arr << i.home_department.uuid # organizational_unit_id
        arr << 'Primary'
        csv << arr
      end
    end
  end

  task :kibbe_coauthors => :environment do 
    pi = Investigator.find_all_by_username('wakibbe').first
    run_vivo_curl(pi)
    filename = "#{Rails.root}/tmp/coauthors/#{pi.uuid}.json"
    file = File.read(filename)
    data = JSON.parse(file)
    coauthor_array = data["results"]["bindings"]
    coauthor_array.each do |coauthor|
      uri = coauthor["Coauthor"]["value"]
      co_uuid = pi.uuid_from_uri(uri)
      run_vivo_curl(pi, uri, co_uuid)
    end
  end

  def run_vivo_curl(pi, uri = nil, uuid = nil)
    uuid = pi.uuid if uuid.nil?
    File.open('coauthor.sparql', 'w') { |file| file.write(pi.coauthor_sparql(uri)) }
    %x( curl -d 'email=vivo_root@northwestern.edu' -d 'password=13#vivo#' -d '@coauthor.sparql' -H 'Accept: application/sparql-results+json' 'http://localhost:8080/vivo/api/sparqlQuery' > tmp/coauthors/#{uuid}.json )    
  end

  task :kibbe_publication_count => :environment do 
    pi = Investigator.find_all_by_username('wakibbe').first
    run_publication_count_curl(pi)
    filename = "#{Rails.root}/tmp/coauthors/#{pi.uuid}.json"
    file = File.read(filename)
    data = JSON.parse(file)
    coauthor_array = data["results"]["bindings"]
    coauthor_array.each do |coauthor|
      uri = coauthor["Coauthor"]["value"]
      co_uuid = pi.uuid_from_uri(uri)
      run_publication_count_curl(pi, uri, co_uuid)
    end

  end

  def run_publication_count_curl(pi, uri = nil, uuid = nil)
    uuid = pi.uuid if uuid.nil?
    File.open('publication_count.sparql', 'w') { |file| file.write(pi.publication_count_sparql(uri)) }
    %x( curl -d 'email=vivo_root@northwestern.edu' -d 'password=13#vivo#' -d '@publication_count.sparql' -H 'Accept: application/sparql-results+json' 'http://localhost:8080/vivo/api/sparqlQuery' > tmp/publication_counts/#{uuid}.json )
  end

  task :kibbe_chord_data => :environment do 
    pi = Investigator.find_all_by_username('wakibbe').first
    
    coauthor_array = get_coauthor_array(pi.uuid)
    pi_imports = imports(coauthor_array)

    coauthors = []
    coauthors << {name: pi.name, size: pub_count(pi.uuid), imports: pi_imports}
    coauthor_array.each do |coauthor|
      uri  = coauthor["Coauthor"]["value"]
      name = coauthor["Coauthor_name"]["value"]
      co_uuid = pi.uuid_from_uri(uri)
      pub_cnt = pub_count(co_uuid)
      coauthor_array = get_coauthor_array(co_uuid)      
      co_imports = imports(coauthor_array)

      coauthors << {name: name, size: pub_cnt, imports: (pi_imports & co_imports)}
    end
    File.open("#{Rails.root}/tmp/chord_data/#{pi.uuid}.json", 'w') { |file| file.write(coauthors.as_json) }
  end

  def get_coauthor_array(uuid)
    filename = "#{Rails.root}/tmp/coauthors/#{uuid}.json"
    file = File.read(filename)
    data = JSON.parse(file)
    data["results"]["bindings"]
  end

  def imports(coauthor_array)
    imports = []
    coauthor_array.each { |c| imports << c["Coauthor_name"]["value"] }
    imports
  end

  def pub_count(pi_uuid)
    filename = "#{Rails.root}/tmp/publication_counts/#{pi_uuid}.json"
    file = File.read(filename)
    data = JSON.parse(file)
    data["results"]["bindings"].first['cnt']['value']    
  end

end
