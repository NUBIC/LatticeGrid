##
# Tasks to call the VIVO SPARQL API to get data 
# which is then massaged into a format used by the 
# views rendered by the VivoController
namespace :vivo do

  ##
  # Set this to your instiution's namespace
  def vivo_namespace
    'http://vivo.northwestern.edu/individual/'
  end

  ##
  # The uri for this investigator record in VIVO
  # Anatomy of a URI in LatticeGrid (LG):
  # [the vivo namespace] + [uuid in LG table]
  #
  # This method will need to be updated for your institution
  def vivo_uri(uuid)
    "#{vivo_namespace}#{uuid}"
  end

  ##
  # Strip the vivo_namespace from the given uri param
  # to get the uuid from the string 
  # (which should match some record in LatticeGrid)
  def uuid_from_uri(uri)
    uri.gsub(vivo_namespace, '')
  end

  ##
  # An array of investigator unique identifiers and names
  # The uuids can be used to build the VIVO URI. 
  # Names are used when building the data used by the graphs.
  #
  # For simplicity sake we are using the LatticeGrid data 
  # and the Investigator model to get these items.
  #  
  # But really this is the same as the SPARQL Query
  #   SELECT distinct ?uri ?name 
  #   WHERE {
  #     ?uri rdf:type vivo:FacultyMember .
  #     ?uri rdfs:label ?name .
  #   } 
  #
  # because we are simply using the uuid to create the 
  # matching VIVO URI.
  # 
  # @see vivo_uri
  def pi_uuids_and_names
    Investigator.all.map{|i| [i.uuid, i.name]}
  end

  ## 
  # Create the files for the pi and coauthors 
  # and save them in the tmp/vivo/coauthors directory
  task :coauthors => :environment do 
    ## 
    # This is the only thing LatticeGrid related
    # But really we can and should get all the URIs for the vivo:FacultyMembers
    pi_uuids_and_names.each do |uuid, name|
      run_coauthor_curl(uuid)
      get_coauthor_array(uuid).each do |coauthor|
        # We do need to know what we are getting back from the coauthor_sparql query below
        run_coauthor_curl(uuid_from_uri(coauthor["Coauthor"]["value"]))
      end
    end
  end

  ##
  # Almost the same as above but get the publication count 
  # and save it into the tmp/vivo/publication_counts directory
  task :publication_count => :environment do 
    pi_uuids_and_names.each do |uuid, name|
      run_publication_count_curl(uuid)
      get_coauthor_array(uuid).each do |coauthor| 
        run_publication_count_curl(uuid_from_uri(coauthor["Coauthor"]["value"]))
      end
    end
  end

  ##
  # Put the data we got from above into the format we want 
  # and save it into the tmp/vivo/chord_data directory
  task :chord_data => :environment do 
    pi_uuids_and_names.each do |uuid, name|
      filename = "#{Rails.root}/tmp/vivo/chord_data/#{uuid}.json"
      next if File.exist?(filename)
      # Here we also would like the name of the 
      coauthors = build_chord_data_array(uuid, name)
      json = coauthors.as_json.to_s.gsub('=>', ':')
      File.open(filename, 'w') { |file| file.write(json) }
    end
  end

  def build_chord_data_array(uuid, pi_name)
    coauthors = []
    coauthor_array = get_coauthor_array(uuid)
    # put the pi in question as the first person in the coauthors array
    pi_imports = imports(coauthor_array)
    coauthors << {name: pi_name, size: pub_count(uuid), imports: pi_imports}
    # then build the same hash for each coauthor 
    coauthor_array.each do |coauthor|
      name = coauthor["Coauthor_name"]["value"]
      pub_cnt = pub_count(uuid_from_uri(coauthor["Coauthor"]["value"]))
      co_imports = get_coauthor_imports(coauthor["Coauthor"]["value"])
      coauthors << {name: name, size: pub_cnt, imports: (pi_imports & co_imports)}
    end
    coauthors
  end

  ##
  # RDF Prefices needed to run the SPARQL queries below
  # @see coauthor_sparql
  # @see publication_count_sparql
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
    WHERE {
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

  def word_sparql(uri)
    # SELECT ?publication ?title ?abstract
    # OPTIONAL { ?publication bibo:abstract ?abstract } .
    "query=#{rdf_prefices} 
SELECT ?publication ?title
WHERE
{
  ?authorship rdf:type vivo:Authorship .
  ?authorship vivo:relates <http://vivo.northwestern.edu/individual/e99c3c0e-2de2-4f46-994f-b5d45a09c39a> .
  ?publication rdf:type bibo:Document .
  ?publication vivo:relatedBy ?authorship .
  ?publication rdfs:label ?title .
}
"
  end

  ##
  # Get the number of publications for this person in VIVO
  def publication_count_sparql(uri)
    "query=#{rdf_prefices} SELECT (count(?Authorship1) as ?cnt)
    WHERE {
    ?Authorship1 rdf:type vivo:Authorship .
    ?Authorship1 vivo:relates <#{uri}>
    }"
  end

  # Run the curl command we learned from Jim and the wiki to make a call to vivo/api/sparqlQuery
  # and output it to a file in the tmp/coauthors directory
  def run_coauthor_curl(uuid)
    filename = "tmp/vivo/coauthors/#{uuid}.json"
    return if File.exist?(filename)    
    File.open('coauthor.sparql', 'w') { |file| file.write(coauthor_sparql(vivo_uri(uuid))) }
    %x( curl -d 'email=vivo_root@northwestern.edu' -d 'password=13#vivo#' -d '@coauthor.sparql' -H 'Accept: application/sparql-results+json' 'http://localhost:8080/vivo/api/sparqlQuery' > #{filename} )
  end


  def run_publication_count_curl(uuid)
    filename = "tmp/vivo/publication_counts/#{uuid}.json"
    return if File.exist?(filename)

    File.open('publication_count.sparql', 'w') { |file| file.write(publication_count_sparql(vivo_uri(uuid))) }
    %x( curl -d 'email=vivo_root@northwestern.edu' -d 'password=13#vivo#' -d '@publication_count.sparql' -H 'Accept: application/sparql-results+json' 'http://localhost:8080/vivo/api/sparqlQuery' > #{filename} )
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
  # Get the imports array for the given author
  def get_coauthor_imports(uri)
    co_uuid = uuid_from_uri(uri)
    coauthor_array = get_coauthor_array(co_uuid)
    imports(coauthor_array)
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
