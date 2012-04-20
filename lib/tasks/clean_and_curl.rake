require 'utilities'
require 'cache_utilities'
require 'config'
require 'graphviz_config'
#require 'pathname'

# rake cache:clear 

# curl -s http://latticegrid.cancer.northwestern.edu/abstracts/list/2010/1 -o index.html

namespace :cache do
  task :clear => :environment do
    block_timing("cache:clear") {
    if File.directory?(public_path) then
        directories= %w{graphs abstracts investigators programs orgs member_nodes org_nodes copublications graphviz mesh cytoscape member_cytoscape_data org_cytoscape_data investigators_search profiles investigators_search_all awards}
      directories.each do |name|
        clear_directory(name)
      end
      files = %w{programs.html orgs.html ccsg.html mesh.html mesh.json mesh.xml js.html xml.html json.html investigators_search.html test.html investigators_search_all.html high_impact.html}
      files.each do |name|
        name="#{name}"
        clear_file(name)
      end
    end
    }
  end

  task :setup_url_for => :environment do
    include ActionController::UrlWriter
    # just hard coding for now

    default_url_options[:host] = LatticeGridHelper.curl_host
    default_url_options[:protocol] = LatticeGridHelper.curl_protocol
  end

  def run_curl(the_url)
    my_command = "curl -s -k #{the_url} -o #{root_path}/index.html"
    puts my_command
    curl_result = system(my_command)
    if ! curl_result
      puts "rats. The command '#{my_command}' failed to execute"
    end
  end

  def run_ajax_curl(the_url)
    my_command = "curl -H 'Accept: text/javascript' -s -k #{the_url} -o #{root_path}/js.html"
    puts my_command
    curl_result = system(my_command)
    if ! curl_result
      puts "rats. The command '#{my_command}' failed to execute"
    end
  end
  
  def run_json_curl(the_url)
    my_command = "curl -H 'Accept: application/json' -s -k #{the_url} -o #{root_path}/json.html"
    puts my_command
    curl_result = system(my_command)
    if ! curl_result
      puts "rats. The command '#{my_command}' failed to execute"
    end
  end

  def run_xml_curl(the_url)
    my_command = "curl -H 'Accept: application/xml' -s -k #{the_url} -o #{root_path}/xml.html"
    puts my_command
    curl_result = system(my_command)
    if ! curl_result
      puts "rats. The command '#{my_command}' failed to execute"
    end
  end

  def do_abstracts_for_year(year)
    page = 1
    run_ajax_curl tag_cloud_by_year_abstract_url(:id => year)
    run_curl high_impact_by_month_abstracts_url()
    run_curl full_year_list_abstract_url(:id => year)
    abstracts = Abstract.display_data( year, page )
    total_entries = abstracts.total_entries
    total_pages   = abstracts.total_pages
    (1..total_pages).to_a.each do |abstract_page|
      run_curl abstracts_by_year_url(:id => year, :page => abstract_page) 
      #run_curl url_for :controller => 'abstracts', :action => 'year_list', :id => year, :page => abstract_page
    end
  end

  def abstracts
    year_array = LatticeGridHelper.year_array()
    run_curl tag_cloud_abstracts_url
    year_array.each do |year|
      do_abstracts_for_year(year.to_s)
    end
  end

  def investigators
    @AllInvestigators.each do |inv|
      run_curl full_show_investigator_url(:id => inv.username)
      run_ajax_curl tag_cloud_side_investigator_url(:id => inv.username)
      run_ajax_curl tag_cloud_investigator_url(:id => inv.username)
      run_curl publications_investigator_url(:id => inv.username)
      run_json_curl publications_investigator_url(:id => inv.username, :format => 'json')
      run_curl show_investigator_url(:id => inv.username, :page => 1)
      #run_curl url_for :controller => 'investigators', :action => 'show', :id => inv.username, :page => 1
    end
  end

  def mesh
    @AllTags.each do |mesh|
      run_curl tag_count_mesh_url(:id => mesh.name)
      run_curl tag_count_mesh_url(:id => mesh.id)
      run_json_curl tag_count_mesh_url(:id => mesh.name, :format => 'json')
      #run_xml_curl  tag_count_mesh_url(:id => mesh.name, :format => 'xml')
      run_curl investigators_mesh_url(:id => mesh.name)
      run_curl investigators_mesh_url(:id => mesh.id)
      run_json_curl investigators_mesh_url(:id => mesh.name, :format => 'json')
      #run_xml_curl  investigators_mesh_url(:id => mesh.name, :format => 'xml')
       #run_curl url_for :controller => 'investigators', :action => 'show', :id => inv.username, :page => 1
    end
  end

  def orgs
    # master page (index)
    run_curl orgs_url
    run_curl index_orgs_url
    run_curl centers_orgs_url
    run_curl programs_orgs_url
    run_curl departments_orgs_url
    # stats page
    run_curl stats_orgs_url
    @AllOrganizations.each do |org|
      run_curl show_investigators_org_url(org.id)
      run_curl url_for :controller => 'orgs', :action => 'show', :id => org.id, :page => 1
      run_curl full_show_org_url(:id => org.id)
      run_ajax_curl tag_cloud_org_url(:id => org.id)
      run_ajax_curl short_tag_cloud_org_url(:id => org.id)
      run_ajax_curl org_cytoscape_data_url(:id=>org.id, :depth=>1, :include_publications=>1, :include_awards=>0, :include_studies=>0)
    end
  end

  def investigator_graphs
    @AllInvestigators.each do |inv|
      run_curl show_member_graph_url( inv.username)  
      #url_for :controller => 'graphs', :action => 'show_member', :id => inv.username
      #run_curl url_for :controller => 'graphs', :action => 'member_nodes', :id => inv.username
      run_curl member_nodes_url(inv.username)
    
    end
  end

  def investigator_awards
    @AllInvestigators.each do |inv|
 #     run_curl awards_cytoscape_url( inv.username)  
      run_curl investigator_award_url(inv.username)
     end
  end

  def awards
    run_curl listing_awards_url
    @AllAwards.each do |award|
      run_curl award_url( award.id)  
     end
  end

  def investigator_studies
    @AllInvestigators.each do |inv|
#      run_curl studies_cytoscape_url( inv.username)  
      run_curl investigator_study_url(inv.username)
     end
  end

  def studies
    run_curl listing_studies_url
    @AllStudies=Study.all
    @AllStudies.each do |study|
      run_curl study_url( study.id)  
     end
  end

  def investigator_cytoscape
    @AllInvestigators.each do |inv|
      #study data
      run_ajax_curl member_cytoscape_data_url(:id=>inv.username, :depth=>1, :include_publications=>0, :include_awards=>0, :include_studies=>1)
      #award data
      run_ajax_curl member_cytoscape_data_url(:id=>inv.username, :depth=>1, :include_publications=>0, :include_awards=>1, :include_studies=>0)
      #publications data
      run_ajax_curl member_cytoscape_data_url(:id=>inv.username, :depth=>1, :include_publications=>1, :include_awards=>0, :include_studies=>0)
      run_ajax_curl member_cytoscape_data_url(:id=>inv.username, :depth=>2, :include_publications=>1, :include_awards=>0, :include_studies=>0)
      #all data
      run_ajax_curl member_cytoscape_data_url(:id=>inv.username, :depth=>1, :include_publications=>1, :include_awards=>1, :include_studies=>1)
      puts "generated cytoscape data for #{inv.name}: #{inv.username}"
      #break
     end
  end

  def investigator_graphviz
    params = set_graphviz_defaults({})
    params[:distance] = "1"
    @AllInvestigators.each do |inv|
      params[:id] =  inv.username
      params[:analysis] = "member"
      params[:stringency] = "1"
      run_curl build_graphviz_restfulpath(params, params[:format]) 
      params[:stringency] = "2"
      run_curl build_graphviz_restfulpath(params, params[:format]) 
      params[:stringency] = "3"
      run_curl build_graphviz_restfulpath(params, params[:format]) 
      params[:analysis] = "member_mesh"
      params[:stringency] = "2000"
      run_curl build_graphviz_restfulpath(params, params[:format]) 
    end
  end

  def org_graphs
    @AllOrganizations.each do |org|
       #run_curl url_for :controller => 'graphs', :action => 'show_org', :id => prog.id
       run_curl show_org_graph_url(org.id)
       run_curl org_nodes_url(org.id)
    end
  end

  def org_graphviz
    params={}
    params[:analysis] = "org"
    params = set_graphviz_defaults(params)
    params[:distance] = "1"
    @AllOrganizations.each do |org|
      params[:id] =  org.id
      params[:analysis] = "org"
      params[:stringency] = "1"
      run_curl build_graphviz_restfulpath(params, params[:format]) 
      params[:stringency] = "2"
      run_curl build_graphviz_restfulpath(params, params[:format]) 
      params[:stringency] = "3"
      run_curl build_graphviz_restfulpath(params, params[:format]) 
      params[:analysis] = "org_org"
      params[:stringency] = "1"
      params[:distance] = "0"
      run_curl build_graphviz_restfulpath(params, params[:format]) 
      params[:analysis] = "org_mesh"
      params[:stringency] = "2000"
      run_curl build_graphviz_restfulpath(params, params[:format]) 
    end
  end

  task :populate => [:setup_url_for,:getInvestigators, :getAllOrganizations, :getTags, :getAwards] do
    tasknames = %w{abstracts investigators orgs investigator_graphs org_graphs investigator_graphviz org_graphviz mesh investigator_awards awards investigator_studies studies investigator_cytoscape}
    if ENV["taskname"].nil?
      puts "sorry. You need to call 'rake cache:populate taskname=task' where task is one of #{tasknames.join(', ')}"
    else
      taskname = ENV["taskname"]
      block_timing("cache:populate taskname=#{taskname}") {
      case 
        when taskname == 'abstracts': abstracts
        when taskname == 'investigators': investigators
        when taskname == 'awards': awards
        when taskname == 'orgs': orgs
        when taskname == 'mesh': mesh
        when taskname == 'investigator_graphs': investigator_graphs
        when taskname == 'investigator_graphviz': investigator_graphviz
        when taskname == 'investigator_awards': investigator_awards
        when taskname == 'org_graphs': org_graphs
        when taskname == 'org_graphviz': org_graphviz
        when taskname == 'investigator_studies': investigator_studies
        when taskname == 'studies': studies
        when taskname == 'investigator_cytoscape': investigator_cytoscape
        else puts "sorry - unknown caching task #{taskname}."
      end    
      }
    end
  end
end
