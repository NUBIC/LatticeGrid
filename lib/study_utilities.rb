require 'text_utilities'

def CurrentStudies()
  studies = Investigator.all.collect{|a| a.irb_study_number}.sort.uniq
end

def CreateStudyFromHash(data_row)
  # assumed header values
  # irb_number => irb_study_number
  
  # note if the following change
  # title => title
  # description => abstract
  # study_id  => enotis_study_id
  # research_type => research_type
  # review_type_requested => review_type
  # approved_date => approved_date

  # these may change
  # irb_status => status
  # closed_or_completed_date => closed_date
  # closed_or_completed_date => completed_date
  # expiration_date => next_review_date
  # fda_unapproved_agent
  # fda_offlabel_agent
  # accrual_goal => accrual_goal
  # expired_date
  # clinical_trial_submitter
  # created_date
  # is_a_clinical_investigation => is_clinical_trial
  # modified_date
  # periodic_review_open
  # total_subjects_at_all_ctrs
  # inclusion_criteria => inclusion_criteria
  # exclusion_criteria => exclusion_criteria
  # read_only
  # read_only_msg
  # uses_medical_services => has_medical_services
  # imported_at
  # import_errors => had_import_errors
  # import_cache
    	
  s = Study.new
  s.irb_study_number =  data_row['irb_number']
  s.title =  data_row['title']
  s.abstract =  data_row['description']
  # clean out the non-ASCII characters
  s.title = CleanNonUTFtext(s.title)
  s.abstract = CleanNonUTFtext(s.abstract)
  
  s.enotis_study_id =  data_row['study_id']
  s.research_type =  data_row['research_type']
  s.review_type =  data_row['review_type_requested']
  s.approved_date =  data_row['approved_date']
  
  if s.irb_study_number.blank?
    puts "irb_study_number was blank for this row: #{data_row.inspect}"
    return
  end
  existing_s = Study.find_by_irb_study_number(s.irb_study_number)
  if ! existing_s.blank? then
    complain_not_equal(s, existing_s, "title")
    complain_not_equal(s, existing_s, "abstract")
    complain_not_equal(s, existing_s, "enotis_study_id")
    complain_not_equal(s, existing_s, "research_type")
    complain_not_equal(s, existing_s, "review_type")
    complain_not_equal(s, existing_s, "approved_date")
    existing_s.save!
    s= existing_s
  end
  do_replace(s,"status", data_row['irb_status'])
  do_replace(s,"closed_date", data_row['closed_or_completed_date'])
  do_replace(s,"completed_date", data_row['closed_or_completed_date'])
  do_replace(s,"next_review_date", data_row['expiration_date'])
  do_replace(s,"accrual_goal", data_row['accrual_goal'])
  do_replace(s,"is_clinical_trial", data_row['is_a_clinical_investigation'])
  do_replace(s,"inclusion_criteria", data_row['inclusion_criteria'])
  do_replace(s,"exclusion_criteria", data_row['exclusion_criteria'])
  do_replace(s,"has_medical_services", data_row['uses_medical_services'])
  import_errors = !(data_row['import_errors'].blank? or data_row['import_errors'] == false or data_row['import_errors'].to_s.downcase == 'false' )
  do_replace(s,"had_import_errors", import_errors )
  s.save!
end

def CreateStudyInvestigatorFromHash(data_row)
  # assumed header values
  # study_id
  # user_id
  # project_role
  # consent_role
  # created_at
  # updated_at
  # netid

  s = InvestigatorStudy.new
  enotis_study_id =  data_row['study_id']
  s.role =  data_row['project_role']
  s.consent_role =  data_row['consent_role']
  username =  data_row['netid']

  if enotis_study_id.blank?
    puts "enotis_study_id was blank for this row: #{data_row.inspect}"
    return
  end
  study = Study.find_by_enotis_study_id(enotis_study_id)
  if study.blank? then
    puts "unable to find enotis_study_id #{enotis_study_id} for row: #{data_row.inspect}"
    return
  end
  investigator = Investigator.find_by_username(username)
  if investigator.blank? then
    return
  end
  s.study_id = study.id
  s.investigator_id = investigator.id
  s.consent_role = clean_consent_role(s.consent_role)
  s.role = clean_study_role(s.role)
  existing_s = InvestigatorStudy.find(:first, :conditions => ["study_id = :study_id and investigator_id = :investigator_id", {:study_id=> s.study_id, :investigator_id=>s.investigator_id}])
  if !existing_s.blank?
    if existing_s.consent_role != s.consent_role and existing_s.consent_role != "Obtaining"
      if s.consent_role == "Obtaining" or s.consent_role == "Oversight"
        existing_s.consent_role = s.consent_role
      end
    end
    if existing_s.role != s.role and existing_s.role != 'PI'
      if existing_s.role == 'Other'
        existing_s.role = s.role
      end
      if s.role == 'Co-Investigator'
        existing_s.role = s.role
      end
    end
    existing_s.save!
  else
    s.save!
  end
end

def clean_consent_role(the_role)
  cleaned = case the_role
    when "None"      :  "None"
    when "Oversight" :  "Oversight"
    when "Obtaining" :  "Obtaining"
    else                 "None"
  end
  return cleaned
end

# current list of roles:
# Co-Investigator =>  ["Co-Investiogator", "Co-I", "Co-Investigator", "co-Investigator", "Co-Inv", "CO-I", "co-investigator", "Co-Investiagtor", "Co-Investitagor", "co-inv","co-investiagtor", "Co-investigator", "Co-Investiagator", "Co-Investgatior", "co-investogator", "Co_I", "Co-PD/PI" ]
# PD/PI => [ "Principal Investigator", "PD/PI", "Director", "Co-Program Director", "Co-Director", "Investigator", "investigator", "Contact P. I."]
# Fellow => [ "Fellow", "postdoc fellow", "Post Doctoral"]
# Biostatistician => [ "Statistician", "statistician", "Statistician", "Statician", "Biostatician", "Biostatisation", "Data Mgmt.", "Analyst"]
# Faculty => [ "Faculty", "Asst. Professor", "Co-Mentor", "Mentor", "collabor", "Collaborateor", "Collaborator", "collaborator" ]
# Other => [ "Other", "O.S.P", "Advisory Board Member", "Co-Sponsor", "Program Administrator","Pharmacologist", "Other Professional", "RAP"]
# Other => [nil, , , "R.D.", "Technician", "medical monitor"] 

def clean_study_role(role)
  return 'Other' if role.blank?
  case role.downcase
    when /phys.*ther/
      'Physical Therapist'
    when /physical/
      'Other'
    when /phleb/
      'Phlebotomist'
    when /nurse/
      'Nurse'
    when /regu|coord/
      'Coordinator'
    when /physici/
      'Physicist'
    when /phys|doctor|md/
      'Physician'
    when /pharm/
      'Pharmicist'
    when /informat/
      'Informaticist'
    when /advisor/
      'Advisor'
    when /stude/
      'Student'
    when /assist/
      'Assistant'
    when /manag|admin/
      'Administrator/Manager'
    when /tech/
      'Technician'
    when /co-i|co_i|co-pd/
      'Co-Investigator'
    when /principal|pd\/pi|contact p|investigator|director/
      'PI'
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


def complain_not_equal(new_rec, old_rec, attr_name, replace=true)
  return if new_rec.blank? or new_rec[attr_name].blank? 
  return if new_rec[attr_name] == old_rec[attr_name] 
  if  ! old_rec[attr_name].blank? and  (new_rec[attr_name].class.to_s !~ /string/i or new_rec[attr_name].length < 50)
    puts "new #{attr_name} not the same as the old: new #{new_rec[attr_name]}; old: #{old_rec[attr_name]}"
  end
  if replace
    do_replace(old_rec, attr_name, new_rec[attr_name] )
  end
end

def do_replace(rec, attr_name, value)
  return  if value.blank? and not value == false
  rec[attr_name] = value
end