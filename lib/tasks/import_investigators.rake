# -*- coding: utf-8 -*-
require 'pubmed_config'   # look here to change the default time spans
require 'file_utilities'  # specific methods
require 'utilities'       # specific methods

require 'rubygems'
require 'pathname'

task :importOrganizations => :environment do
  read_file_handler("importOrganizations" ) {|filename| ReadOrganizationData(filename)}
end

task :purgeUnupdatedOrganizations => :getAllOrganizationsNotUpdated do
  block_timing("purgeUnupdatedOrganizations") {
    deleteUnupdatedOrganizations(@all_organizationsNotUpdated)
  }
end

task :importRoot => :environment do
  read_file_handler("importRoot" ) {|filename| ReadRootOrgData(filename)}
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
  prune_investigators_without_programs(@all_investigators)
  prune_program_memberships_not_updated()
end

task :importInvestigatorDescriptions => :getInvestigators do
  read_file_handler("importInvestigatorDescriptions" ) {|filename| ReadInvestigatorDescriptionData(filename)}
end

task :validateUsers => :environment do
  read_file_handler("ValidateUsers" ) {|filename| ReadUsers(filename)}
end

