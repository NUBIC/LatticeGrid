##
# Tasks to call the VIVO SPARQL API to get data 
# which is then massaged into a format used by the 
# views rendered by the VivoController
namespace :vivo do

  ## 
  # Create the files for the pi and coauthors 
  # and save them in the tmp/vivo/coauthors directory
  task :coauthors => :environment do 
    # This is the only thing LatticeGrid related - and it's just a quick way to get the uuid for the pi in question
    # But really we can and should get all the URIs for the vivo:FacultyMembers
    pi = Investigator.find_all_by_username('wakibbe').first

    run_vivo_curl(pi.uuid)
    filename = "#{Rails.root}/tmp/vivo/coauthors/#{pi.uuid}.json"
    file = File.read(filename)
    data = JSON.parse(file)
    coauthor_array = data["results"]["bindings"]

    # run_vivo_curl for each coauthor
    coauthor_array.each do |coauthor|
      # We do need to know what we are getting back from the coauthor_sparql query below
      uri = coauthor["Coauthor"]["value"]
      run_vivo_curl(uuid_from_uri(uri))
    end
  end

  # Almost the same as above but get the publication count 
  # and save it into the tmp/vivo/publication_counts directory
  task :publication_count => :environment do 
    pi = Investigator.find_all_by_username('wakibbe').first
    run_publication_count_curl(pi.uuid)

    filename = "#{Rails.root}/tmp/vivo/coauthors/#{pi.uuid}.json"
    file = File.read(filename)
    data = JSON.parse(file)

    coauthor_array = data["results"]["bindings"]
    
    coauthor_array.each do |coauthor|
      uri = coauthor["Coauthor"]["value"]
      run_publication_count_curl(uuid_from_uri(uri))
    end
  end

  # Put the data we got from above into the format we want 
  # and save it into the tmp/vivo/chord_data directory
  task :chord_data => :environment do 
    pi = Investigator.find_all_by_username('wakibbe').first
    
    coauthor_array = get_coauthor_array(pi.uuid)
    pi_imports = imports(coauthor_array)

    coauthors = []
    coauthors << {name: pi.name, size: pub_count(pi.uuid), imports: pi_imports}
    coauthor_array.each do |coauthor|
      uri  = coauthor["Coauthor"]["value"]
      name = coauthor["Coauthor_name"]["value"]
      co_uuid = uuid_from_uri(uri)
      pub_cnt = pub_count(co_uuid)
      coauthor_array = get_coauthor_array(co_uuid)      
      co_imports = imports(coauthor_array)

      coauthors << {name: name, size: pub_cnt, imports: (pi_imports & co_imports)}
    end
    File.open("#{Rails.root}/tmp/vivo/chord_data/#{pi.uuid}.json", 'w') { |file| file.write(coauthors.as_json) }
  end


  # Run the curl command we learned from Jim and the wiki to make a call to vivo/api/sparqlQuery
  # and output it to a file in the tmp/coauthors directory
  def run_vivo_curl(uuid)
    File.open('coauthor.sparql', 'w') { |file| file.write(coauthor_sparql(vivo_uri(uuid))) }
    %x( curl -d 'email=vivo_root@northwestern.edu' -d 'password=13#vivo#' -d '@coauthor.sparql' -H 'Accept: application/sparql-results+json' 'http://localhost:8080/vivo/api/sparqlQuery' > tmp/coauthors/#{uuid}.json )    
  end

  def rdf_prefices
"PREFIX rdf:     <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs:     <http://www.w3.org/2000/01/rdf-schema#>
PREFIX vitro:    <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
PREFIX bibo:     <http://purl.org/ontology/bibo/>
PREFIX foaf:     <http://xmlns.com/foaf/0.1/>
PREFIX vcard:    <http://www.w3.org/2006/vcard/ns#>
PREFIX vivo:     <http://vivoweb.org/ontology/core#>"
  end

  ##
  # SPARQL query to get the Coauthor URI, Coauthor Name, and PI Name 
  def coauthor_sparql(uri)
"query=#{rdf_prefices} SELECT distinct ?Coauthor ?Coauthor_name ?PI_name 
WHERE{
?Authorship1 rdf:type vivo:Authorship .
?Authorship1 vivo:relates <#{uri}> .
?Authorship1 vivo:relates ?Document1 .
?Document1 rdf:type bibo:Document .
?Document1 vivo:relatedBy ?Authorship2 .
?Authorship2 rdf:type vivo:Authorship .
?Coauthor rdf:type vivo:FacultyMember .
?Coauthor vivo:relatedBy ?Authorship2 .
?Coauthor rdfs:label ?Coauthor_name .
<#{uri}> rdfs:label ?PI_name .
FILTER (!(?Authorship1=?Authorship2))
}"
  end

  ##
  # Strip the vivo_namespace from the given uri param
  def uuid_from_uri(uri)
    uri.gsub(vivo_namespace, '')
  end

  ##
  # Set this to your namespace
  def vivo_namespace
    'http://vivo.northwestern.edu/individual/'
  end

  ##
  # The uri for this investigator record in VIVO
  def vivo_uri(uuid)
    "#{vivo_namespace}#{uuid}"
  end


  def run_publication_count_curl(uuid)
    File.open('publication_count.sparql', 'w') { |file| file.write(pi.publication_count_sparql(vivo_uri(uuid))) }
    %x( curl -d 'email=vivo_root@northwestern.edu' -d 'password=13#vivo#' -d '@publication_count.sparql' -H 'Accept: application/sparql-results+json' 'http://localhost:8080/vivo/api/sparqlQuery' > tmp/publication_counts/#{uuid}.json )
  end

  ##
  # Get the number of publications for this person in VIVO
  def publication_count_sparql(uri)
    uri = vivo_uri if uri.blank?
"query=#{rdf_prefices} SELECT (count(?Authorship1) as ?cnt)
WHERE{
?Authorship1 rdf:type vivo:Authorship .
?Authorship1 vivo:relates <#{uri}>
}"
  end

  ## 
  # Read the data from the coauthors file
  def get_coauthor_array(uuid)
    filename = "#{Rails.root}/tmp/vivo/coauthors/#{uuid}.json"
    file = File.read(filename)
    data = JSON.parse(file)
    data["results"]["bindings"]
  end

  ##
  # Create an array of coauthor name
  def imports(coauthor_array)
    imports = []
    coauthor_array.each { |c| imports << c["Coauthor_name"]["value"] }
    imports
  end

  ## 
  # Read the data from the publication_counts file
  def pub_count(pi_uuid)
    filename = "#{Rails.root}/tmp/vivo/publication_counts/#{pi_uuid}.json"
    file = File.read(filename)
    data = JSON.parse(file)
    data["results"]["bindings"].first['cnt']['value']    
  end

end
