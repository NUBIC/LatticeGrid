# -*- ruby -*-

require 'fastercsv'
require 'utilities'
require 'journal_utilities'
require 'award_utilities'
require 'investigator_appointment_utilities'
require 'investigator_abstract_utilities'
require 'organization_utilities'

def read_data_handler(model_name, file_name, column_separator="\t")
  errors = ""
  data = FasterCSV.read(file_name, :col_sep => column_separator, :headers => :first_row)
  puts model_name.find(:all).length
  yield(data)
  puts model_name.find(:all).length
end

def ReadInvestigatorData(file_name)
  read_data_handler(Investigator,file_name) {|data| row_iterator(data) {|data| CreateInvestigatorFromHash(data)} }
end

def ReadOrganizationData(file_name)
  read_data_handler(OrganizationalUnit,file_name) {|data| row_iterator(data) {|data| CreateOrganizationFromHash(data)} }
end

def ReadSchoolDepartmentData(file_name)
  read_data_handler(OrganizationalUnit,file_name) {|data| row_iterator(data) {|data| CreateSchoolDepartmentFromHash(data)} }
end

def ReadJointAppointmentData(file_name)
  read_data_handler(InvestigatorAppointment,file_name) {|data| row_iterator(data) {|data| CreateJointAppointmentsFromHash(data)} }
end

def ReadSecondaryAppointmentData(file_name)
  read_data_handler(InvestigatorAppointment,file_name) {|data| row_iterator(data) {|data| CreateSecondaryAppointmentsFromHash(data)} }
end

def ReadCenterMembershipData(file_name)
  read_data_handler(InvestigatorAppointment,file_name) {|data| row_iterator(data) {|data| CreateCenterMembershipsFromHash(data)} }
end

def ReadProgramMembershipData(file_name)
  read_data_handler(InvestigatorAppointment,file_name) {|data| row_iterator(data) {|data| CreateProgramMembershipsFromHash(data, 'Member')} }
end

def ReadInvestigatorDescriptionData(file_name)
  read_data_handler(Investigator,file_name) {|data| row_iterator(data) {|data| MergeInvestigatorDescriptionsFromHash(data)} }
end

def ReadInvestigatorPubmedData(file_name)
  read_data_handler(Abstract,file_name) { |data| 
    CreateAbstractsFromArrayHash(data) 
  }
  read_data_handler(InvestigatorAbstract,file_name) { |data|  row_iterator(data) {|data| CreateInvestigatorAbstractsFromHash(data)} }
end

def ReadJournalImpactData(file_name)
  read_data_handler(Journal,file_name, ";") {|data| row_iterator(data) {|data| CreateJournalImpactFromHash(data)} }
end

def ReadJournalISOnamesData(file_name)
  read_data_handler(Journal,file_name, ";") {|data| row_iterator(data) {|data| UpdateJournalAbbreviation(data)} }
end

def ReadAwardData(file_name)
  read_data_handler(Proposal,file_name) {|data| row_iterator(data) {|data| CreateAwardData(data)} }
end

def ReadUsers(file_name)
  read_data_handler(Investigator,file_name) {|data| row_iterator(data) {|data| ValidateUser(data)} }
end
