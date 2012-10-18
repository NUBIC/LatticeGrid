# to enable truncate
require "#{RAILS_ROOT}/app/helpers/application_helper"
include ApplicationHelper
require 'text_utilities'

def CurrentAwards()
  awards = Proposal.all
end

# current list of roles:
# Co-Investigator =>  ["Co-Investiogator", "Co-I", "Co-Investigator", "co-Investigator", "Co-Inv", "CO-I", "co-investigator", "Co-Investiagtor", "Co-Investitagor", "co-inv","co-investiagtor", "Co-investigator", "Co-Investiagator", "Co-Investgatior", "co-investogator", "Co_I", "Co-PD/PI" ]
# PD/PI => [ "Principal Investigator", "PD/PI", "Director", "Co-Program Director", "Co-Director", "Investigator", "investigator", "Contact P. I."]
# Fellow => [ "Fellow", "postdoc fellow", "Post Doctoral"]
# Biostatistician => [ "Statistician", "statistician", "Statistician", "Statician", "Biostatician", "Biostatisation", "Data Mgmt.", "Analyst"]
# Faculty => [ "Faculty", "Asst. Professor", "Co-Mentor", "Mentor", "collabor", "Collaborateor", "Collaborator", "collaborator" ]
# Other => [ "Other", "O.S.P", "Advisory Board Member", "Co-Sponsor", "Program Administrator","Pharmacologist", "Other Professional", "RAP"]
# Other => [nil, , , "R.D.", "Technician", "medical monitor"] 

def compressRoles(role)
  return 'Other' if role.blank?
  case role.downcase
    when /co-i|co_i|co-pd/
      'Co-Investigator'
    when /principal|pd\/pi|contact p|investigator|director/
      'PD/PI'
    when /fellow|post/
      'Fellow'
    when /stat|data m|analyst/
      'Biostatistician'
    when /pharm|other|o\.s\.p|advisor|sponso|rap|admin/
      'Other'
    when /faculty|prof|mentor|collabor/
      'Faculty'
    else
      'Other'
  end
end

def clean_date(the_date)
  return nil if the_date.blank?
  begin
    the_date = the_date.to_date if the_date.class.to_s != /date|time/i
  rescue 
    begin
      #assume US 
      the_date = Date.strptime(the_date, "%m/%d/%Y")
    rescue Exception => err
      puts "error converting #{the_date} to a date. Class: #{the_date.class.to_s} Error: #{err.message}"
      the_date = the_date.to_date
    end
  end
  return the_date + 2000.years if the_date < '01/01/0070'.to_date
  return the_date + 1900.years if the_date < '01/01/0100'.to_date
  return the_date
end


def CreateAwardData(data_row)
# from InfoEd through Cognos

  #about the investigator
  #INVESTIGATOR_ROLE
  #NU_EMPLOYEE_ID
  #PI_EMPLOYEE_ID
  #TOTAL_EFFORT
  #IS_MAIN_PI

  # about the award
  #AWARD_BEGIN_DATE
  #AWARD_END_DATE
  #PROJECT_BEGIN_DATE
  #PROJECT_END_DATE
  #DIRECT_AMOUNT
  #INDIRECT_AMOUNT
  #INST_NUM

  #ORIG_SPONSOR_CODE_L3
  #ORIG_SPONSOR_NAME_L3
  #PROPOSAL_STATUS
  #PROPOSAL_TITLE
  #SPONSOR_CODE_L1
  #SPONSOR_CODE_L2
  #SPONSOR_CODE_L3
  #SPONSOR_NAME_L1
  #SPONSOR_NAME_L2
  #SPONSOR_NAME_L3
  #SPONSOR_TYPE_DESC_L1
  #SPONSOR_TYPE_L1
  #TOTAL_AMOUNT

  # not used
  #FIRST_NAME
  #MIDDLE_NAME
  #LAST_NAME


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
	
  @not_found_employees = [] if @not_found_employees.blank?
  @not_found_employee_messages = [] if @not_found_employee_messages.blank?
  
  employee_id = data_row['Employee ID'] || data_row['NU_EMPLOYEE_ID']
  role = data_row['Investigator Role'] || data_row['INVESTIGATOR_ROLE']
  role = compressRoles(role)
  first_name = data_row['First Name'] || data_row['FIRST_NAME']
  last_name  = data_row['Last Name'] || data_row['LAST_NAME']
  is_main_pi  = data_row['IS_MAIN_PI'] || false
  if is_main_pi != true and is_main_pi != false
    if is_main_pi.to_i > 0
      is_main_pi  = true 
    else
      is_main_pi = false
    end
  end
  investigator_effort  = data_row['TOTAL_EFFORT']
  investigator_effort  = 0 if investigator_effort.blank?
  investigator = Investigator.find_by_employee_id(employee_id) if not (last_name =~ /conversion/i)
  if investigator
    proposal = CreateProposalRecord(data_row)
    if ! proposal.blank? and !proposal.id.blank?
      investigator_proposal = InvestigatorProposal.find(:first, :conditions => ["investigator_id = :investigator_id and proposal_id = :proposal_id",
         {:investigator_id => investigator.id, :proposal_id => proposal.id}])
      if investigator_proposal.blank?  then
        InvestigatorProposal.create(:investigator_id => investigator.id, :proposal_id => proposal.id, :role=>role, :percent_effort => investigator_effort, :is_main_pi => is_main_pi)
      elsif investigator_proposal.percent_effort != investigator_effort
        investigator_proposal.percent_effort = investigator_effort
        investigator_proposal.save!
      end
    else
      puts "unable to create proposal for row #{data_row.inspect}"
    end
  elsif not @not_found_employees.include?(employee_id)
    @not_found_employees << employee_id
    @not_found_employee_messages << "unable to find investigator #{first_name} #{last_name} with NU employee_id #{employee_id}\t#{employee_id}"
    # puts "unable to find investigator #{first_name} #{last_name} with NU employee_id #{employee_id}\t#{employee_id}"
  end
end

def CreateProposalRecord(data_row)
  # about the award
  
  #AWARD_BEGIN_DATE
  #AWARD_END_DATE
  #PROJECT_BEGIN_DATE
  #PROJECT_END_DATE
  #DIRECT_AMOUNT
  #INDIRECT_AMOUNT
  #TOTAL_AMOUNT
  #INST_NUM
  #PARENT_INST_NUM
  #PI_EMPLOYEE_ID

  #ORIG_SPONSOR_CODE_L3
  #ORIG_SPONSOR_NAME_L3
  #PROPOSAL_STATUS
  #PROPOSAL_TITLE
  #SPONSOR_AWARD_NUMBER
  #SPONSOR_CODE_L1
  #SPONSOR_CODE_L2
  #SPONSOR_CODE_L3
  #SPONSOR_NAME_L1
  #SPONSOR_NAME_L2
  #SPONSOR_NAME_L3
  #SPONSOR_TYPE_DESC_L1
  #SPONSOR_TYPE_L1

  j = Proposal.new
  j.institution_award_number =  data_row['Institution Number'] || data_row['INST_NUM']
  j.institution_award_number =  j.institution_award_number.gsub(/[ -].*/, "") if !j.institution_award_number.blank?
  j.sponsor_award_number =  data_row['Sponsored Award Number'] || data_row['SPONSOR_AWARD_NUMBER']
  j.pi_employee_id =  data_row['PI_EMPLOYEE_ID']
  j.direct_amount =  data_row['DIRECT_AMOUNT']
  j.indirect_amount =  data_row['INDIRECT_AMOUNT']
  j.total_amount =  data_row['TOTAL_AMOUNT']
  j.sponsor_code = data_row['Sponsor Code'] || data_row['SPONSOR_CODE_L3']
  j.sponsor_name = data_row["Sponsor Name"] || data_row['SPONSOR_NAME_L3']
  j.sponsor_type_name = data_row['SPONSOR_TYPE_DESC_L1']
  j.sponsor_type_code = data_row['SPONSOR_TYPE_L1']
  j.original_sponsor_code = data_row['ORIG_SPONSOR_CODE_L3']
  j.original_sponsor_name = data_row['ORIG_SPONSOR_NAME_L3']
  if j.sponsor_name != j.original_sponsor_name
    j.sponsor_type_code = '' 
    j.sponsor_type_name = ''
  end
  # clean out the non-ASCII characters
  j.original_sponsor_name = CleanNonUTFtext(j.original_sponsor_name)
  j.sponsor_name = CleanNonUTFtext(j.sponsor_name)
  award_title = data_row['Proposal Title'] || data_row['PROPOSAL_TITLE'] || data_row['proposal_title']
  j.title = truncate_words(award_title, 220) unless award_title.blank?
  j.title = CleanNonUTFtext(j.title)
  
  project_start_date = data_row['Project Award Start Date'] || data_row['PROJECT_BEGIN_DATE']
  project_end_date = data_row['Project Award End Date'] || data_row['PROJECT_END_DATE']
  award_start_date = data_row['Project Award Start Date'] || data_row['AWARD_BEGIN_DATE']
  award_end_date = data_row['Project Award End Date'] || data_row['AWARD_END_DATE']

  
  j.project_start_date = clean_date(project_start_date)
  j.project_end_date = clean_date(project_end_date)
  j.award_start_date = clean_date(award_start_date)
  j.award_end_date = clean_date(award_end_date)
  
  unless project_start_date.blank?
    puts "project_start_date was not converted: #{project_start_date}" if j.project_start_date.blank?
  end
  if j.project_start_date.blank?
    puts "project_start_date was not set for row: #{data_row.inspect}"
  end
  
  j.award_category = data_row["Program Type"]
  j.award_type = data_row['Instrument Type']
  
  if j.institution_award_number.blank?
    puts "institutional award number was blank for row: #{data_row.inspect}"
    return nil
  end
  if j.title.blank?
    puts "award title was blank for row: #{data_row.inspect}"
    return nil
  end

  existing_award = Proposal.find_by_institution_award_number(j.institution_award_number)
  if existing_award.blank? && ! j.institution_award_number.blank? then
    j.save
    existing_award = j
    return existing_award
  end
  if existing_award.blank? or existing_award.id.blank?
    puts "existing_award was blank. Shouldn't happen. Data for row: #{data_row.inspect}"
    return nil  
  end
  if !j.title.blank? and existing_award.title != j.title 
    existing_award.title = j.title
    existing_award.save
  end
  if !j.project_start_date.blank? and existing_award.project_start_date != j.project_start_date 
    existing_award.project_start_date = j.project_start_date
    existing_award.save!
  end
  if !j.project_end_date.blank? and existing_award.project_end_date != j.project_end_date 
    existing_award.project_end_date = j.project_end_date
    existing_award.save
  end
  if !j.award_start_date.blank? and existing_award.award_start_date != j.award_start_date 
    existing_award.award_start_date = j.award_start_date
    existing_award.save
  end
  if !j.award_end_date.blank? and existing_award.award_end_date != j.award_end_date 
    existing_award.award_end_date = j.award_end_date
    existing_award.save
  end
  if !j.original_sponsor_name.blank? and  existing_award.original_sponsor_name != j.original_sponsor_name 
    existing_award.original_sponsor_name = j.original_sponsor_name 
    existing_award.save
  end
  if !j.sponsor_name.blank? and existing_award.sponsor_name != j.sponsor_name
    existing_award.sponsor_name = j.sponsor_name 
    existing_award.save
  end
  existing_award
end
