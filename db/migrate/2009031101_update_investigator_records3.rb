class UpdateInvestigatorRecords3 < ActiveRecord::Migration
  def self.up
    puts Investigator.find( :all,  :conditions => ['end_date is null or end_date >= :now', {:now => Date.today }]).length
    
    Investigator.create :username => "mag641", :last_name => "Agulnik", :first_name => "Mark", :email => "m-agulnik@northwestern.edu"
    Investigator.create :username => "sba689", :last_name => "Basti", :first_name => "Surendra", :email => "sbasti@northwestern.edu"
    Investigator.create :username => "alb635", :last_name => "Buchman", :first_name => "Alan", :email => "a-buchman@northwestern.edu"
    Investigator.create :username => "ecz500", :last_name => "Chen", :first_name => "Zong-ming Eric", :email => "zchen@northwestern.edu"
    Investigator.create :username => "nco146", :last_name => "Contractor", :first_name => "Noshir", :email => "nosh@northwestern.edu"
    Investigator.create :username => "scl669", :last_name => "Corey", :first_name => "Seth", :email => "s-corey@northwestern.edu"
    Investigator.create :username => "vpdravid", :last_name => "Dravid", :first_name => "Vinayak", :email => "v-dravid@northwestern.edu"
    Investigator.create :username => "ofr043", :last_name => "Frankfurt", :first_name => "Olga", :email => "o-frankfurt@northwestern.edu"
    Investigator.create :username => "glg377", :last_name => "Gamble", :first_name => "Gail", :email => "ggamble@ric.org"
    Investigator.create :username => "pgreenld", :last_name => "Greenland", :first_name => "Philip", :email => "p-greenland@northwestern.edu"
    Investigator.create :username => "bgr639", :last_name => "Grzybowski", :first_name => "Bartosz", :email => "grzybor@northwestern.edu"
    Investigator.create :username => "aha385", :last_name => "Harris", :first_name => "Ann", :email => "ann-harris@northwestern.edu"
    Investigator.create :username => "wkarpus", :last_name => "Karpus", :first_name => "William", :email => "w-karpus@northwestern.edu"
    Investigator.create :username => "mkletzel", :last_name => "Kletzel", :first_name => "Morris", :email => "mkletzel@northwestern.edu"
    Investigator.create :username => "jek902", :last_name => "Koblinski", :first_name => "Jennifer", :email => "j-koblinski@northwestern.edu"
    Investigator.create :username => "stk897", :last_name => "Kosak", :first_name => "Steven", :email => "s-kosak@northwestern.edu"
    Investigator.create :username => "ivk770", :last_name => "Kourkine", :first_name => "Igor", :email => "i-kourkine@northwestern.edu"
    Investigator.create :username => "lmk445", :last_name => "Kulik", :first_name => "Laura", :email => "l-kulik@northwestern.edu"
    Investigator.create :username => "cla486", :last_name => "Larson", :first_name => "Andrew", :email => "a-larson@northwestern.edu"
    Investigator.create :username => "nal829", :last_name => "Laurie", :first_name => "Nikia", :email => "nlaurie@childrensmemorial.org"
    Investigator.create :username => "jnl186", :last_name => "Leonard", :first_name => "Joshua", :email => "j-leonard@northwestern.edu"
    Investigator.create :username => "dlr363", :last_name => "Losordo", :first_name => "Douglas", :email => "d-losordo@northwestern.edu"
    Investigator.create :username => "sma160", :last_name => "Ma", :first_name => "Shuo", :email => "shuo-ma@northwestern.edu"
    Investigator.create :username => "ycm569", :last_name => "Ma", :first_name => "YongChao", :email => "ma@northwestern.edu"
    Investigator.create :username => "dmm685", :last_name => "Mahvi", :first_name => "David", :email => "dmahvi@nmh.org"
    Investigator.create :username => "fma674", :last_name => "Mauvais-Jarvis", :first_name => "Franck", :email => "f-mauvais-jarvis@northwestern.edu"
    Investigator.create :username => "pbm864", :last_name => "Messersmith", :first_name => "Phillip", :email => "philm@northwestern.edu"
    Investigator.create :username => "bmd525", :last_name => "Mitchell", :first_name => "Brian", :email => "brian-mitchell@northwestern.edu"
    Investigator.create :username => "hsn718", :last_name => "Nimeiri", :first_name => "Halla", :email => "h-nimeiri@northwestern.edu"
    Investigator.create :username => "pho669", :last_name => "Ozdinler", :first_name => "Hande", :email => "ozdinler@northwestern.edu"
    Investigator.create :username => "mrr427", :last_name => "Ring", :first_name => "Melinda", :email => "mring@nmh.org"
    Investigator.create :username => "kgs935", :last_name => "Scandrett", :first_name => "Karen", :email => "kgscandrett@northwestern.edu"
    Investigator.create :username => "jws467", :last_name => "Shega", :first_name => "Joseph", :email => "j-shega@northwestern.edu"
    Investigator.create :username => "dks980", :last_name => "Shumaker", :first_name => "Dale", :email => "dshumake@northwestern.edu"
    Investigator.create :username => "jfs928", :last_name => "Stoddart", :first_name => "James", :email => "stoddart@northwestern.edu"
    Investigator.create :username => "cst694", :last_name => "Thaxton", :first_name => "C. Shad", :email => "cthaxton003@md.northwestern.edu"
    Investigator.create :username => "cwi685", :last_name => "Wang", :first_name => "Chyung-Ru", :email => "chyung-ru-wang@northwestern.edu"
    Investigator.create :username => "jwg499", :last_name => "Wei", :first_name => "Jian-Jun", :email => "jianjun-wei@northwestern.edu"
    Investigator.create :username => "eyx963", :last_name => "Xu", :first_name => "Eugene", :email => "e-xu@northwestern.edu"

    puts Investigator.find( :all,  :conditions => ['end_date is null or end_date >= :now', {:now => Date.today }]).length

    theProgram=Program.find_by_program_abbrev("NP")
    thePI=Investigator.find_by_email("m-agulnik@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
    thePI=Investigator.find_by_email("zchen@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
    thePI=Investigator.find_by_email("i-kourkine@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
    thePI=Investigator.find_by_email("l-kulik@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
    thePI=Investigator.find_by_email("dmahvi@nmh.org")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'



    theProgram=Program.find_by_program_abbrev("CC")
    thePI=Investigator.find_by_email("sbasti@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
    thePI=Investigator.find_by_email("a-buchman@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
    thePI=Investigator.find_by_email("nosh@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
    thePI=Investigator.find_by_email("ggamble@ric.org")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
    thePI=Investigator.find_by_email("kgscandrett@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
    thePI=Investigator.find_by_email("j-shega@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
 

    theProgram=Program.find_by_program_abbrev("CP")
    thePI=Investigator.find_by_email("nosh@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
    thePI=Investigator.find_by_email("p-greenland@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
    thePI=Investigator.find_by_email("h-nimeiri@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
    thePI=Investigator.find_by_email('d-mohr@northwestern.edu')
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'


    theProgram=Program.find_by_program_abbrev("TIMA")
    thePI=Investigator.find_by_email("ann-harris@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
    thePI=Investigator.find_by_email("j-koblinski@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
    thePI=Investigator.find_by_email("a-larson@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
    thePI=Investigator.find_by_email("d-losordo@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'


    theProgram=Program.find_by_program_abbrev("BC")
    thePI=Investigator.find_by_email("j-koblinski@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'

    theProgram=Program.find_by_program_abbrev("CCB")
    thePI=Investigator.find_by_email("s-kosak@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
    thePI=Investigator.find_by_email("brian-mitchell@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
    thePI=Investigator.find_by_email("jianjun-wei@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'


    theProgram=Program.find_by_program_abbrev("HM")
    thePI=Investigator.find_by_email("o-frankfurt@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
    thePI=Investigator.find_by_email("s-kosak@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
    thePI=Investigator.find_by_email("mkletzel@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
    thePI=Investigator.find_by_email("s-corey@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
    thePI=Investigator.find_by_email("shuo-ma@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'

    theProgram=Program.find_by_program_abbrev("CGMT")
    thePI=Investigator.find_by_email("nlaurie@childrensmemorial.org")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
    thePI=Investigator.find_by_email("j-leonard@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
    thePI=Investigator.find_by_email("philm@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
    thePI=Investigator.find_by_email("v-dravid@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
    thePI=Investigator.find_by_email("grzybor@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'

    theProgram=Program.find_by_program_abbrev("HAST")
    thePI=Investigator.find_by_email("ma@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
    thePI=Investigator.find_by_email("f-mauvais-jarvis@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
    thePI=Investigator.find_by_email("s-corey@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
    thePI=Investigator.find_by_email("w-karpus@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'


    theProgram=Program.find_by_program_abbrev("TIMA")
    thePI=Investigator.find_by_email("ozdinler@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
    thePI=Investigator.find_by_email("dshumake@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'

    theProgram=Program.find_by_program_abbrev("CC")
    thePI=Investigator.find_by_email("mring@nmh.org")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'

    theProgram=Program.find_by_program_abbrev("PRO")
    thePI=Investigator.find_by_email("dshumake@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
     thePI=Investigator.find_by_email("cthaxton003@md.northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
    thePI=Investigator.find_by_email("jianjun-wei@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'

    theProgram=Program.find_by_program_abbrev("CGMT")
    thePI=Investigator.find_by_email("stoddart@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
    thePI=Investigator.find_by_email("cthaxton003@md.northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
    thePI=Investigator.find_by_email("e-xu@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'


    theProgram=Program.find_by_program_abbrev("HAST")
    thePI=Investigator.find_by_email("chyung-ru-wang@northwestern.edu")
    InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'

# create new program - GI

theProgram=Program.find_by_program_abbrev("GI")
thePI=Investigator.find_by_email("zchen@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("ann-harris@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("l-kulik@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("a-larson@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("dmahvi@nmh.org")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("h-nimeiri@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("chyung-ru-wang@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'

# existing members added to GI
thePI=Investigator.find_by_email("v-backman@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("tabarrett@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("cbenne@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("a-benson@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("dbentrem@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("lbianchi@enh.org")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("lynette-craft@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("sgapstur@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("p-grippo@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("v-kaklamani@md.northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("khazaie@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("r-lewandowski@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("tmeade@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("m-mulcahy@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("h-munshi@md.northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("reed@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("drpugh@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("s-rao@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("jkreddy@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("h-roy@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("r-salem@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("mtalamonti@enh.org")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("rwali@enh.org")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("g-yang@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'

# create new program - PO


theProgram=Program.find_by_program_abbrev("PO")
thePI=Investigator.find_by_email("s-corey@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("mkletzel@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("nlaurie@childrensmemorial.org")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("ma@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'

#existing members added to PO

thePI=Investigator.find_by_email("sgoldman@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("mjchendrix@childrensmemorial.org")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("nhijiya@childrensmemorial.org")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("pmi@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("djacobsohn@childrensmemorial.org")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("ljennings@childrensmemorial.org")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("h-li2@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("mmadonna@childrensmemorial.org")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("apaller@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("eperlman@childrensmemorial.org")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("schnaper@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("p-schumacker@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("mbsoares@childrensmemorial.org")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("a-thompson@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("d-walterhouse@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'
thePI=Investigator.find_by_email("x-wang1@northwestern.edu")
InvestigatorProgram.create :program_id => theProgram.id, :investigator_id => thePI.id, :program_appointment => 'member', :start_date => '01-FEB-2009'


 # removals
 thePI=Investigator.find_by_email('dlinzer@northwestern.edu')
 thePI.update_attribute( :end_date, '30-JAN-2009')
 thePI.investigator_programs.find(:all).each { | ip | ip.update_attribute( :end_date, '01-JAN-2009') }

 thePI=Investigator.find_by_email('makoul@northwestern.edu')
 thePI.update_attribute( :end_date, '30-JAN-2009')
 thePI.investigator_programs.find(:all).each { | ip | ip.update_attribute( :end_date, '01-JAN-2009') }

 thePI=Investigator.find_by_email('n-yaseen@northwestern.edu')
 thePI.update_attribute( :end_date, '30-JAN-2009')
 thePI.investigator_programs.find(:all).each { | ip | ip.update_attribute( :end_date, '01-JAN-2009') }

 thePI=Investigator.find_by_email('scrawford@northwestern.edu')
 thePI.update_attribute( :end_date, '30-JAN-2009')
 thePI.investigator_programs.find(:all).each { | ip | ip.update_attribute( :end_date, '01-JAN-2009') }

 thePI=Investigator.find_by_email('levenson@northwestern.edu')
 thePI.update_attribute( :end_date, '30-JAN-2009')
 thePI.investigator_programs.find(:all).each { | ip | ip.update_attribute( :end_date, '30-SEP-2008') }

 thePI=Investigator.find_by_email('gylocker@northwestern.edu')
 thePI.update_attribute( :end_date, '30-JAN-2009')
 thePI.investigator_programs.find(:all).each { | ip | ip.update_attribute( :end_date, '01-JAN-2009') }



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

  end
end

