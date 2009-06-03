require 'pubmed_config' #look here to change the default time spans
require 'file_utilities' #specific methods

require 'rubygems'
require 'pathname'

task :importInvestigators => :environment do
   if ENV["file"].nil?
     puts "couldn't find a file in the calling parameters. Please call as 'rake importInvestigators file=filewithpath'" 
   else
     start = Time.now
     puts "file: "+ENV["file"]
     ENV["file"].split(',').each do | filename |
       p1 = Pathname.new(filename) 
       if p1.file? then
         ReadInvestigatorData(filename)
       else
         puts "unable to open file #{filename}"
       end
     end
     stop = Time.now
     elapsed_seconds = stop.to_f - start.to_f
     puts "importInvestigators run in #{elapsed_seconds} seconds" if @verbose
   end
end

task :buildProgramsFromInvestigators => [:getInvestigators,:getDepartments,:getDepartmentsAndDivisions] do
  start = Time.now
  puts "number of investigatorPrograms = #{InvestigatorProgram.find(:all).length}"
  CreateProgramsFromDepartments(@AllDepartments)
  InsertInvestigatorProgramsFromDepartments(@AllInvestigators)
  puts "number of investigatorPrograms = #{InvestigatorProgram.find(:all).length}"
  stop = Time.now
  elapsed_seconds = stop.to_f - start.to_f
  puts "buildProgramsFromInvestigators run in #{elapsed_seconds} seconds" if @verbose
end

task :cleanInvestigatorsUsername => :environment do
   start = Time.now
   stop = Time.now
   doCleanInvestigators(Investigator.find(:all, :conditions => "username like '%.%'"))
   elapsed_seconds = stop.to_f - start.to_f
   puts "cleanInvestigatorsUsername run in #{elapsed_seconds} seconds" if @verbose
end
