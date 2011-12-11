require 'organization_utilities'
require 'config' # cleanup_campus is in config
require "#{RAILS_ROOT}/app/helpers/investigators_helper"
include InvestigatorsHelper

def to_str(element)
  return "" if element.blank?
  return element.to_s.split(13.chr).join(', ')
end

def DoReadNamesAndSplit(data_row)
  investigator_string = data_row["name"] || data_row["NAME"]
  first_name = ""
  middle_name = ""
  last_name = ""
  degrees = ""
  
  return if investigator_string.blank?
  investigator_string =~ /([^,]*),(.*)/
  if $2.blank?
    name_string = investigator_string
  else
    name_string = $1.strip
    degrees = $2.strip
  end
  space_split = name_string.split(" ")
  if space_split.length == 1
    last_name = space_split[0]
  elsif space_split.length == 2
    first_name = space_split[0]
    last_name = space_split[1]
  elsif space_split.length == 3
    first_name = space_split[0]
    middle_name = space_split[1]
    last_name = space_split[2]
  else
    puts "unable to process #{investigator_string}: too many spaces"
    return
  end
  puts "#{first_name}\t#{middle_name}\t#{last_name}\t#{degrees}"
end

def GenerateNetIDReport(data_row)
  pi = Investigator.new
  pi = SetInvestigatorIdentity(pi,data_row)
  existing_investigator = IdentifyExistingInvestigator(pi)
  position = "FSM faculty"
  if existing_investigator.blank? and ! pi.username.blank?
    position = "Not FSM faculty"
    existing_investigator = Investigator.new(:username=>pi.username)
  end
  
  existing_investigator = merge_investigator_db_and_ldap(existing_investigator)
  
  if pi.username.blank? then
    puts "GenerateNetIDReport: Row did not have a username"
    puts data_row.inspect
  elsif existing_investigator.blank? or existing_investigator.last_name.blank?
    puts pi.username + "\tblank investigator"
  else
    if ! existing_investigator.home_department.blank? then 
      department_name = existing_investigator.home_department.name.to_s
      department_abbreviation = existing_investigator.home_department.abbreviation.to_s
    elsif ! existing_investigator.home_department_name.blank?
      department_name = existing_investigator.home_department_name.to_s
      department_abbreviation = department_name.to_s
    elsif ! existing_investigator.home.blank?
      department_name = existing_investigator.home.to_s
      department_abbreviation = department_name.to_s
    else
      department_name = "not found"
      department_abbreviation = "not found"
    end
    puts existing_investigator.username + "\t" + to_str(existing_investigator.first_name) + "\t" + to_str(existing_investigator.middle_name) + "\t" + to_str(existing_investigator.last_name) + "\t" + to_str(existing_investigator.degrees) + "\t" + to_str(existing_investigator.email) + "\t" + to_str(existing_investigator.employee_id) + "\t" + to_str(existing_investigator.title) + "\t" + position + "\t" + department_name + "\t" + to_str(existing_investigator.business_phone) + "\t" + to_str(existing_investigator.address1)  
  end
end

def CreateInvestigatorFromHash(data_row)
  pi = Investigator.new
  pi = SetInvestigatorIdentity(pi,data_row)
  pi = HandleUsername(pi)
  pi = SetInvestigatorInformation(pi,data_row)
  pi = SetInvestigatorAddress(pi,data_row)
  
  if pi.username.blank? then
    puts "investigator #{pi.first_name} #{pi.last_name} does not have a username"
    puts data_row.inspect
  elsif pi.last_name.blank?
    puts "investigator does not have a last_name"
    puts data_row.inspect
  else
    existing_pi = Investigator.find_by_username_including_deleted(pi.username)
    if existing_pi.blank? and ! pi.email.blank? then
      existing_pi = Investigator.find_by_email_including_deleted(pi.email)
    end
    if existing_pi.blank? then
      if pi.home_department_id.blank? and pi.home_department_name.blank?
        puts "unable to set home_department_id for #{data_row}" if LatticeGridHelper.verbose? and HasDepartment(data_row)
      end
      puts "New investigator: #{pi.first_name} #{pi.last_name}; username: #{pi.username}; email: #{pi.email}" if LatticeGridHelper.verbose?
      pi.save!
    else
      # overwrite existing record ?
      overwrite=true
      existing_pi.employee_id = pi.employee_id if existing_pi.employee_id.blank? and ! pi.employee_id.blank?
      if existing_pi.first_name != pi.first_name
        puts "Existing first name and new first name different: existing: #{existing_pi.name}, username: #{existing_pi.username}, email: #{existing_pi.email}; new record: #{pi.name}, username #{pi.username}, email: #{pi.email}"
        overwrite=false
      end
      if existing_pi.email != pi.email and !pi.email.blank?
        puts "Existing email is different: existing: #{existing_pi.name}, username: #{existing_pi.username}, email: #{existing_pi.email}; merging record: #{pi.name}, username #{pi.username}, email: #{pi.email}"
      end
      existing_pi = MergeInvestigatorData(existing_pi, pi, overwrite)
      # in case this investigator was marked as deleted/expired
      existing_pi.end_date = nil
      existing_pi.deleted_at = nil
      existing_pi.deleted_ip = nil
      existing_pi.deleted_id = nil
      existing_pi.end_date = Date.today
      existing_pi.save
      existing_pi.end_date = nil
      existing_pi.save!
      pi = existing_pi
    end
    if ! data_row['program'].blank? then
      theProgram = CreateProgramFromName(data_row['program'].strip)
      if theProgram.blank? then
        throw "unable to match program #{data_row['program']} for user #{pi.username}"
      end
      # replace this logic with a STI model of 'member??'
      membership = InvestigatorAppointment.find(:first, 
          :conditions=>['investigator_id=:investigator_id and organizational_unit_id=:program_id and type in (:types)', 
            {:program_id => theProgram.id, :investigator_id => pi.id, :types => ["Member"]}])
      if membership.blank?
        puts "Membership of #{pi.name} in #{theProgram.name} created" if LatticeGridHelper.verbose?
        Member.create :organizational_unit_id => theProgram.id, :investigator_id => pi.id, :start_date => Time.now
      else
        puts "Membership of #{pi.name} in #{theProgram.name} updated" if LatticeGridHelper.debug?
        membership.end_date = nil
        membership.updated_at = Time.now
        membership.save!  # update the record
      end
    else
      puts 'no program datarow' if LatticeGridHelper.debug?
	  end
	end
end

def HandleUsername(pi)
  if pi.username.blank? and !pi.last_name.blank? and !pi.first_name.blank?
    pi.username=pi.last_name+pi.first_name
  end
  if pi.username.blank? and !pi.email.blank?
    pi.username = pi.email
    pi.username = pi.username.gsub(/[\.]+/,'_')
  end
  if !pi.username.blank?
    pi.username = pi.username.split('.')[0]
    pi.username = pi.username.split('(')[0]
    pi.username = pi.username.gsub(/[' \t]+/,'')
    pi.username = pi.username.downcase
  end
  pi
end

def SetInvestigatorIdentity(pi, data_row)
  # assumed header values
  # netid || username
  # employee_id
  # name || first_name & last_name
  # first_name
  # last_name
  # middle_name || mi
  # email
  pi.username = data_row['NETID'] || data_row['USERNAME'] || data_row['netid'] || data_row['username']
  pi.employee_id = data_row['EMPLOYEE_ID'] || data_row['employee_id'] 
  pi.first_name = data_row['FIRST_NAME'] || data_row['first_name']
  pi.middle_name = data_row['MI'] || data_row['MIDDLE_NAME'] || data_row['mi'] || data_row['middle_name']
  pi.last_name = data_row['LAST_NAME'] || data_row['last_name'] 
  pi.email = data_row['EMAIL'] || data_row['email'] 

  pi.username.downcase.strip! if ! pi.username.blank?
  pi.first_name = pi.first_name.gsub(/\./,' ').strip if ! pi.first_name.blank?
  pi.middle_name = pi.middle_name.gsub(/\./,' ').strip if ! pi.middle_name.blank?
  pi.last_name = pi.last_name.gsub(/\./,' ').strip if ! pi.last_name.blank?
  pi.email.downcase.strip! if ! pi.email.blank?
  pi.employee_id.to_s.strip! if ! pi.employee_id.blank?
  pi.employee_id.to_s.downcase! if ! pi.employee_id.blank?
 
  if pi.last_name.blank? && !data_row['NAME'].blank?
      pi=HandleName(pi,data_row['NAME'])
  end
  if pi.last_name.blank? && !data_row['name'].blank?
      pi=HandleName(pi,data_row['name'])
  end
  if !pi.email.blank?
    pi.email.downcase!
  end
  pi
end

def SetInvestigatorInformation(pi, data_row)
  # assumed header values
  # rank || title
  # category
  # career_track
  # basis
  # degree || degrees
  # pubmed_search_name
  # pubmed_limit_to_institution
  # interests || faculty_interests
  # description || summary || faculty_description || research_summary
  # keywords || research_keywords || faculty_keywords


  pi.title = data_row['RANK'] || data_row['rank'] || data_row['TITLE'] || data_row['title'] 
  CleanTitle(pi)
  pi = SetDepartment(pi, data_row )
  pi.appointment_type = data_row['CATEGORY'] || data_row['category'] # Regular, Adjunct, Emeritus
  pi.appointment_track = data_row['CAREER_TRACK'] || data_row['career_track'] # research, clinician, clinician for CS, Clinician-Investigator
  pi.appointment_basis = data_row['BASIS'] || data_row['basis']
  pi.degrees = data_row['DEGREE'] || data_row['degree'] || data_row['DEGREES'] || data_row['degrees'] 
  pi.degrees = pi.degrees.gsub(/\//,",") if ! pi.degrees.blank?
  pi.pubmed_search_name = data_row['pubmed_search_name'] 
  pi.pubmed_limit_to_institution = data_row['pubmed_limit_to_institution'] if !data_row['pubmed_limit_to_institution'].blank?
  pi.faculty_interests = data_row['interest'] || data_row['INTEREST'] || data_row['faculty_interest'] || data_row['FACULTY_INTEREST']
  pi.faculty_research_summary = data_row['description'] || data_row['DESCRIPTION'] || data_row['faculty_description'] || data_row['FACULTY_DESCRIPTION'] || data_row['summary'] || data_row['SUMMARY'] || data_row['research_summary'] || data_row['RESEARCH_SUMMARY']
  pi.faculty_keywords = data_row['keywords'] || data_row['KEYWORDS'] || data_row['faculty_keywords'] || data_row['FACULTY_KEYWORDS'] || data_row['research_keywords'] || data_row['RESEARCH_KEYWORDS']


  pi.title.strip! if ! pi.title.blank?
  pi.appointment_type.strip! if ! pi.appointment_type.blank?
  pi.appointment_track.strip! if ! pi.appointment_track.blank?
  pi.appointment_basis.strip! if ! pi.appointment_basis.blank?
  pi.degrees.strip! if ! pi.degrees.blank?
  pi.pubmed_search_name.strip! if ! pi.pubmed_search_name.blank?
  # pi.pubmed_limit_to_institution.strip! if ! pi.pubmed_limit_to_institution.blank? # fails for booleans
  pi.faculty_interests.strip! if ! pi.faculty_interests.blank?
  pi.faculty_research_summary.strip! if ! pi.faculty_research_summary.blank?
  pi.faculty_keywords.strip! if ! pi.faculty_keywords.blank?

  pi.faculty_research_summary = CleanNonUTFtext(pi.faculty_research_summary)
  pi
end

def SetInvestigatorAddress(pi,data_row)
  # assumed header values
  # campus
  # office_phone || business_phone
  # home_phone || mobile_phone || cell_phone
  # lab_phone
  # fax
  # pager
  # mailcode || campus_mailcode
  # address || address1
  # address2
  # city
  # state
  # postal_code || zip
  # country
  pi.campus = data_row['CAMPUS'] || data_row['campus'] 
  pi.campus = pi.campus.gsub(/ *campus */i,'') if ! pi.campus.blank?
  pi.business_phone = data_row['BUSINESS_PHONE'] || data_row['business_phone'] || data_row['OFFICE_PHONE'] || data_row['office_phone'] 
  pi.home_phone = data_row['home_phone'] || data_row['HOME_PHONE'] || data_row['mobile_phone'] || data_row['MOBILE_PHONE'] || data_row['cell_phone'] || data_row['CELL_PHONE']
  pi.lab_phone = data_row['lab_phone'] || data_row['LAB_PHONE']
  pi.fax = data_row['FAX'] || data_row['fax'] 
  pi.pager = data_row['pager'] || data_row['PAGER'] 
  pi.mailcode = data_row['mailcode'] || data_row['MAILCODE'] || data_row['campus_mailcode'] || data_row['CAMPUS_MAILCODE'] 
  pi.address1 = data_row['address'] || data_row['ADDRESS'] || data_row['address1'] || data_row['ADDRESS1'] 
  pi.address2 = data_row['address2'] || data_row['ADDRESS2'] 
  pi.city = data_row['city'] || data_row['CITY']
  pi.state = data_row['state'] || data_row['STATE'] 
  pi.postal_code = data_row['postal_code'] || data_row['POSTAL_CODE'] || data_row['zip'] || data_row['ZIP']
  pi.country = data_row['country'] || data_row['COUNTRY'] 

  pi.campus.strip! if ! pi.campus.blank?
  pi.business_phone.strip! if ! pi.business_phone.blank?
  pi.home_phone.strip! if ! pi.home_phone.blank?
  pi.lab_phone.strip! if ! pi.lab_phone.blank?
  pi.fax.strip! if ! pi.fax.blank?
  pi.pager.strip! if ! pi.pager.blank?
  pi.mailcode.to_s.strip! if ! pi.mailcode.blank?
  pi.address1.strip! if ! pi.address1.blank?
  pi.address2.strip! if ! pi.address2.blank?
  pi.city.strip! if ! pi.city.blank?
  pi.state.strip! if ! pi.state.blank?
  pi.postal_code.to_s.strip! if ! pi.postal_code.blank?
  pi.country.strip! if ! pi.country.blank?

  pi.campus = nil if pi.campus.blank?
  pi.business_phone = nil if pi.business_phone.blank?
  pi.home_phone = nil if pi.home_phone.blank?
  pi.lab_phone = nil if pi.lab_phone.blank?
  pi.fax = nil if pi.fax.blank?
  pi.pager = nil if pi.pager.blank?
  pi.mailcode = nil if pi.mailcode.blank?
  pi.address1 = nil if pi.address1.blank?
  pi.address2 = nil if pi.address2.blank?
  pi.city = nil if pi.city.blank?
  pi.state = nil if pi.state.blank?
  pi.postal_code = nil if pi.postal_code.blank?
  pi.country = nil if pi.country.blank?

  pi = BuildAddressField(pi)
  pi
end

def BuildAddressField(pi)
  mailcode = nil
  city_state_zip = [[pi.city,pi.state].join(', '), pi.postal_code].join(" ").gsub(/^, +/,'')
  mailcode = "campus mailcode: #{pi.mailcode}" if !pi.mailcode.blank?
  pi.address1 = [mailcode, pi.address1, pi.address2, city_state_zip,pi.country].join("$")
  pi.address1 = pi.address1.gsub(/ *\$+[, ]*\$+/,"$").gsub(/\$$/,'')
  pi.address1 = nil if pi.address1.blank?
  pi
end

def CleanNonUTFtext(the_text)
  return if the_text.blank?
  return to_ascii_iconv(the_text)
#  the_text.gsub!(/&\#(\d+);/m) {|s| [$1.to_i].pack('U') }
 # the_text.gsub!(/•|¥||ê/m,'\\\'')
  #the_text.gsub!(/–|”|Ð|Ó/m,'"')
#  the_text.gsub!(/ã||/m,'-')
 # the_text.gsub!(/Í|ê/m,'i')
  #the_text.gsub!(/ô|/m,'u')
#  accents = { 
#  		  ['á','à','â','ä','ã'] => 'a',
#  		  ['Ã','Ä','Â','À','�?'] => 'A',
#  		  ['é','è','ê','ë'] => 'e',
#  		  ['Ë','É','È','Ê'] => 'E',
#  		  ['í','ì','î','ï'] => 'i',
#  		  ['�?','Î','Ì','�?'] => 'I',
#  		  ['ó','ò','ô','ö','õ'] => 'o',
#  		  ['Õ','Ö','Ô','Ò','Ó'] => 'O',
#  		  ['ú','ù','û','ü'] => 'u',
#  		  ['Ú','Û','Ù','Ü'] => 'U',
#  		  ['ç'] => 'c', ['Ç'] => 'C',
#  		  ['ñ'] => 'n', ['Ñ'] => 'N'
#  		  }
#  		accents.each do |ac,rep|
#  		  ac.each do |s|
#  			str = str.gsub(s, rep)
#  		  end
#  		end
  
  the_text
end

def to_ascii_iconv(text)
  ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
  new_text=ic.iconv(text + ' ')[0..-2]
  converter = Iconv.new('ASCII//IGNORE//TRANSLIT', 'UTF-8') 
  text = converter.iconv(new_text).unpack('U*').select{ |cp| cp < 127 }.pack('U*')
  text.gsub(/\022|\023|\024|\030|\031|\034|\035/,' ')
  
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

def DoOverwrite(dest, source, overwrite)
  if overwrite and !source.blank?
    return source
  end
  if !overwrite and dest.blank?
    return source
  end
  return dest
end

def MergeInvestigatorData(dest_pi, source_pi, overwrite)
  dest_pi.title               = DoOverwrite(dest_pi.title, source_pi.title, overwrite)
  dest_pi.campus              = DoOverwrite(dest_pi.campus, source_pi.campus, overwrite)
  dest_pi.degrees             = DoOverwrite(dest_pi.degrees, source_pi.degrees, overwrite)
  dest_pi.appointment_type    = DoOverwrite(dest_pi.appointment_type, source_pi.appointment_type, true)
  dest_pi.appointment_track   = DoOverwrite(dest_pi.appointment_track, source_pi.appointment_track, true)
  dest_pi.appointment_basis   = DoOverwrite(dest_pi.appointment_basis, source_pi.appointment_basis, true)
  dest_pi.faculty_keywords    = DoOverwrite(dest_pi.faculty_keywords, source_pi.faculty_keywords, overwrite)
  dest_pi.faculty_interests   = DoOverwrite(dest_pi.faculty_interests, source_pi.faculty_interests, overwrite)
  dest_pi.faculty_research_summary   = DoOverwrite(dest_pi.faculty_research_summary, source_pi.faculty_research_summary, overwrite)
  dest_pi.email               = DoOverwrite(dest_pi.email, source_pi.email, overwrite)
  dest_pi.employee_id         = DoOverwrite(dest_pi.employee_id, source_pi.employee_id, overwrite)
  dest_pi.home_department_id  = DoOverwrite(dest_pi.home_department_id, source_pi.home_department_id, overwrite)
  dest_pi.pubmed_search_name  = DoOverwrite(dest_pi.pubmed_search_name, source_pi.pubmed_search_name, overwrite)
  dest_pi.pubmed_limit_to_institution = DoOverwrite(dest_pi.pubmed_limit_to_institution, source_pi.pubmed_limit_to_institution, overwrite)
  dest_pi = LatticeGridHelper.cleanup_campus(dest_pi)
  dest_pi
end

def IdentifyExistingInvestigator(pi)
  return nil if pi.blank?
  existing = Investigator.find_by_username(pi.username) if ! pi.username.blank?
  return existing if ! existing.blank?
  existing = Investigator.find_by_employee_id(pi.employee_id) if ! pi.employee_id.blank?
  return existing if ! existing.blank?
  existing = Investigator.find_by_email(pi.email) if ! pi.email.blank?
  return existing if ! existing.blank?
  existing = Investigator.find(:all, 
    :conditions => ['lower(last_name) = lower(:last_name) and lower(first_name) = lower(:first_name)', 
      {:first_name=>pi.first_name,  :last_name=>pi.last_name}])  if (! pi.first_name.blank?) and (! pi.last_name.blank?)
  unless  existing.blank? or existing.length != 1
    return existing[0] 
  end
  nil
end

def FindInvestigatorsWithBasisWithoutActivities(basis)
  pis = Investigator.has_basis_without_connections(basis)
  puts "Found #{pis.length} investigators tagged as #{basis} without activities" if LatticeGridHelper.verbose?
  return pis
end

def FindParttimeInvestigatorsWithoutActivities()
  basis_array = ["UNPD","CS","PT-L","PT-G"]
  basis_array.each do |basis|
    pis = FindInvestigatorsWithBasisWithoutActivities(basis)
  end
end  

def PurgeParttimeInvestigatorsWithoutActivities()
  basis_array = ["UNPD","CS","PT-L","PT-G"]
  basis_array.each do |basis|
    pis = FindInvestigatorsWithBasisWithoutActivities(basis)
    purgeInvestigators(pis)
  end
end  

def MergeInvestigatorDescriptionsFromHash(data_row)
  # assumed header values
  # netid || username
  # employee_id
  # email
  # first_name
  # last_name
  # interests
  # description || summary
  # keywords
  # will disambiguate investigator based on netid, employee_id, email or (first_name + last_name), in that order
  investigator = Investigator.new
  investigator = SetInvestigatorIdentity(investigator,data_row)
  investigator = HandleUsername(investigator)
  investigator = SetInvestigatorInformation(investigator,data_row)
  existing_investigator = IdentifyExistingInvestigator(investigator)
  if !existing_investigator.blank?
    puts "merging data: #{existing_investigator.name}; #{existing_investigator.username}." if LatticeGridHelper.debug?
    # uncomment this if you are merging multiple research summaries
    #    if !investigator.faculty_research_summary.blank? and (existing_investigator.faculty_research_summary =~ Regexp.new(investigator.faculty_research_summary[0..20].gsub(/\//,'?')) ).blank?
    #      existing_investigator.faculty_research_summary += investigator.faculty_research_summary
    #    end
    # merge multiple research interests, assuming they are single items
    if (!existing_investigator.faculty_interests.blank? and !investigator.faculty_interests.blank?) 
      investigator.faculty_interests.strip!
      if (! existing_investigator.faculty_interests.split(',').collect{|interest| interest.strip }.include?(investigator.faculty_interests))
        existing_investigator.faculty_interests = [existing_investigator.faculty_interests,investigator.faculty_interests].join(", ")
        investigator.faculty_interests = existing_investigator.faculty_interests
        puts "merging faculty interests: #{investigator.faculty_interests}" if LatticeGridHelper.verbose?
      else
        investigator.faculty_interests = existing_investigator.faculty_interests
      end
    end
    existing_investigator = MergeInvestigatorData(existing_investigator, investigator, true)
    existing_investigator.save!
  else
    puts "could not find Investigator: name: #{investigator.name}; email: #{investigator.email}; username: #{investigator.username} for data_row: #{data_row.inspect}"  if LatticeGridHelper.debug?
  end
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
    appt.save!
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
  last_name = data_row["LastName"] || data_row["last_name"] || data_row["LAST_NAME"]
  first_name = data_row["FirstName"] || data_row["first_name"] || data_row["FIRST_NAME"]
  unit_abbreviation = data_row["Program"] || data_row["program"] || data_row["PROGRAM"]
  email = data_row["email"] || data_row["EMAIL"]
  if unit_abbreviation.blank? || (last_name.blank? and email.blank?) then
     puts "unit_abbreviation or email was blank or missing. datarow="+data_row.inspect
     return
  end
  last_name.strip! if !last_name.blank?
  first_name.strip! if !first_name.blank?
  email.downcase.strip! if !email.blank?
  unit_abbreviation.strip! if !unit_abbreviation.blank?
  appt = InvestigatorAppointment.new
  program = OrganizationalUnit.find_by_abbreviation(unit_abbreviation)
  investigator=nil
  investigators = Investigator.find_all_by_email(email)
  if investigators.length == 1
    investigator = investigators[0]
  else
    investigator = Investigator.first(
        :conditions => ["lower(last_name) = :last_name AND lower(first_name) like :first_name",
           {:last_name => last_name.downcase, :first_name => "#{first_name.split(" ").first.downcase}%"}])
    if investigator.blank? then
      more_pis = Investigator.find(:all, 
        :conditions => ["lower(email) = :email",
           {:email => email}])
      if more_pis.length == 1
        investigator = more_pis[0]
      end
    end
    if investigator.blank? then
      more_pis = Investigator.all(
        :conditions => ["lower(last_name) = :last_name AND lower(first_name) like :first_name",
           {:last_name => last_name.split(",").first.downcase, :first_name => "#{first_name.split(" ").first.downcase}%"}])
      if more_pis.length == 1
        investigator = more_pis[0]
      end
    end
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
    appt.save!
  else
    # save so we can look at the update_at info for all members
    exists.end_date = Date.today
    exists.save
    exists.end_date = nil
    exists.save!
  end
 end

def prune_investigators_without_programs(investigators)
  investigators.each do |investigator|
    if investigator.investigator_appointments.nil?
      puts "pruning (setting deleted_at and end_date) for investigator #{investigator.name}" if LatticeGridHelper.verbose?
      investigator.deleted_at = 2.days.ago
      investigator.end_date = 2.days.ago
      investigator.save!
    end
  end
end

def prune_program_memberships_not_updated()
  memberships = InvestigatorAppointment.all
  memberships.each do |membership|
    # membership.updated_at < 1.hour.ago means update was more than an hour ago!
    if (membership.updated_at < 1.day.ago or membership.investigator.nil? or membership.organizational_unit.nil?) and (membership.end_date.nil? or membership.end_date > Date.tomorrow)
      puts "deleting membership entry for #{membership.investigator.name} username #{membership.investigator.username} in program #{membership.organizational_unit.name}" if LatticeGridHelper.verbose? and !membership.investigator.nil? and ! membership.organizational_unit.nil?
      puts "deleting membership entry for #{membership.investigator_id} with an invalid/deleted user in program #{membership.organizational_unit.name}" if LatticeGridHelper.verbose? and membership.investigator.nil? and ! membership.organizational_unit.nil?
      puts "deleting membership entry for #{membership.investigator.name} username #{membership.investigator.username} in deleted program #{membership.organizational_unit_id}" if LatticeGridHelper.verbose? and !membership.investigator.nil? and membership.organizational_unit.nil?
      membership.end_date = 1.day.ago
      membership.save! 
    end
  end
end

def doCleanInvestigators(investigators)
  puts "cleaning #{investigators.length} investigators" if LatticeGridHelper.verbose?
  investigators.each do |pi|
    begin
      pi.username = pi.username.split('.')[0]
      pi.username = pi.username.split('(')[0]
      pi.username.gsub!(/[' \t]+/,'')
      pi.save!
    rescue
      puts "could not change #{pi.name} username to #{pi.username}"
    end
  end
end

def CleanTitle(pi)
  return if pi.blank? or pi.title.blank?
  title = pi.title 
  title = title.sub(/Sr /, "Senior ")
  title = title.sub(/Emer$/, "Emeritus")
  title = title.sub(/Adj /, "Adjunct ")
  title = title.sub(/Asst /, "Assistant ")
  title = title.sub(/Assoc /, "Associate ")
  title = title.sub(/Prof$/, "Professor")
  title = title.sub(/Prof,/, "Professor,")
  title = title.sub(/CL$/, "Clinical")
  title = title.sub(/CL /, "Clinical ")
  title = title.sub(/Res /, "Research ")
  title = title.sub(/Vis /, "Visiting ")
  title = title.sub(/Dir /, "Director ")
  title = title.sub(/Dir$/, "Director")
  pi.title = title
end

def UpdateHomeDepartmentAndTitle(pi)
  return if pi.blank? or pi.username.blank?
  pi.home_department_name=pi.home_department.name if !pi.home_department.blank?
  if ( LatticeGridHelper.ldap_perform_search?)
    begin
      pi_data = GetLDAPentry(pi.username)
      if pi_data.nil?
        logger.warn("Probable error reaching the LDAP server in GetLDAPentry: GetLDAPentry returned null for netid #{pi.username}.")
      elsif pi_data.blank?
          logger.warn("Entry not found. GetLDAPentry returned null using netid #{pi.username}.")
      else
        ldap_rec=CleanPIfromLDAP(pi_data)
        investigator = Investigator.new
        investigator=MergePIrecords(investigator,ldap_rec)
      end
    rescue Exception => error
      if pi_data.nil?
        puts "Probable error reaching the LDAP server in GetLDAPentry: GetLDAPentry returned null for netid #{pi.username}."
      else
        puts "Entry not found. GetLDAPentry returned null using netid #{pi.username}."
      end
    end
  end
  return if investigator.blank?
  CleanTitle(investigator)
  if not investigator.title.blank? and (pi.title.blank? or pi.title.strip != investigator.title.strip )
    puts "Title change for pi #{pi.name}. Old: #{pi.title}. New: #{investigator.title}"
    pi.title = investigator.title
  end
  if not investigator.home.blank? and (pi.home_department_name.blank? or pi.home_department_name.strip != investigator.home.strip )
    puts "home department change for pi #{pi.name}. Old: #{pi.home_department_name}; New: #{investigator.home};"
    pi.home_department_name = investigator.home
  end
end

def purgeInvestigators(investigators_to_purge)
  investigators_to_purge.each do |pi|
    puts "marking investigator  #{pi.name} username #{pi.username} as deleted" if LatticeGridHelper.verbose?
    pi.deleted_at = 2.days.ago
    pi.end_date = 2.days.ago
    pi.save!
  end
end

def deletePurgedInvestigators()
  purged_investigators = Investigator.find_purged
  puts "deleting #{purged_investigators.length} investigators"
  purged_investigators.each do |pi|
    puts "deleting purged investigator  #{pi.name} username #{pi.username}" if LatticeGridHelper.verbose?
    pi.investigator_abstracts.map{|m| m.delete}
    pi.all_investigator_appointments.map{|m| m.delete}
    pi.investigator_proposals.map{|m| m.delete}
    pi.investigator_studies.map{|m| m.delete}
    pi.investigator_colleagues.map{|m| m.delete}
    pi.colleague_investigators.map{|m| m.delete}
    Investigator.delete_deleted(pi.id)
  end
end

def reinstateInvestigators(pis)
  puts "reinstating #{pis.length} investigators"
  pis.each do |pi|
    puts "reinstating purged investigator  #{pi.name} username #{pi.username}" if LatticeGridHelper.verbose?
    pi.deleted_at = nil
    pi.end_date = nil
    pi.save!
  end
end


def count_faculty_updates()
  updated = Investigator.find_updated().length
  not_updated = Investigator.find_not_updated().length
  puts "#{updated} faculty updated. #{not_updated} faculty were not updated."
end

def prune_unupdated_faculty()
  updated = Investigator.find_updated().length
  not_updated = Investigator.find_not_updated()
  puts "#{updated} faculty updated. #{not_updated.length} faculty were not updated."
  purgeInvestigators(not_updated)
  puts "#{not_updated.length} faculty were marked as removed."
  
end