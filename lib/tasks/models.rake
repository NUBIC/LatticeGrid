require 'pubmed_config' #look here to change the default time spans

require 'rubygems'

task :setAllYears => :environment do
  @publication_years = @all_years
end

task :getInvestigators => :environment do
  # load all investigators
  # @AllInvestigators = Investigator.find(:all,  :conditions => ['end_date is null or end_date >= :now', {:now => Date.today }])
  @AllInvestigators = Investigator.find(:all, :order => 'id', :include => ["abstracts"])
  
#  @AllInvestigators = Investigator.find(:all, :conditions => "id=1")
  puts "count of all investigators is #{@AllInvestigators.length}" if @verbose
end

task :getMeshTags => :environment do
    @AllInvestigatorMeshTags = Tagging.find(:all, :joins => :tag, :select=> "distinct information_content, tag_id, tags.name", :conditions=>"taggable_type='Investigator'")
    puts "count of all investigator MeSH tags is #{@AllInvestigatorMeshTags.length}" if @verbose
    @AllAbstractMeshTags = Tagging.find(:all, :joins => :tag, :select=> "distinct information_content, tag_id, tags.name", :conditions=>"taggable_type='Abstract'")
    puts "count of all abstract MeSH tags is #{@AllAbstractMeshTags.length}" if @verbose
end

task :getDepartments => :environment do
  # load distinct Departments from Investigators
  @AllDepartments = Investigator.distinct_departments()
  
  puts "count of all departments is #{@AllDepartments.length}" if @verbose
end

task :getDepartmentsAndDivisions => :environment do
  # load distinct Departments from Investigators
  @AllDepartmentsAndDivisions = Investigator.distinct_departments_with_divisions()
  
  puts "count of all departments and divisions is #{@AllDepartmentsAndDivisions.length}" if @verbose
end

task :getAbstracts => :environment do
  # load all abstracts
  @AllAbstracts = Abstract.find(:all, :order => 'id', :include => ["investigator_abstracts","investigators"])
  puts "count of all abstracts is #{@AllAbstracts.length}" if @verbose
  if @verbose then
    investigator_abstracts_length = @AllAbstracts.collect{|x| x.investigator_abstracts.length }.sum
    puts "count of all investigator_abstracts is #{investigator_abstracts_length}"
  end
end

task :getTags => :environment do
  # load all tags
  @AllTags = Tag.find(:all)
  puts "count of all tags is #{@AllTags.length}" if @verbose
end

task :getPrograms => :environment do
  # load all abstracts for each program
  @Programs = Program.find(:all, :order => 'program_number, id')
  puts "count of all Programs is #{@Programs.length}" if @verbose
end

task :getProgramAbstracts => :getPrograms do
  # load all abstracts for each program
  @ProgramAbstracts = @Programs
  total=0
  @ProgramAbstracts.each do |program|
      program.abstracts = Abstract.get_all_program_data(  program.id )
      puts "count of Abstracts for program #{program.program_title} is #{program.abstracts.length}" if @verbose
      total += program.abstracts.length
   end
   puts "count of all ProgramAbstracts is #{total}" if @verbose
   puts "count of Abstracts for program #{@ProgramAbstracts[0].program_title} is #{@ProgramAbstracts[0].abstracts.length}" if @verbose
end

task :updateProgramAbstractInformation => [:getProgramAbstracts] do
  # load the test data
  start = Time.now
  @ProgramAbstracts.each do |program|
    program.abstracts.each do |abstract|
      UpdateProgramWithAbstract (program.id,abstract.id)
    end
  end
  stop = Time.now
  elapsed_seconds = stop.to_f - start.to_f
  puts "task updateProgramAbstractInformation ran in #{elapsed_seconds} seconds" if @verbose
end

