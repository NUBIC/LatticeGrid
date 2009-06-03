require 'fastercsv'

# -*- ruby -*-


def CreateInvestigatorFromHash(data_row)
  # assumed header values
  # employee_id
  # netid
  # email
  # last_name
  # first_name
  # mi
  # dept/div
  # category
  # basis  -- for now not using
  # rank
  # career_track
  # campus
 
  pi = Investigator.new
  pi.username = (data_row['username'].blank?) ? data_row['netid'] : data_row['username']
  pi.first_name = data_row['first_name']
  pi.middle_name = data_row['mi']
  pi.last_name = data_row['last_name']
  pi.email = data_row['email']
  pi.title = data_row['rank']
  pi.nu_employee_id = data_row['employee_id']
  pi = HandleDepartment(pi, data_row['dept/div'] )
  pi.campus = data_row['campus']
  pi.appointment_type = data_row['category']
  pi.appointment_track = data_row['career_track']
  pi.pubmed_search_name = data_row['pubmed_search_name'] if !data_row['pubmed_search_name'].blank?
  pi.pubmed_limit_to_institution = data_row['pubmed_limit_to_institution'] if !data_row['pubmed_limit_to_institution'].blank?
  if pi.username.blank? then
    puts "investigator #{pi.first_name} #{pi.last_name} does not have a username"
    puts pi.inspect
  else
    existing_pi = Investigator.find_by_username(pi.username)
    if existing_pi.blank? then
      pi.save!
    else
      existing_pi.campus = pi.campus if existing_pi.campus.blank?
      existing_pi.nu_employee_id = pi.nu_employee_id if existing_pi.nu_employee_id.blank?
      existing_pi.appointment_type = pi.appointment_type if existing_pi.appointment_type.blank?
      existing_pi.appointment_track = pi.appointment_track if existing_pi.appointment_track.blank?
      existing_pi.secondary = pi.secondary if existing_pi.secondary.blank?
      existing_pi.division = pi.division if existing_pi.division.blank?
      existing_pi.home_department = pi.home_department if existing_pi.home_department.blank?
      existing_pi.title = pi.title if existing_pi.title.blank?
      existing_pi.pubmed_search_name = pi.pubmed_search_name if existing_pi.pubmed_search_name.blank?
      existing_pi.pubmed_limit_to_institution = pi.pubmed_limit_to_institution if existing_pi.pubmed_limit_to_institution.blank?
      existing_pi.save
     end
    if ! data_row['program'].blank? then
      theProgram = Program.find_by_program_title(data_row['program']) || Program.find_by_program_abbrev(data_row['program'])
      if theProgram.blank? then
        throw "unable to match program #{data_row['program']} for user #{pi.username}"
      end
      InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => pi.id, :program_appointment => 'member', :start_date => Time.now
    end
  end
end

def ReadInvestigatorData (filename)
  errors = ""

  data = FasterCSV.read(filename, :col_sep => "\t", :headers => :first_row)
  puts Investigator.find(:all).length
  data.each do |data_row|
    begin
      CreateInvestigatorFromHash(data_row)
    rescue
      puts "something happened"+$!.message
      errors += $!.message
      puts data_row.inspect
      throw pi.inspect
    end
  end
  puts Investigator.find(:all).length
end

# process the somewhat arbitrary syntax of the way home departments, secondary appointments, and department divisions are handled.
# do I need to handle single quotes? .gsub(/\'/. '')
def HandleDepartment(pi, department)
  return pi if department.blank? 
  temp, joint = department.split("/")
  department, division = temp.split("-")
  temp, joint = joint.split("=") if ! joint.blank?
  pi.secondary = joint.strip if ! joint.blank?
  pi.division = division.strip if ! division.blank?
  pi.home_department = department.strip
  return pi
end

def CreateProgramFromDepartment(department)
  return nil if department.blank?
  theProgram = nil
  begin
      theProgram = Program.find_by_program_title(department) ||  Program.find_by_program_abbrev(department)
      if theProgram.blank? && !department.blank? then
        max_program_number_q = Program.find(:first, :select => 'max(program_number) as program_number')
        if max_program_number_q.blank? || max_program_number_q.program_number.blank?
          max_program_number = 0
        else
          max_program_number = max_program_number_q.program_number
        end
        max_program_number += 1
        puts max_program_number
        theProgram = Program.create! (
           :program_title  => department,
           :program_number => max_program_number
        )
      end
    rescue
     puts "something happened"+$!.message
     throw department.inspect
  end
  theProgram
end

def CreateProgramsFromDepartments(departments)
   departments.each do |department|
     theProgram = CreateProgramFromDepartment(department.home_department)
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
    rescue
       puts "something happened"+$!.message
       throw pi.inspect
    end
  end
end

def doCleanInvestigators(investigators)
  investigators.each do |pi|
    pi.username = pi.username.split('.')[0]
    pi.save!
  end
end
