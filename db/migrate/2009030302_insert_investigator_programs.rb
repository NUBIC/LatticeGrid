class InsertInvestigatorPrograms < ActiveRecord::Migration
  def self.up
  # left in July 2007  Investigator.create :username => "aba461", :last_name => "Barron", :first_name => "Annelise", :middle_name => "E", :email => "a-barron@northwestern.edu"
  # no longer a member for 2007. Investigator.create :username => "sbe345", :last_name => "Belknap", :first_name => "Steven", :middle_name => "M", :email => "sbelknap@northwestern.edu"
  # dropped summer 07   Investigator.create :username => "dad805", :last_name => "Dean", :first_name => "David", :middle_name => "", :email => "a-lam4@md.northwestern.edu"
  # dropped summer 07   Investigator.create :username => "rde674", :last_name => "Derry", :first_name => "Robbin", :middle_name => "", :email => "r-derry@kellogg.northwestern.edu"
  # dropped summer 07    Investigator.create :username => "reh848", :last_name => "Hendrick", :first_name => "R", :middle_name => "Edward", :email => "r-hendrick@northwestern.edu"
  # dropped summer 07    Investigator.create :username => "lhi959", :last_name => "Hicke", :first_name => "Linda", :middle_name => "Anne", :pubmed_search_name => "Hicke Linda", :email => "l-hicke@northwestern.edu"
  # dropped summer 07    Investigator.create :username => "tsj652", :last_name => "Jardetzky", :first_name => "Theodore", :middle_name => "S", :pubmed_search_name => "Jardetzky T S", :email => "tedj@northwestern.edu"
  # left summer of 07    Investigator.create :username => "mrp881", :last_name => "Pins", :first_name => "Michael", :middle_name => "R", :email => "m-pins@northwestern.edu"
  # dropped summer 07    Investigator.create :username => "rls720", :last_name => "Satcher", :first_name => "Robert", :middle_name => "L.", :email => "r-satcher@northwestern.edu"
  # left summer 07   Investigator.create :username => "mss130", :last_name => "Stack", :first_name => "M.", :middle_name => "Sharon", :email => "mss130@northwestern.edu"
  # dropped summer 07    Investigator.create :username => "eyx963", :last_name => "Xu", :first_name => "Eugene", :middle_name => "Y", :email => "e-xu@northwestern.edu"
  # dropped summer 07    Investigator.create :username => "xya379", :last_name => "Yang", :first_name => "Ximing", :middle_name => "J.", :email => "xyang@northwestern.edu"

#VO
    theProgram=Program.find_by_program_abbrev("VO")
    thePI=Investigator.find_by_email('v-band@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('thope@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('horvath@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('m-hummel@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('l-laimins@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('ralamb@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('j-leis@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('limingli@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('r-longnecker@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('larry-pinto@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('krundell@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('pseth@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('g-smith3@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('p-spear@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('b-thimmapaya@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
  
#TIMA
theProgram=Program.find_by_program_abbrev("TIMA")
    thePI=Investigator.find_by_email('i-awad@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('beitel@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('nav@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('achenn@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('t-chew@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('scrawford@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('vgelfand@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('r-goldman@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('a-gonzalez2@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('c-gottardi@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('kgreen@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('mjchendrix@childrensmemorial.org')  
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('j-jones3@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('gsk@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('zellis@childrensmemorial.org')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('m-kibbe@md.northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('jkramer@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('clabonne@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('mlamm@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('h-munshi@md.northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('t-mustoe@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('apaller@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('s-rice@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('schnaper@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('p-schumacker@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('rseftor@childrensmemorial.org')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('l-shea@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('j-varga@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('olgavolp@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('x-wang1@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('awang@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('m-zhang@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    
    
    #HAST
    theProgram=Program.find_by_program_abbrev("HAST")
    thePI=Investigator.find_by_email('h-band@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('dbentrem@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('i-budunova@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('s-bulun@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('debu@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('chengc@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('clevenger@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('freymann@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('p-grippo@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('a-gross@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('x-he@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('k-iwasaki@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('ljameson@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('j-kim4@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('dlinzer@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('nickzlu@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('r-lupu@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('k-mayo@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('j-pelling@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('l-platanias@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('grodriguez@enh.org')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('s-rosen@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('p-stein2@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('tkw@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    
    #CGMT
    theProgram=Program.find_by_program_abbrev("CGMT")
    
    thePI=Investigator.find_by_email('wf-anderson@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('v-backman@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('m-bredel@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('r-chisholm@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('d-ho@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('bmh@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('s-huang2@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('k-kaul@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('levenson@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('tmeade@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('c-mirkin@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('a-mondragon@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('j-moskal@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('stn@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('t-ohalloran@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('t-ouchi@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('b-pasche@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('eperlman@childrensmemorial.org')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('i-radhakrishnan@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('amyr@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('rsc248@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('scheidt@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('r-silverman@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('mbsoares@childrensmemorial.org')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('s-stupp@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('r-thomson@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('swang1@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('j-widom@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('g-woloschak@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('g-yang@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    
    #CCB
    theProgram=Program.find_by_program_abbrev("CCB")
    thePI=Investigator.find_by_email('h-ardehali@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('j-brickner@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('r-carthew@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('j-crispino@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('v-cryns@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('g-dimri@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('e-eklund@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('h-folsch@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('q-gao@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('r-holmgren@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('jakessler@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('kiyokawa@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('j-licht@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('j-lomasney@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('matouschek@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('t-mcgarry@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('r-miller10@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('r-morimoto@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('s-rao@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('jkreddy@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('h-roy@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('erik@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('o-uhlenbeck@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('t-volpe2@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('rwali@enh.org')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('elweiss@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('jane-wu@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('n-yaseen@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    
    
    #BC
    theProgram=Program.find_by_program_abbrev("BC")
    thePI=Investigator.find_by_email('h-band@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('v-band@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('s-bulun@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('debu@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('dsc@radiology.northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('chat@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('t-chew@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('m-cianfrocca@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('clevenger@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('v-cryns@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('g-dimri@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('q-gao@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('m-goel@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('w-gradishar@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('nhansen@nmh.org')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('jjeruss@nmh.org')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('v-kaklamani@md.northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('s-khan2@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('wakibbe@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('dkirsch@childrensmemorial.org')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('kiyokawa@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('a-levenson@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('xuli@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('r-lupu@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('t-ouchi@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('w-rubinstein@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('lvanhorn@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('s-weitzman@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('m-zhang@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('y-zhu2@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'

    #PRO
    theProgram=Program.find_by_program_abbrev("PRO")
    thePI=Investigator.find_by_email('cbenne@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('r-bergan@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('cbrendler@enh.org')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('w-catalona@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('nav@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('scrawford@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('sgapstur@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('r-goldman@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('k-kaul@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('wakibbe@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('t-kuzel@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('mlamm@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('c-lee7@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('g-macvicar@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('k-mcvary@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('tmeade@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('c-mirkin@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('ajschaeffer@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('d-shevrin@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('p-stern@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('olgavolp@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('g-woloschak@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'

    #HM
    theProgram=Program.find_by_program_abbrev("HM")
    thePI=Investigator.find_by_email('m-brown12@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('bchiu@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('j-crispino@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('e-eklund@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('a-evens@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('c-goolsby@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('l-gordon@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('j-guitart@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('djacobsohn@childrensmemorial.org')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('gsk@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('mkletzel@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('n-krett@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('t-kuzel@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('j-licht@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('r-longnecker@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('j-mehta@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('wmmiller@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('t-ohalloran@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('loannc@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('l-platanias@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('s-rosen@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('s-singhal@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('p-stein2@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('m-tallman@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('lwagner@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('swang1@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('s-winandy@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('j-winter@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('n-yaseen@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'

    #CP
    theProgram=Program.find_by_program_abbrev("CP")
    thePI=Investigator.find_by_email('v-backman@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('tabarrett@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('a-benson@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('r-bergan@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('s-bulun@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('w-catalona@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('dsc@radiology.northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('chat@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('bchiu@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('lynette-craft@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('sgapstur@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('m-goel@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('l-hou@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('v-kaklamani@md.northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('d-kamp@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('s-khan2@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('xuli@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('gylocker@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('m-martini@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('b-pasche@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('j-pelling@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('drpugh@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('wtbjkr@rcn.com')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('grodriguez@enh.org')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('h-roy@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('w-rubinstein@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('jschink@nmff.org')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('d-singh2@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('bspring@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('lvanhorn@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('g-yang@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'

    #CC
    theProgram=Program.find_by_program_abbrev("CC")
    thePI=Investigator.find_by_email('a-apkarian@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('cbenne@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('d-cella@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('chchang@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('m-clayman@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('l-emanuel@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('anoveros@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('sgoldman@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('e-hahn@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('a-heinemann@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('m-lacouture@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('js-lai@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('j-logemann@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('makoul@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('j-mckoy@md.northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('k-mcvary@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('d-mohr@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('j-paice@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('w-small@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('j-vonroenn@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('lwagner@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('mswolf@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('tkw@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('simon-yoo@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('kyost@enh.org')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('s-yount@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    
    #NP
    theProgram=Program.find_by_program_abbrev("NP")
    thePI=Investigator.find_by_email('d-engman@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('sean-grimm@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('pmi@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('j-khandekar@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('p-kopp@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('bmittal@nmh.org')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('m-mulcahy@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('reed@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('jd-patel@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('rmp158@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('rademaker@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('j-raizer@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('r-salem@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('mtalamonti@enh.org')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('warren@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('vaneldik@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('d-walterhouse@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('m-watterson@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('a-yasko@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('rleikin@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('schallma@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    thePI=Investigator.find_by_email('t-volpe@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
    
    #Assoc
#    theProgram=Program.find_by_program_abbrev("Assoc")
#    thePI=Investigator.find_by_email('jchmiel@northwestern.edu')
#    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
#    thePI=Investigator.find_by_email('dscholtens@northwestern.edu')
#    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
#    thePI=Investigator.find_by_email('borko@northwestern.edu')
#    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'
#    thePI=Investigator.find_by_email('huangcc@northwestern.edu')
#    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-SEP-2007'

  end

  def self.down
    InvestigatorProgram.delete_all 
  end
end
