class UpdateInvestigatorRecords < ActiveRecord::Migration
  def self.up
    Investigator.find( :all,  :conditions => ['end_date is null or end_date >= :now', {:now => Date.today }]).length
    
    Investigator.create :username => "jal286", :last_name => "Altman", :first_name => "Jessica", :middle_name => "K", :email => "j-altman@northwestern.edu"
    Investigator.create :username => "mbm363", :last_name => "Madonna", :first_name => "Mary Beth", :middle_name => "", :email => "mmadonna@childrensmemorial.org"
    Investigator.create :username => "lbianchi@enh.org", :last_name => "Bianchi", :first_name => "Laura", :middle_name => "", :email => "lbianchi@enh.org"
    Investigator.create :username => "pge203", :last_name => "Gerami", :first_name => "Pedram", :middle_name => "", :email => "pgerami@nmff.org"
    Investigator.create :username => "lje629", :last_name => "Jennings", :first_name => "Lawrence", :middle_name => "", :email => "ljennings@childrensmemorial.org"
    Investigator.create :username => "nhi230", :last_name => "Hijiya", :first_name => "Nobuko", :middle_name => "", :email => "nhijiya@childrensmemorial.org"
    Investigator.create :username => "kkh665", :last_name => "Khazaie", :first_name => "Khashayarsha", :middle_name => "", :email => "khazaie@northwestern.edu"
    Investigator.create :username => "rle202", :last_name => "Lewandowski", :first_name => "Robert", :middle_name => "", :email => "r-lewandowski@northwestern.edu"
    Investigator.create :username => "hli958", :last_name => "Li", :first_name => "Honglin", :middle_name => "", :email => "h-li2@northwestern.edu"
    Investigator.create :username => "ama702", :last_name => "Minella", :first_name => "Alexander", :middle_name => "", :email => "a-minella@northwestern.edu"
    Investigator.create :username => "wam924", :last_name => "Muller", :first_name => "William", :middle_name => "A", :email => "wamuller@northwestern.edu"
    Investigator.create :username => "mas572", :last_name => "Simon", :first_name => "Melissa", :middle_name => "", :email => "m-simon2@northwestern.edu"
    Investigator.create :username => "qzh758", :last_name => "Zhang", :first_name => "Qiang", :middle_name => "", :pubmed_limit_to_institution => true, :email => "q-zhang2@northwestern.edu"

    Investigator.find( :all,  :conditions => ['end_date is null or end_date >= :now', {:now => Date.today }]).length

    theProgram=Program.find_by_program_abbrev("HAST")
    thePI=Investigator.find_by_email('j-altman@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-NOV-2007'

    theProgram=Program.find_by_program_abbrev("HM")
    thePI=Investigator.find_by_email('j-altman@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-NOV-2007'
 
    theProgram=Program.find_by_program_abbrev("TIMA")
    thePI=Investigator.find_by_email('wamuller@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-OCT-2007'

    theProgram=Program.find_by_program_abbrev("CGMT")
    thePI=Investigator.find_by_email('ljennings@childrensmemorial.org')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-OCT-2007'

    theProgram=Program.find_by_program_abbrev("CCB")
    thePI=Investigator.find_by_email('a-minella@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-OCT-2007'
    thePI=Investigator.find_by_email('h-li2@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-OCT-2007'

    theProgram=Program.find_by_program_abbrev("BC")
    thePI=Investigator.find_by_email('a-minella@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-OCT-2007'

    theProgram=Program.find_by_program_abbrev("PRO")
    thePI=Investigator.find_by_email('q-zhang2@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-OCT-2007'
 
    theProgram=Program.find_by_program_abbrev("CP")
    thePI=Investigator.find_by_email('lbianchi@enh.org')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-OCT-2007'
    thePI=Investigator.find_by_email('khazaie@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-OCT-2007'
    thePI=Investigator.find_by_email('m-simon2@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-OCT-2007'
 
    theProgram=Program.find_by_program_abbrev("CC")
    thePI=Investigator.find_by_email('nhijiya@childrensmemorial.org')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-OCT-2007'
    thePI=Investigator.find_by_email('m-simon2@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-OCT-2007'

    theProgram=Program.find_by_program_abbrev("NP")
    thePI=Investigator.find_by_email('pgerami@nmff.org')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-OCT-2007'
    thePI=Investigator.find_by_email('r-lewandowski@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-OCT-2007'
    thePI=Investigator.find_by_email('mmadonna@childrensmemorial.org')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-NOV-2007'
 
 # removals
    thePI=Investigator.find_by_email('h-band@northwestern.edu')
    thePI.update_attribute( :end_date, '30-SEP-2007')
    thePI.investigator_programs.find(:all).each { | ip | ip.update_attribute( :end_date, '30-SEP-2007') }

    thePI=Investigator.find_by_email('v-band@northwestern.edu')
    thePI.update_attribute( :end_date, '30-SEP-2007')
    thePI.investigator_programs.find(:all).each { | ip | ip.update_attribute( :end_date, '30-SEP-2007') }

    thePI=Investigator.find_by_email('e-paps@northwestern.edu')
    thePI.update_attribute( :end_date, '30-SEP-2007')
    thePI.investigator_programs.find(:all).each { | ip | ip.update_attribute( :end_date, '30-SEP-2007') }

   end

  def self.down
    thePI=Investigator.find_by_email('h-band@northwestern.edu')
    thePI.update_attribute( :end_date, nil)
    thePI.investigator_programs.find(:all).each { | ip | ip.update_attribute( :end_date, nil) }

    thePI=Investigator.find_by_email('v-band@northwestern.edu')
    thePI.update_attribute( :end_date, nil)
    thePI.investigator_programs.find(:all).each { | ip | ip.update_attribute( :end_date, nil) }
 
    thePI=Investigator.find_by_email('e-paps@northwestern.edu')
    thePI.update_attribute( :end_date, nil)
    thePI.investigator_programs.find(:all).each { | ip | ip.update_attribute( :end_date, nil) }

 
 # remove new members
    thePI=Investigator.find_by_email('pgerami@nmff.org')
    thePI.investigator_programs.each {|ip| ip.destroy() }
    thePI.destroy()

    thePI=Investigator.find_by_email('j-altman@northwestern.edu')
    thePI.investigator_programs.each {|ip| ip.destroy() }
    thePI.destroy()
  
    thePI=Investigator.find_by_email('mmadonna@childrensmemorial.org')
    thePI.investigator_programs.each {|ip| ip.destroy() }
    thePI.destroy()
  
    thePI=Investigator.find_by_email('lbianchi@enh.org')
    thePI.investigator_programs.each {|ip| ip.destroy() }
    thePI.destroy()
  
    thePI=Investigator.find_by_email('nhijiya@childrensmemorial.org')
    thePI.investigator_programs.each {|ip| ip.destroy() }
    thePI.destroy()
  
    thePI=Investigator.find_by_email('ljennings@childrensmemorial.org')
    thePI.investigator_programs.each {|ip| ip.destroy() }
    thePI.destroy()
  
    thePI=Investigator.find_by_email('khazaie@northwestern.edu')
    thePI.investigator_programs.each {|ip| ip.destroy() }
    thePI.destroy()
  
    thePI=Investigator.find_by_email('r-lewandowski@northwestern.edu')
    thePI.investigator_programs.each {|ip| ip.destroy() }
    thePI.destroy()
 
    thePI=Investigator.find_by_email('h-li2@northwestern.edu')
    thePI.investigator_programs.each {|ip| ip.destroy() }
    thePI.destroy()
  
    thePI=Investigator.find_by_email('a-minella@northwestern.edu')
    thePI.investigator_programs.each {|ip| ip.destroy() }
    thePI.destroy()
  
    thePI=Investigator.find_by_email('wamuller@northwestern.edu')
    thePI.investigator_programs.each {|ip| ip.destroy() }
    thePI.destroy()
  
    thePI=Investigator.find_by_email('m-simon2@northwestern.edu')
    thePI.investigator_programs.each {|ip| ip.destroy() }
    thePI.destroy()
  
    thePI=Investigator.find_by_email('q-zhang2@northwestern.edu')
    thePI.investigator_programs.each {|ip| ip.destroy() }
    thePI.destroy()
  end
end

