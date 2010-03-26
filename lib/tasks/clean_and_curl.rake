require 'utilities'
require 'config'
require 'graphviz_config'
#require 'pathname'

# rake cache:clear 


# curl -s http://latticegrid.cancer.northwestern.edu/abstracts/list/2010/1 -o index.html

namespace :cache do
  task :clear => :environment do
    block_timing("cache:clear") {
    if File.directory?(public_path) then
        directories= %w{graphs abstracts investigators programs orgs member_nodes org_nodes copublications graphviz}
      directories.each do |name|
        name="#{public_path}/#{name}"
        if File.directory?(name) then
          puts "running 'rm -r #{name}'"
          system("rm -r #{name}")
        end
      end
        files = %w{programs.html orgs.html}
      files.each do |name|
        name="#{public_path}/#{name}"
        if File.exist?(name) then
          puts "running 'rm #{name}'"
          system("rm #{name}")
        end
      end
    end
    }
  end

  def public_path
    "#{File.expand_path(RAILS_ROOT)}/public"
  end

  def root_path
    "#{File.expand_path(RAILS_ROOT)}"
  end

  def handle_year (year=nil)
    @starting_year=Time.now.year
    @year_array = (@starting_year-8 .. @starting_year).to_a
    @year_array.reverse!
    @year = @starting_year.to_s
    if !year.blank? then
      @year = year
    end
    @year
  end

  task :setup_url_for => :environment do
    include ActionController::UrlWriter
    # just hard coding for now
    host = curl_host
    default_url_options[:host] = host
  end

  def run_curl(the_url)
    my_command = "curl -s #{the_url} -o #{root_path}/index.html"
    puts my_command
    curl_result = system(my_command)
    if ! curl_result
      puts "rats. The command '#{my_command}' failed to execute"
    end
  end

  def run_ajax_curl(the_url)
    my_command = "curl -H 'Accept: text/javascript' -s #{the_url} -o #{root_path}/index.html"
    puts my_command
    curl_result = system(my_command)
    if ! curl_result
      puts "rats. The command '#{my_command}' failed to execute"
    end
  end

  def run_xml_curl(the_url)
    my_command = "curl -H 'Accept: application/xml' -s #{the_url} -o #{root_path}/index.html"
    puts my_command
    curl_result = system(my_command)
    if ! curl_result
      puts "rats. The command '#{my_command}' failed to execute"
    end
  end


  def abstracts
    year = handle_year()
    page = 1
    run_curl tag_cloud_abstracts_url
    run_ajax_curl tag_cloud_by_year_abstract_url(:id => year)
    run_curl full_year_list_abstract_url(:id => year)
    abstracts = Abstract.display_data( year, page )
    total_entries = abstracts.total_entries
    total_pages   = abstracts.total_pages
    (1..total_pages).to_a.each do |page|
      run_curl abstracts_by_year_url(:id => year, :page => page) 
      #run_curl url_for :controller => 'abstracts', :action => 'year_list', :id => year, :page => page
    end
  end

  def investigators
    @AllInvestigators.each do |inv|
      run_curl full_show_investigator_url(:id => inv.username)
      run_ajax_curl tag_cloud_side_investigator_url(:id => inv.id)
      run_ajax_curl tag_cloud_investigator_url(:id => inv.id)
      run_curl show_investigator_url(:id => inv.username, :page => 1)
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
    params = set_graphviz_defaults({})
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
     params[:analysis] = "org_mesh"
     params[:stringency] = "2000"
     run_curl build_graphviz_restfulpath(params, params[:format]) 
    end
  end

  task :populate => [:setup_url_for,:getInvestigators, :getAllOrganizations] do
    tasknames = %w{abstracts investigators orgs investigator_graphs org_graphs investigator_graphviz org_graphviz}
    if ENV["taskname"].nil?
      puts "sorry. You need to call 'rake cache:populate taskname=task' where task is one of #{tasknames.join(', ')}"
    else
      taskname = ENV["taskname"]
      block_timing("cache:populate taskname=#{taskname}") {
      case 
        when taskname == 'abstracts': abstracts
        when taskname == 'investigators': investigators
        when taskname == 'orgs': orgs
        when taskname == 'investigator_graphs': investigator_graphs
        when taskname == 'investigator_graphviz': investigator_graphviz
        when taskname == 'org_graphs': org_graphs
        when taskname == 'org_graphviz': org_graphviz
        else puts "sorry - unknown caching task #{taskname}."
      end    
      }
    end
  end
end
