  require 'organization_utilities'
  
def CreateInvestigatorFromHash(data_row)
  # assumed header values
	 # netid
	 # employee_id
	 # first_name
	 # last_name
	 # middle_name
	 # email
	 # rank
	 # campus
	 # career_track
	 # category
	 # degree
	 # dept_id
	 # division_id
	 # dv_abbr
	 # basis
	  
  pi = Investigator.new
  pi.username = data_row['NETID'] || data_row['USERNAME'] || data_row['netid'] || data_row['username']
  pi.employee_id = data_row['EMPLOYEE_ID'] || data_row['employee_id'] 
  pi.first_name = data_row['FIRST_NAME'] || data_row['first_name']
  pi.middle_name = data_row['MI'] || data_row['MIDDLE_NAME'] || data_row['mi'] || data_row['middle_name']
  pi.last_name = data_row['LAST_NAME'] || data_row['last_name'] 
  pi.email = data_row['EMAIL'] || data_row['email'] 
  pi.title = data_row['RANK'] || data_row['rank'] 
  pi = SetDepartment(pi, data_row )
  pi.campus = data_row['CAMPUS'] || data_row['campus'] 
  pi.campus = pi.campus.gsub(/ *campus */i,'') if ! pi.campus.blank?
  pi.appointment_type = data_row['CATEGORY'] || data_row['category'] # Regular, Adjunct, Emeritus
  pi.appointment_track = data_row['CAREER_TRACK'] || data_row['career_track'] # research, clinician, clinician for CS, Clinician-Investigator
  pi.appointment_basis = data_row['BASIS'] || data_row['basis']
  pi.degrees = data_row['DEGREE'] || data_row['degree'] 
  pi.degrees = pi.degrees.gsub(/\//,",") if ! pi.degrees.blank?
  pi.pubmed_search_name = data_row['pubmed_search_name'] 
  pi.pubmed_limit_to_institution = data_row['pubmed_limit_to_institution'] if !data_row['pubmed_limit_to_institution'].blank?
  if pi.last_name.blank? && !data_row['NAME'].blank?
      pi=HandleName(pi,data_row['NAME'])
  end
  if pi.last_name.blank? && !data_row['name'].blank?
      pi=HandleName(pi,data_row['name'])
  end
  if pi.last_name.blank?
      puts "investigator does not have a last_name"
      puts data_row.inspect
  end
  if pi.username.blank?
    pi.username=pi.last_name+pi.first_name
  end
  pi.username = pi.username.split('.')[0]
  pi.username = pi.username.gsub(/[' \t]+/,'')
  pi.username.downcase!
  
  if pi.username.blank? then
    puts "investigator #{pi.first_name} #{pi.last_name} does not have a username"
    puts data_row.inspect
  else
    existing_pi = Investigator.find_by_username(pi.username)
    if existing_pi.blank? then
      if pi.home_department_id.blank?
        puts "unable to set home_department_id for #{data_row}"
        return 
      end
      pi.save!
    else
      existing_pi.employee_id = pi.employee_id if existing_pi.employee_id.blank?
      if existing_pi.first_name != pi.first_name
        puts "Existing first name and new first name different: existing: #{existing_pi.name}, new: #{pi.name}"
      end
      existing_pi.title = pi.title if existing_pi.title.blank?
      existing_pi.campus = pi.campus if existing_pi.campus.blank?
      existing_pi.appointment_type = pi.appointment_type if existing_pi.appointment_type.blank?
      existing_pi.appointment_track = pi.appointment_track if existing_pi.appointment_track.blank?
#      existing_pi.secondary = pi.secondary if existing_pi.secondary.blank?
#      existing_pi.division = pi.division if existing_pi.division.blank?
      existing_pi.email = pi.email if existing_pi.email.blank?
      existing_pi.employee_id = pi.employee_id if existing_pi.employee_id.blank?
      existing_pi.home_department_id = pi.home_department_id if existing_pi.home_department_id.blank?
      existing_pi.pubmed_search_name = pi.pubmed_search_name if existing_pi.pubmed_search_name.blank?
      existing_pi.pubmed_limit_to_institution = pi.pubmed_limit_to_institution if existing_pi.pubmed_limit_to_institution.blank?
      existing_pi.save
      pi = existing_pi
     end
    if ! data_row['program'].blank? then
      theProgram = CreateProgramFromName(data_row['program'])
      if theProgram.blank? then
        throw "unable to match program #{data_row['program']} for user #{pi.username}"
      end
      # replace this logic with a STI model of 'member??'
      if  InvestigatorAppointment.find(:all, :conditions=>['investigator_id=:investigator_id and organizational_unit_id=:program_id and type in (:types)', 
        {:program_id => theProgram.id, :investigator_id => pi.id, :types => ["member","leader","co-leader"]}]).length == 0
		  InvestigatorAppointment.create :organizational_unit_id => theProgram.id, :investigator_id => pi.id, :type => 'member', :start_date => Time.now
		end
	  end
	end
end

def HandleName(pi, name)
  return pi if name.blank? 
  pre, degrees = name.split(",")
  pi.degrees = degrees
  names = pre.split(" ")
  if ['I','II','III','Jr','Sr'].include?(names.last)
    pi.suffix = names.pop
  end
  if names.length < 2 || names.length > 3
    puts "investigator name is not valid - #{names}"
    puts pi.inspect
    return pi
  end
  if names.length == 2
    pi.first_name  = names[0]
    pi.last_name   = names[1]
  else
    pi.first_name  = names[0]
    pi.middle_name = names[1]
    pi.last_name   = names[2]
  end
  return pi
end


def InsertInvestigatorProgramsFromDepartments(pis)
  pis.each do |pi|
    theProgram = CreateProgramFromDepartment(pi.home_department)
    InsertInvestigatorProgram(pi,theProgram)
    theProgram = CreateProgramFromDepartment(pi.secondary)
    InsertInvestigatorProgram(pi,theProgram)
   end
end

def InsertInvestigatorProgram(pi,program)
  if !program.blank? && !program.id.blank? && !pi.id.blank? then
    begin
      ip = InvestigatorProgram.create :program_id => program.id, :investigator_id => pi.id, :program_appointment => 'member', :start_date => Time.now
    rescue Exception => error
       puts "something happened"+error
       throw pi.inspect
    end
  end
end

def CreateAppointment(data_row, type)
  # assumed header values
	 # division_id
	 # employee_id
  division_id = data_row["DIVISION_ID"]
  employee_id = data_row["EMPLOYEE_ID"]
  if division_id.blank? || employee_id.blank? then
     puts "Division_id or employee_id was blank or missing. datarow="+data_row.inspect
     return
  end  
  appt = InvestigatorAppointment.new
  division = OrganizationalUnit.find_by_division_id(division_id)
  investigator = Investigator.find_by_employee_id(employee_id)
  if  division.blank? then
     puts "Could not find Organization. datarow="+data_row.inspect
     return
  end
  if investigator.blank? then
      puts "Could not find Investigator. datarow="+data_row.inspect
      return
  end
  appt.type = type
  appt.organizational_unit_id = division.id
  appt.investigator_id = investigator.id
  exists = InvestigatorAppointment.find(:first, :conditions=>
    ['organizational_unit_id = :unit_id and investigator_id = :investigator_id and type = :type', 
      {:investigator_id => appt.investigator_id, :unit_id => appt.organizational_unit_id, :type => appt.type }])
  if exists.nil?
    appt.save
  end
end

def CreateJointAppointmentsFromHash(data_row)
  CreateAppointment(data_row, "Joint")
end

def CreateSecondaryAppointmentsFromHash(data_row)
     CreateAppointment(data_row, "Secondary")
end

def CreateCenterMembershipsFromHash(data_row)
     CreateAppointment(data_row, "Member")
end

def CreateProgramMembershipsFromHash(data_row, type='Member')
  # assumed header values
	 # Program	
	 # AppointmentType
	 # LastName
	 # FirstName
	 # email
   last_name = data_row["LastName"]
   unit_abbreviation = data_row["Program"]
  email = data_row["email"]
  if unit_abbreviation.blank? || (last_name.blank? and email.blank?) then
     puts "unit_abbreviation or email was blank or missing. datarow="+data_row.inspect
     return
  end  
  appt = InvestigatorAppointment.new
  program = OrganizationalUnit.find_by_abbreviation(unit_abbreviation)
  investigator=nil
  investigators = Investigator.find_all_by_last_name(last_name)
  if investigators.length == 1
    investigator = investigators[0]
  else
    investigator = Investigator.find_by_email(email)
  end
  if  program.blank? then
     puts "Could not find Organization. datarow="+data_row.inspect
     return
  end
  if investigator.blank? then
      puts "Could not find Investigator. datarow="+data_row.inspect
      puts "(found multiple investigators with last name #{last_name})" if investigators.length > 1
      return
  end
  appt.type = type
  appt.organizational_unit_id = program.id
  appt.investigator_id = investigator.id
  exists = InvestigatorAppointment.find(:first, :conditions=>
    ['organizational_unit_id = :unit_id and investigator_id = :investigator_id and type = :type', 
      {:investigator_id => appt.investigator_id, :unit_id => appt.organizational_unit_id, :type => appt.type }])
  if exists.nil?
    appt.save
  else
    # save so we can look at the update_at info for all members
    exists.update_attribute(:investigator_id, investigator.id) 
  end
 end

def prune_investigators_without_programs(investigators)
  investigators.each do |investigator|
    if investigator.investigator_appointments.nil?
      puts "deleting investigator #{investigator.name}" if @verbose
      investigator.delete 
    end
  end
end

def prune_program_memberships_not_updated()
  memberships = InvestigatorAppointment.all
  memberships.each do |membership|
    if membership.updated_at < 1.hour.ago
      puts "deleting membership entry for #{membership.investigator.name} in program #{membership.organizational_unit.name}" if @verbose
      membership.delete 
    end
  end
end

def doCleanInvestigators(investigators)
  investigators.each do |pi|
    pi.username = pi.username.split('.')[0]
    pi.save!
  end
end
