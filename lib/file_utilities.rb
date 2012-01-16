# -*- ruby -*-

require 'fastercsv'
require 'utilities'
require 'journal_utilities'
require 'award_utilities'
require 'investigator_appointment_utilities'
require 'investigator_abstract_utilities'
require 'organization_utilities'


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
  
def read_data_handler(model_name, file_name, column_separator="\t")
  errors = ""
  data = FasterCSV.read(file_name, :col_sep => column_separator, :headers => :first_row)
  puts model_name.find(:all).length unless model_name.blank?
  yield(data)
  puts model_name.find(:all).length unless model_name.blank?
end


def ReadNetIDgenerateReport(file_name)
  puts   "username\tfirst_name\tmiddle_name\tlast_name\tdegrees\temail\temployee_id\ttitle\tposition\tdepartment\tbusiness_phone\taddress"
  read_data_handler(Investigator,file_name) {|data| row_iterator(data) {|data| GenerateNetIDReport(data)} }
end

def ReadNamesAndSplit(file_name)
  puts  "username\tfirst_name\tmiddle_name\tlast_name\tdegrees"
  read_data_handler("",file_name) {|data| row_iterator(data) {|data| DoReadNamesAndSplit(data)} }
end

def ReadInvestigatorData(file_name)
  read_data_handler(Investigator,file_name) {|data| row_iterator(data) {|data| CreateInvestigatorFromHash(data)} }
end

def ReadOrganizationData(file_name)
  read_data_handler(OrganizationalUnit,file_name) {|data| row_iterator(data) {|data| CreateOrganizationFromHash(data)} }
end

def ReadRootOrgData(file_name)
  read_data_handler(OrganizationalUnit,file_name) {|data| row_iterator(data) {|data| CreateSchoolDepartmentFromHash(data)} }
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
  novel_pubmed_ids = []
  read_data_handler(Abstract,file_name) { |data| 
    novel_pubmed_ids += CreateAbstractsFromArrayHash(data) 
  }
  # set novel_pubmed_ids to [] if you want to process every connection to look for new authors added to existing pubs
  #novel_pubmed_ids = []
  read_data_handler(InvestigatorAbstract,file_name) { |data|  
    row_iterator(data) {|data| CreateInvestigatorAbstractsFromHash(data, novel_pubmed_ids)} }
end

def ReadJournalImpactData(file_name)
  read_data_handler(Journal,file_name, ";") {|data| row_iterator(data) {|data| CreateJournalImpactFromHash(data)} }
end

def ReadJournalISOnamesData(file_name)
  read_data_handler(Journal,file_name, ";") {|data| row_iterator(data) {|data| UpdateJournalAbbreviation(data)} }
end

def ReadStudyData(file_name)
  read_data_handler(Study,file_name, ",") {|data| row_iterator(data) {|data| CreateStudyFromHash(data)} }
end

def ReadStudyInvestigatorData(file_name)
  read_data_handler(InvestigatorStudy,file_name, ",") {|data| row_iterator(data) {|data| CreateStudyInvestigatorFromHash(data)} }
end

def ReadAwardData(file_name)
  read_data_handler(Proposal,file_name) {|data| row_iterator(data) {|data| CreateAwardData(data)} }
end

def ReadUsers(file_name)
  read_data_handler(Investigator,file_name) {|data| row_iterator(data) {|data| ValidateUser(data)} }
end
