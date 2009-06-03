class UpdateInvestigatorRecords4 < ActiveRecord::Migration
  def self.up
    puts Investigator.find( :all,  :conditions => ['end_date is null or end_date >= :now', {:now => Date.today }]).length
    
    Investigator.create :username => "mhe663", :last_name => "Hersam", :first_name => "Mark", :email => "m-hersam@northwestern.edu"
    Investigator.create :username => "ema212", :last_name => "Marsh", :first_name => "Erica", :middle_name => 'E', :email => "erica-marsh@md.northwestern.edu"
    Investigator.create :username => "hwp673", :last_name => "Pinkett", :first_name => "Heather", :middle_name => 'W', :email => "h-pinkett@northwestern.edu"
    Investigator.create :username => "asc380", :last_name => "Stegh", :first_name => "Alexander", :middle_name => 'H', :email => "a-stegh@northwestern.edu"
 
    theProgram=Program.find_by_program_abbrev("CGMT")
    thePI=Investigator.find_by_email("m-hersam@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-MAR-2009'
    thePI=Investigator.find_by_email("h-pinkett@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-MAR-2009'


    theProgram=Program.find_by_program_abbrev("HM")
    thePI=Investigator.find_by_email("nhijiya@childrensmemorial.org")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-MAR-2009'

    theProgram=Program.find_by_program_abbrev("HAST")
    thePI=Investigator.find_by_email("erica-marsh@md.northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-MAR-2009'
    
    theProgram=Program.find_by_program_abbrev("NP")
    thePI=Investigator.find_by_email("a-stegh@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-MAR-2009'
    
   # removals
   thePI=Investigator.find_by_email('b-pasche@northwestern.edu')
   thePI.update_attribute( :end_date, '28-FEB-2009')
   thePI.investigator_programs.find(:all).each { | ip | ip.update_attribute( :end_date, '01-JAN-2009') }

   puts Investigator.find( :all,  :conditions => ['end_date is null or end_date >= :now', {:now => Date.today }]).length
 

   end

  def self.down
    thePI=Investigator.find_by_email('b-pasche@northwestern.edu')
    thePI.update_attribute( :end_date, nil)
    thePI.investigator_programs.find(:all).each { | ip | ip.update_attribute( :end_date, nil) }

 
 # remove new members
    thePI=Investigator.find_by_email("m-hersam@northwestern.edu")
    thePI.investigator_programs.each {|ip| ip.destroy() }
    thePI.destroy()

  end
end

