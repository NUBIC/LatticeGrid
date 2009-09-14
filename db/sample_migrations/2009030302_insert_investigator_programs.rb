class InsertInvestigatorPrograms < ActiveRecord::Migration
  def self.up
#VO
    theProgram=Program.find_by_program_abbrev("VO")

    thePI=Investigator.find_by_email('m-hummel@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
  
#TIMA
theProgram=Program.find_by_program_abbrev("TIMA")
    thePI=Investigator.find_by_email('j-jones3@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    



    #CP
    theProgram=Program.find_by_program_abbrev("CP")

    thePI=Investigator.find_by_email('a-benson@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'

    #CC
    theProgram=Program.find_by_program_abbrev("CC")
    thePI=Investigator.find_by_email('a-apkarian@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    
    
    
    #NP
    theProgram=Program.find_by_program_abbrev("NP")
    thePI=Investigator.find_by_email('pmi@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
  end

  def self.down
    InvestigatorProgram.delete_all 
  end
end
