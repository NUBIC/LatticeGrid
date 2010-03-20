# to enable truncate
require "#{RAILS_ROOT}/app/helpers/application_helper"
include ApplicationHelper

def CurrentAwards()
  awards = Proposal.all
end


def CreateAwardData(data_row)
  # assumed header values
  # OSR Approval Date
  # Institution Number
  # Sponsored Award Number
  # Proposal Title
  # Investigator Role
  # Employee ID
  # Last Name
  # First Name
  # Middle Initial
  # Project Award Start Date
  # Project Award End Date
  # Sponsor Code
  # Sponsor Name
  # Program Type
  # Proposal Type
  # Instrument Type
	
  # get smarter to pull out impact factor year. Right now it is encoded in the ISI file in the heading Total_Cites as '{year} Total Cites'
  employee_id = data_row['Employee ID']
  role = data_row['Investigator Role']
  investigator = Investigator.find_by_employee_id(employee_id)
  if investigator
    proposal = CreateProposalRecord(data_row)
    investigator_proposal = InvestigatorProposal.find(:all, :conditions => ["investigator_id = :investigator_id and proposal_id = :proposal_id",
       {:investigator_id => investigator.id, :proposal_id => proposal.id}])
    if investigator_proposal.blank? && ! proposal.id.blank? then
      InvestigatorProposal.create(:investigator_id => investigator.id, :proposal_id => proposal.id, :role=>role)
    end
  end
end

def CreateProposalRecord(data_row)
  j = Proposal.new
  j.institution_award_number =  data_row['Institution Number'].gsub(/[ -].*/, "")
  j.sponsor_award_number =  data_row['Sponsored Award Number']
  j.sponsor_code = data_row['Sponsor Code']
  j.sponsor_name = data_row["Sponsor Name"]
  j.title = truncate_words(data_row['Proposal Title'], 220)
  j.project_start_date = data_row['Project Award Start Date']
  j.project_end_date = data_row['Project Award End Date']
  j.award_category = data_row["Program Type"]
  j.award_type = data_row['Instrument Type']

  existing_award = Proposal.find_by_institution_award_number(j.institution_award_number)
  if existing_award.blank? && ! j.institution_award_number.blank? then
    j.save
    existing_award = j
  end
  existing_award
end
