#require 'pathname'

# rake cache:clear 


# curl -s http://pubs.cancer.northwestern.edu/abstracts/list/2009/1 -o index.html

namespace :cache do
  task :clear => :environment do
    start = Time.now
    if File.directory?(public_path) then
      directories= %w{graphs abstracts investigators programs member_nodes program_nodes}
      directories.each do |name|
        name="#{public_path}/#{name}"
        if File.directory?(name) then
          puts "running 'rm -r #{name}'"
          system("rm -r #{name}")
        end
      end
      files = %w{programs.html}
      files.each do |name|
        name="#{public_path}/#{name}"
        if File.exist?(name) then
          puts "running 'rm #{name}'"
          system("rm #{name}")
        end
      end
    end
    stop = Time.now
    elapsed_seconds = stop.to_f - start.to_f
    puts "clean ran in #{elapsed_seconds} seconds"
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
    my_env = RAILS_ENV
    my_env = 'home' if public_path =~ /Users/ 
    host = case 
      when my_env == 'home': 'localhost:3000'
      when my_env == 'development': 'rails-dev.bioinformatics.northwestern.edu'
      when my_env == 'production': 'pubs.cancer.northwestern.edu'
      else 'rails-dev.bioinformatics.northwestern.edu'
    end 
    default_url_options[:host] = host
  end

  def run_curl(the_url)
    my_command = "curl -s #{the_url} -o #{root_path}/index.html"
    puts my_command
    system(my_command)
  end

  def abstracts
    year = handle_year()
    page = 1
    run_curl tag_cloud_abstracts_url
    abstracts = Abstract.display_data( year, page )
    total_entries = abstracts.total_entries
    total_pages   = abstracts.total_pages
    (1..total_pages).to_a.each do |page|
      run_curl year_list_abstract_url(:id => year, :page => page) 
      #url_for :controller => 'abstracts', :action => 'year_list', :id => year, :page => page
    end
  end

  def investigators
    @AllInvestigators.each do |inv|
      run_curl investigator_url(:id => inv.username, :page => 1)
      #run_curl url_for :controller => 'investigators', :action => 'show', :id => inv.username, :page => 1
    end
  end

  def programs
    # master page
    run_curl programs_url
    # program stats page
    run_curl program_stats_programs_url
    @Programs.each do |prog|
      run_curl show_investigators_program_url(prog.id)
      run_curl show_program_program_url(:id => prog.id, :page => 1)
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

  def program_graphs
    @Programs.each do |prog|
       #run_curl url_for :controller => 'graphs', :action => 'show_program', :id => prog.id
       run_curl show_program_graph_url(prog.id)
       run_curl program_nodes_url(prog.id)
    end
  end

  task :populate => [:setup_url_for,:getInvestigators, :getPrograms] do
    start = Time.now
    tasknames = %w{abstracts investigators programs investigator_graphs program_graphs}
    if ENV["taskname"].nil?
      puts "sorry. You need to call 'rake cache:populate taskname=task' where task is one of #{tasknames.join(', ')}"
    else
      taskname = ENV["taskname"]
      case 
        when taskname == 'abstracts': abstracts
        when taskname == 'investigators': investigators
        when taskname == 'programs': programs
        when taskname == 'investigator_graphs': investigator_graphs
        when taskname == 'program_graphs': program_graphs
        else puts "sorry - unknown caching task #{taskname}."
      end    
    end
      
    stop = Time.now
    elapsed_seconds = stop.to_f - start.to_f
    puts "populate_cache cache=#{taskname} ran in #{elapsed_seconds} seconds"
  end
end
