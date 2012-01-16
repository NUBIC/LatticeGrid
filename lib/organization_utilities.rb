require 'config'

def CreateSchoolDepartmentFromHash(data_row)
# APPT_ENTITY_ABBR - abbreviated name
# APPT_ENTITY_CHAIR_FACULTY_ID - link to an internal id for the chair of the department
# APPT_ENTITY_ID - same as dept_id or department_id
# APPT_ENTITY_NAME - Name of the department
# APPT_ENTITY_SCHOOL - name of the owning school
  node_abbrev = data_row['APPT_ENTITY_ABBR'] || data_row['ENTITY_ABBR'] || data_row['ABBR'] || data_row['ABBR_NAME']
  node_name = data_row['APPT_ENTITY_NAME'] || data_row['NODE_NAME'] || data_row['ENTITY_NAME'] 
  node_search_name = data_row['APPT_SEARCH_NAME'] || data_row['SEARCH_NAME'] 
  node_label = data_row['LABEL_NAME'] || node_name
  node_id = data_row['APPT_ENTITY_ID'] || data_row['ENTITY_ID'] || data_row['ID'] || data_row['NODE_ID'] || data_row['dept_id'] || data_row['department_id'] || data_row['DEPT_ID'] || data_row['DEPARTMENT_ID']
  root_name = data_row['APPT_ENTITY_SCHOOL'] || data_row['ROOT'] || data_row['ROOT_NAME']

  if root_name == node_abbrev || node_name =~ /school/i || node_name =~ /college/i
    org = School.new  # this is the root
  else
    org = Department.new
    school_org = HandleSchool(root_name )
    # can't do this as nested set wants the object saved before moving!
    # org.move_to_child_of school_org if ! school_org.blank?
  end
  org.department_id = node_id
  org.name = node_label
  org.abbreviation = node_abbrev
  org.search_name = node_search_name
  org.abbreviation.strip! unless org.abbreviation.blank?
  org.search_name.strip! unless org.search_name.blank?
  org.name.strip! unless org.name.blank?
  if org.name.blank? then
    puts "org #{org.name} #{org.abbreviation}  does not have a name"
    puts data_row.inspect
  else
    existing_org = OrganizationalUnit.find_by_name(org.name) || OrganizationalUnit.find_by_abbreviation(org.abbreviation)
    if existing_org.blank? then
      org.save!
      org.move_to_child_of school_org unless school_org.blank?
      org.save
    else
      existing_org.move_to_child_of school_org if existing_org.parent_id.blank? && ! school_org.nil?
      existing_org.department_id = org.department_id if existing_org.department_id.blank?
      existing_org.name = org.name if existing_org.name.blank?
      existing_org.abbreviation = org.abbreviation if existing_org.abbreviation.blank?
      existing_org.save!
      org = existing_org
	  end
	end
	org
end

def HandleSchool(school_name)
  return nil if school_name.blank? 
  school = School.find_by_name(school_name) || School.find_by_abbreviation(school_name)
  if school.blank? then
    school = School.new
    if school_name =~ /school/i
      school.name = school_name
    else 
      school.name = school_name
      school.abbreviation = school_name
    end
    puts "creating school #{school_name}"
    school.save!
  end
  return school
end

def ReorderByAbbreviation(node=nil)
  return ReorderByAbbreviation(OrganizationalUnit.root) if node.blank?
  child_nodes = node.children
  child_nodes.each do |unit|
    right_sib = unit.right_sibling 
    if (!right_sib.blank? ) and unit.abbreviation > right_sib.abbreviation
      unit.move_right
      return ReorderByAbbreviation(node)
    end
  end
  child_nodes = node.children
  child_nodes.each do |unit|
    ReorderByAbbreviation(unit)
  end
end


def CleanUpOrganizationData()
  all = OrganizationalUnit.find_all_by_division_id(0)
  all.each do |unit|
    synthetic_division_id = unit.department_id+10
    exists = OrganizationalUnit.find_by_division_id(synthetic_division_id)
    if exists.nil?
      puts "Setting unit #{unit.name} division_id to #{synthetic_division_id}"
      unit.division_id = synthetic_division_id
      unit.save
    else
      puts "division_id #{synthetic_division_id} already exists!"
    end
  end
  all = OrganizationalUnit.all()
  all.each do |unit|
    unless unit.nil? or unit.department_id.blank? or !unit.parent_id.blank?
      parent = School.find_by_department_id(unit.department_id)
      if parent and parent.id != unit.id
        puts "Moving #{unit.name} under #{parent.name}"
        unit.parent_id = parent.id
        unit.move_to_child_of parent if ! parent.nil?
      end
    end
  end
  OrganizationalUnit.rebuild!
  all = OrganizationalUnit.all()
  all.each do |unit|
    if ! unit.nil? && ! unit.parent_id.blank? && unit.lft.nil?
      puts unit.name
      parent = OrganizationalUnit.find(unit.parent_id) 
      unit.move_to_child_of parent if ! parent.nil?
    end
  end
end


def CreateOrganizationFromHash(data_row)
    # assumed header values
    # APPOINT_FLAG
  	# CENTER_FLAG
  	# DEPT_ID
  	# DIVISION_ID
  	# DV_ABBR
  	# DV_CAMPUS_ID
  	# DV_LOCATION_ID
  	# DV_NAME
  	# DV_PHONE
  	# DV_ROOM_NUMBER
  	# DV_TYPE
  	# DV_URL
  	# LABEL_NAME
  	# SAU_ID
  	# SEARCH_NAME

    org = OrganizationalUnit.new
    org.name = data_row['NAME'] || data_row['DV_NAME'] || data_row['name'] || data_row['dv_name'] || data_row['LABEL_NAME'] || data_row['label_name']
    org.search_name = data_row['SEARCH_NAME'] || data_row['search_name'] || org.name
    org.abbreviation = data_row['ABBREVIATION'] || data_row['DV_ABBR'] || data_row['abbreviation'] || data_row['dv_abbr'] || org.name
    org.department_id = data_row['DEPT_ID'] || data_row['dept_id'] || data_row['department_id'] || data_row['DEPARTMENT_ID'] || data_row['PARENT_ID']
    org.division_id = data_row['DIVISION_ID'] || data_row['div_id'] || data_row['division_id'] || data_row['NODE_ID']
    org.organization_phone = data_row['DV_PHONE'] || data_row['PHONE'] || data_row['phone']
    org.organization_url = data_row['DV_URL'] || data_row['URL'] || data_row['dv_url']
    org.organization_classification = data_row['DV_TYPE'] || data_row['TYPE'] || data_row['dv_type'] #Research, Basic, Clinical, ??
    org.abbreviation.strip! unless org.abbreviation.blank?
    org.search_name.strip! unless org.search_name.blank?
    org.name.strip! unless org.name.blank?
    if org.name =~ /rollup/i
      return org
    end
    if !data_row['CENTER_FLAG'].blank? && data_row['CENTER_FLAG'].to_i > 0
      org.type = "Center"
    elsif org.division_id.to_s =~ /010$/ || org.division_id.to_s =~ /510$/  # 510 catches Radiation Oncology, otherwise all are 010
      org.type = "Department"
    elsif ! FindCenter(org.department_id ).nil?
      org.type = 'Program'
    elsif FindOrg(org.department_id ).type == 'Program'
      org.type = 'Program' #sub program
    else
      org.type = 'Division'
    end
    
    if org.name.blank?
      puts "org.name blank. data_row=#{data_row.inspect}, org=#{org.inspect}"
      return
    end
    
    parent_org = GetParentOrg(org)

    if org.name.blank? then
      puts "org #{org.name} #{org.search_name} #{org.abbreviation}  does not have a name"
      puts data_row.inspect
    else
      existing_org = OrganizationalUnit.find_by_name(org.name) || OrganizationalUnit.find_by_abbreviation(org.abbreviation)
      if existing_org.blank? then
        puts "creating org #{org.name} #{org.search_name} #{org.abbreviation} "
        org.save!
        org.move_to_child_of parent_org if ! parent_org.nil?
        org.save
      else
        begin
          existing_org.move_to_child_of parent_org if (! parent_org.nil?) && (existing_org.parent_id.blank? || existing_org.parent_id != parent_org.id ) && existing_org.id != parent_org.id
        rescue
          puts "failed to move #{existing_org.name} from #{existing_org.parent.name unless existing_org.parent.blank?} to #{parent_org.name}"
        end
        existing_org.department_id = org.department_id if (existing_org.department_id.blank? || existing_org.department_id == 0) && org.department_id > 0
        existing_org.division_id = org.division_id if org.division_id > 0
        existing_org.type = org.type if org.type != existing_org.type
        existing_org.name = org.name if existing_org.name.blank? or existing_org.name != org.name
        existing_org.abbreviation = org.abbreviation if ! org.abbreviation.blank?
        existing_org.organization_url = org.organization_url if existing_org.organization_url.blank?
        org_url = existing_org.organization_url
        existing_org.organization_url = "http://test.com/"
        existing_org.save!
        existing_org.organization_url = org_url
        existing_org.save!
        org = existing_org
  	  end
  	end
  	org
end
  
def GetParentOrg(org)
  return HandleSchool(LatticeGridHelper.GetDefaultSchool()) if org.type == "Department"
  return HandleSchool(LatticeGridHelper.GetDefaultSchool()) if org.type == "Center" && (org.division_id.to_s =~ /010$/ || org.division_id.to_s =~ /510$/ )
  return nil if org.department_id.blank?
  if org.type == "Program"
    return FindOrg(org.department_id)
  end
  return FindDepartment(org.department_id,'')
end

 def HasDepartment(datarow)
   return true if ! datarow["department"].blank? 
   return true if (! datarow["division_id"].blank? ) || (!datarow["DIVISION_ID"].blank?)
   return true if (! datarow["dept_id"].blank?) || (! datarow["department_id"].blank?) || (! datarow["DEPT_ID"].blank?) || (! datarow["DEPARTMENT_ID"].blank?)

   return false
 end

# process the somewhat arbitrary syntax of the way home departments, secondary appointments, and department divisions are handled.
# do I need to handle single quotes? .gsub(/\'/. '')
def SetDepartment(pi, datarow)
  # dept_id || department_id
  # division_id
  return HandleDepartment(pi,datarow) if ! datarow["department"].blank? 
  division_id = datarow["division_id"] || datarow["DIVISION_ID"]
  department_id=datarow["dept_id"] || datarow["department_id"] || datarow["DEPT_ID"] || datarow["DEPARTMENT_ID"]
  org = FindAppointingUnit(department_id,division_id)
  pi.home_department_id = org.id if !org.blank?
  return pi
end

def HandleDepartment(pi, datarow)
  # department
  return pi if datarow["department"].blank? 
  department=datarow["department"]
  # put in the string handler too
  pi.home_department_name = department
  temp, joint = department.split("/")
  department, division = temp.split("-")
  temp, joint = joint.split("=") if ! joint.blank?
  # this needs to be rewritten to use home_department_id
  home_department = nil
  if !division.blank? 
    home_department = OrganizationalUnit.find_by_name(division) 
    home_department = OrganizationalUnit.find_by_search_name(division) if home_department.blank?
    home_department = OrganizationalUnit.find_by_abbreviation(division)  if home_department.blank?
  end
  if !department.blank? and home_department.blank?
    home_department = OrganizationalUnit.find_by_name(department) 
    home_department = OrganizationalUnit.find_by_search_name(department) if home_department.blank?
    home_department = OrganizationalUnit.find_by_abbreviation(department)  if home_department.blank?
  end
  pi.home_department_id = home_department.id if !home_department.blank?
  #pi.secondary = joint.strip if ! joint.blank?
  #pi.division = division.strip if ! division.blank?
  #pi.home_department = department.strip
  return pi
end

def FindCenter(department_id)
  Center.find_by_department_id(department_id) if !department_id.blank? 
end

def FindProgram(department_id)
  Program.find_by_department_id(department_id) if !department_id.blank? 
end

def FindOrg(department_id)
  return nil if department_id.blank? 
  the_org = OrganizationalUnit.find_by_division_id(department_id, :order => 'id') 
  the_org = OrganizationalUnit.find_by_department_id(department_id, :order => 'id') if the_org.blank? 
  return the_org
end

def FindAppointingUnit(department_id,division_id)
  return OrganizationalUnit.find_by_division_id(division_id) if !division_id.blank? 
  return OrganizationalUnit.find_by_department_id(department_id) if !department_id.blank? 
  nil
end

def FindDepartment(department_id,division_id)
  return Department.find_by_division_id(division_id) if !division_id.blank? 
  return Department.find_by_department_id(department_id) if !department_id.blank? 
  nil
end

def CreateProgramFromName(department)
  return nil if department.blank?
  department.strip!
  return nil if department.blank?
  theProgram = nil
  begin
      theProgram = Program.find_by_abbreviation(department) ||
            Program.find_by_search_name(department) ||
            Program.find_by_name(department) ||
             Program.find(:first, :conditions => ["lower(name) = :name or lower(search_name) = :name or lower(abbreviation) = :name", {:name=>department.downcase }])
      puts "Could not find program #{department}" if  theProgram.blank?
      if theProgram.blank? && !department.blank? then
        max_program_number_q = Program.maximum(:sort_order)
        if max_program_number_q.blank? 
          max_program_number = 0
        else
          max_program_number = max_program_number_q
        end
        max_program_number += 1
        puts max_program_number
        theProgram = Program.create!(
          :name  => department,
          :search_name  => department,
          :abbreviation  => department,
           :sort_order => max_program_number
        )
      end
    rescue Exception => error
     puts "something happened"+error.message
     throw department.inspect
  end
  theProgram
end

def CreateProgramsFromDepartments(departments)
   departments.each do |department|
     theProgram = CreateProgramFromDepartment(department.home_department)
   end
end

def deleteUnupdatedOrganizations(orgs_to_delete)
  orgs_to_delete.each do |org|
    # if we ever want to keep this information do the following
    if (false) then
      InvestigatorAppintment.update_all({:end_date => Time.now()},['organizational_unit_id = :org_id and (end_date is NULL or end_date > :now)', {:org_id => org.id, :now => Time.now() }])
      org.end_date = Time.now()
      org.save!
    else
      InvestigatorAppointment.delete_all(['organizational_unit_id = :org_id', {:org_id => org.id}])
      OrganizationAbstract.delete_all(['organizational_unit_id = :org_id', {:org_id => org.id}])
      OrganizationalUnit.delete(org.id)
    end
  end
end    
    
    