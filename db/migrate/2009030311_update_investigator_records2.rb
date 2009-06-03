class UpdateInvestigatorRecords2 < ActiveRecord::Migration
  def self.up
    puts Investigator.find( :all,  :conditions => ['end_date is null or end_date >= :now', {:now => Date.today }]).length
    
    Investigator.create :username => "sge340", :last_name => "Getsios", :first_name => "Spiro", :middle_name => "", :email => "s-getsios@northwestern.edu"
    Investigator.create :username => "ath523", :last_name => "Thompson", :first_name => "Alexis", :middle_name => "", :email => "a-thompson@northwestern.edu"
    Investigator.create :username => "smt546", :last_name => "Troyanovsky", :first_name => "Sergey", :middle_name => "", :email => "s-troyanovsky@northwestern.edu"
    Investigator.create :username => "xya379", :last_name => "Yang", :first_name => "Ximing", :middle_name => "", :email => "xyang@northwestern.edu"
    Investigator.create :username => "blh670", :last_name => "Hitsman", :first_name => "Brian", :middle_name => "", :email => "b-hitsman@northwestern.edu"
    Investigator.create :username => "gqi114", :last_name => "Qin", :first_name => "Gangjian", :middle_name => "", :email => "g-qin@northwestern.edu"
 
    puts Investigator.find( :all,  :conditions => ['end_date is null or end_date >= :now', {:now => Date.today }]).length

    theProgram=Program.find_by_program_abbrev("TIMA")
    thePI=Investigator.find_by_email('s-getsios@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-JAN-2008'
 
    theProgram=Program.find_by_program_abbrev("TIMA")
    thePI=Investigator.find_by_email('s-troyanovsky@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2008'


    theProgram=Program.find_by_program_abbrev("PRO")
    thePI=Investigator.find_by_email('xyang@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2008'
 

    theProgram=Program.find_by_program_abbrev("NP")
    thePI=Investigator.find_by_email('a-thompson@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2008'

    theProgram=Program.find_by_program_abbrev("TIMA")
     thePI=Investigator.find_by_email('g-qin@northwestern.edu')
     InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-MAR-2008'
 
     theProgram=Program.find_by_program_abbrev("CP")
      thePI=Investigator.find_by_email('b-hitsman@northwestern.edu')
      InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-MAR-2008'

      theProgram=Program.find_by_program_abbrev("CC")
       thePI=Investigator.find_by_email('b-hitsman@northwestern.edu')
       InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-MAR-2008'

 
 # removals

   end

  def self.down
 
 # remove new members
    thePI=Investigator.find_by_email('s-getsios@northwestern.edu')
    thePI.investigator_programs.each {|ip| ip.destroy() }
    thePI.destroy()

    thePI=Investigator.find_by_email('a-thompson@northwestern.edu')
    thePI.investigator_programs.each {|ip| ip.destroy() }
    thePI.destroy()
  
    thePI=Investigator.find_by_email('s-troyanovsky@northwestern.edu')
    thePI.investigator_programs.each {|ip| ip.destroy() }
    thePI.destroy()
  
    thePI=Investigator.find_by_email('xyang@northwestern.edu')
    thePI.investigator_programs.each {|ip| ip.destroy() }
    thePI.destroy()
  
    thePI=Investigator.find_by_email('b-hitsman@northwestern.edu')
    thePI.investigator_programs.each {|ip| ip.destroy() }
    thePI.destroy()
  
    thePI=Investigator.find_by_email('g-qin@northwestern.edu')
    thePI.investigator_programs.each {|ip| ip.destroy() }
    thePI.destroy()
  
  end
end

