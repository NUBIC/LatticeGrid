require 'pubmed_config' #look here to change the default time spans
require 'file_utilities' #specific methods
require 'utilities' #specific methods

require 'rubygems'
require 'pathname'

def read_file_handler(taskname="taskname")
  if ENV["file"].nil?
    puts "couldn't find a file in the calling parameters. Please call as 'rake #{taskname} file=filewithpath'" 
  else
    block_timing(taskname) {
      puts "file: "+ENV["file"]
      ENV["file"].split(',').each do | filename |
        p1 = Pathname.new(filename) 
        if p1.file? then
          yield filename
        else
          puts "unable to open file #{filename}"
        end
      end
    }
  end
end
  
task :importOrganizations => :environment do
  read_file_handler("importOrganizations" ) {|filename| ReadOrganizationData(filename)}
end

task :importDepartments => :environment do
  read_file_handler("importDepartments" ) {|filename| ReadSchoolDepartmentData(filename)}
end

task :cleanUpOrganizations => :environment do
  CleanUpOrganizationData()
end
task :importInvestigators => :environment do
  read_file_handler("importInvestigators" ) {|filename| ReadInvestigatorData(filename)}
end

task :importJointAppointments => :environment do
  read_file_handler("importJointAppointments" ) {|filename| ReadJointAppointmentData(filename)}
end

task :importSecondaryAppointments => :environment do
  read_file_handler("importSecondaryAppointments" ) {|filename| ReadSecondaryAppointmentData(filename)}
end

task :importCenterMemberships => :environment do
  read_file_handler("importCenterMemberships" ) {|filename| ReadCenterMembershipData(filename)}
end

task :importInvestigatorPubmedIDs => :environment do
  read_file_handler("importInvestigatorPubmedIDs" ) {|filename| ReadInvestigatorPubmedData(filename)}
end

task :importProgramMembership => :getInvestigators do
  read_file_handler("importProgramMembership" ) {|filename| ReadProgramMembershipData(filename)}
  prune_investigators_without_programs(@AllInvestigators)
  prune_program_memberships_not_updated()
end

task :importInvestigatorDescriptions => :getInvestigators do
  read_file_handler("importInvestigatorDescriptions" ) {|filename| ReadInvestigatorDescriptionData(filename)}
end

task :buildProgramsFromInvestigators => [:getInvestigators,:getPrimaryAppointments,:getAllOrganizationsWithInvestigators] do
  block_timing("buildProgramsFromInvestigators") {
    puts "number of investigatorPrograms = #{InvestigatorProgram.find(:all).length}"
    CreateProgramsFromDepartments(@AllPrimaryAppointments)
    InsertInvestigatorProgramsFromDepartments(@AllInvestigators)
    puts "number of investigatorPrograms = #{InvestigatorProgram.find(:all).length}"
  }
end

task :cleanInvestigatorsUsername => :environment do
   block_timing("cleanInvestigatorsUsername") {
     doCleanInvestigators(Investigator.find(:all, :conditions => "username like '%.%'"))
     doCleanInvestigators(Investigator.find(:all, :conditions => "username like '%(%'"))
   }
end

task :purgeOldMemberships => :environment do
   block_timing("purgeOldMemberships") {
      prune_program_memberships_not_updated()
   }
end

task :purgeNonMembers => :getAllInvestigatorsWithoutMembership do
   block_timing("purgeNonMembers") {
     purgeInvestigators(@InvestigatorsWithoutMembership)
   }
end

task :importAwardData => :getInvestigators do
  read_file_handler("importAwardData" ) {|filename| ReadAwardData(filename)}
end

task :validateUsers => :environment do
  read_file_handler("ValidateUsers" ) {|filename| ReadUsers(filename)}
end

