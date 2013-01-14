require 'investigator_appointment_utilities'

namespace :cleanup do
  
  task :countries => :environment do
    clean_country("Australia","Australia")
    clean_country("Belgium","Belgium")
    clean_country("Brazil","Brazil")
    clean_country("Canada","Canada")
    clean_country("CH,Switzerland,Swistzerland","Switzerland")
    clean_country("DE,Germany,Ger","Germany")
    clean_country("England,U.K.,UK,United Kingdom,United Kingdon,United-Kingdom","United Kingdom")
    clean_country("France","France")
    clean_country("India","India")
    clean_country("Brazil","Brazil")
    clean_country("U.S.A.,United States,United States of America,US","United States of America")
    clean_country("Netherlands,The Netherlands","Netherlands")
    
  end
  
  task :email => :environment do
    Investigator.update_all("email = lower(email)") 
  end

  task :employee_ids => :environment do
    pis = Investigator.all(:conditions=>"investigators.employee_id is null") 
    puts "#{pis.length} investigators have a null employee_id"
    pis.each do |pi|
      puts "#{pi.name}\t#{pi.email}\t#{pi.username}\t#{pi.employee_id}"
    end
  end
  
  task :titles => :environment do
    pis = Investigator.all(:conditions=>"investigators.title is not null") 
    puts "#{pis.length} investigators have a title"
    clean_cnt = 0
    pis.each do |pi|
      title = pi.title
      CleanTitle(pi)
      if pi.title != title
        clean_cnt+=1
        pi.save! 
      end
    end
    puts "#{clean_cnt} investigator titles cleaned"
  end
  
  task :update_titles_and_home_from_ldap => :environment do
    pis = Investigator.all() 
    puts "#{pis.length} investigators"
    clean_cnt = 0
    pis.each do |pi|
      title = pi.title
      home_department_name = pi.home_department_name
      pi = UpdateHomeDepartmentAndTitle(pi)
      if pi.title != title or pi.home_department_name != home_department_name
        clean_cnt+=1
        pi.save! 
      end
    end
    puts "#{clean_cnt} investigator titles and/or home departments updated"
  end
  
  
  task :insert_employee_ids => :environment do
    username_hash = {'bmd525'=>'1068930',
    'cgo790'=>'1056845',
    'chat'=>'1001981',
    'cinnmosk'=>'1017923',
    'clg879'=>'1000176',
    'dev577'=>'1061814',
    'dhj204'=>'1063577',
    'fma674'=>'1063244',
    'gew111'=>'1051283',
    'hgm988'=>'1042976',
    'hws124'=>'1004472',
    'jkr320'=>'1003414',
    'jkreddy'=>'1022350',
    'jlomas'=>'1000184',
    'jmm392'=>'1043300',
    'jnl186'=>'1069417',
    'jpe670'=>'1057897',
    'jwn341'=>'1059786',
    'lli494'=>'1052740',
    'lwa710'=>'1041769',
    'mhe663'=>'1045028',
    'mwo292'=>'1045435',
    'rleikin'=>'1000727',
    'rsc248'=>'1001865',
    'sge340'=>'1048762',
    'sgr302'=>'1065822',
    'wto456'=>'1040637',
    'xwa760'=>'1055597',
    'zbu468'=>'1064439',
    'tkuzel'=>'1018134',
    'vlc718'=>'1027933',
    'rdu960'=>'1046736',
    'lle969'=>'1027428',
    'dengman'=>'1021653',
    'dmf679'=>'1028424',
    'goldberg'=>'1001719',
    'rgoldman'=>'1001531',
    'sgo912'=>'1029226',
    'clg879'=>'1000176',
    'ligordon'=>'1012563',
    'wjg'=>'1008164',
    'kgreen'=>'1024251',
    'pgreenld'=>'1006058',
    'eha003'=>'1041128',
    'bmh176'=>'1013496',
    'holmgren'=>'1002894',
    'shu683'=>'1028426',
    'philip'=>'1002699',
    'wakibbe'=>'1018461',
    'chat'=>'1001981',
    'chisholm'=>'1018009',
    'rademake'=>'1004037',
    'smr258'=>'1021859',
    'str'=>'1002357',
    'tvo743'=>'1058654',
    'vonroenn'=>'1011821',
    'saweitz'=>'1003787',
    'jwinter'=>'1002062',
    'tab926'=>'1012598',
    'cha994'=>'1041920',
    'anderw'=>'1021319',
    'ava459'=>'1044550',
    'benson'=>'1001725',
    'rbe510'=>'1034453',
    'dce946'=>'1033261',
    'chchang'=>'1041130',
    'jgu906'=>'1008991',
    'jjones'=>'1012450',
    'hidk'=>'1006055',
    'gsk116'=>'1005250',
    'wkarpus'=>'1018731',
    'chunglee'=>'1004817',
    'rleikin'=>'1000727',
    'jameson'=>'1004883',
    'nkrett'=>'1013105',
    'aro764'=>'1025617',
    'rsc248'=>'1001865',
    'ajs351'=>'1006981',
    'bayar'=>'1000909',
    'lvanhorn'=>'1010235',
    'dow641'=>'1018694',
    'watterso'=>'1005304',
    'jwi243'=>'1001847',
    'tkw086'=>'1011912',
    'skh770'=>'1044490',
    'hli958'=>'1043341',
    'jpa590'=>'1040956',
    'olgavolp'=>'1015262',
    'yijun'=>'1039552',
    'hws124'=>'1004472',
    'lds384'=>'1039710',
    'radman'=>'1016392',
    'ejs760'=>'1038716',
    'pgspear'=>'1005318',
    'cam493'=>'1002860',
    'bmi218'=>'1013622',
    'mondrago'=>'1000343',
    'erm636'=>'1003502',
    'morimoto'=>'1013296',
    'tam011'=>'1009325',
    'tvo'=>'1021712',
    'apaller'=>'1006032',
    'lcp123'=>'1021232',
    'schallma'=>'1009082',
    'rmp158'=>'1009779',
    'ira124'=>'1034628',
    'jkreddy'=>'1022350',
    'pstern'=>'1002791',
    'mkletzel'=>'1020213',
    'petekopp'=>'1015007',
    'jkramer'=>'1023834',
    'lal'=>'1005849',
    'ralamb'=>'1002554',
    'leis'=>'1035505',
    'logemann'=>'1011279',
    'jlomas'=>'1000184',
    'rlong'=>'1005100',
    'ama189'=>'1012060',
    'kemayo'=>'1019545',
    'ktm'=>'1014857',
    'wmmiller'=>'1003984',
    'jme662'=>'1047682',
    'tch554'=>'1030012',
    'amg513'=>'1029930',
    'ach617'=>'1052813',
    'ath523'=>'1050962',
    'grb468'=>'1027175',
    'gas611'=>'1050302',
    'gjb871'=>'1042684',
    'djtoft'=>'1021148',
    'eae607'=>'1047214',
    'klumpp'=>'1011618',
    'jak138'=>'1044200',
    'jga275'=>'1050035',
    'pbm864'=>'1029281',
    'ouh865'=>'1053672',
    'lpl530'=>'1051610',
    'mah834'=>'1012336',
    'lisab'=>'1017153',
    'ivb534'=>'1054110',
    'tjm007'=>'1051485',
    'wjc135'=>'1053905',
    'sbu768'=>'1054860',
    'sge340'=>'1048762',
    'awh'=>'1023189',
    'hgm988'=>'1042976',
    'syr195'=>'1004051',
    'vpdravid'=>'1003439',
    'jdp561'=>'1036697',
    'sis997'=>'1035946',
    'wto456'=>'1040637',
    'agr714'=>'1048034',
    'dks980'=>'1048574',
    'fmm757'=>'1036743',
    'ssi694'=>'1047683',
    'vgk331'=>'1042297',
    'qzh758'=>'1050466',
    'mhe663'=>'1045028',
    'gew111'=>'1051283',
    'sma160'=>'1011750',
    'ejp866'=>'1051248',
    'rca623'=>'1049873',
    'rjm821'=>'1046825',
    'gmm806'=>'1050189',
    'pth194'=>'1057699',
    'vba990'=>'1049927',
    'hfo171'=>'1052883',
    'ofr043'=>'2327524',
    'xwa760'=>'1055597',
    'jlw345'=>'1042630',
    'xya379'=>'1053660',
    'cgo790'=>'1056845',
    'mki094'=>'1052037',
    'jla782'=>'1043745',
    'lli494'=>'1052740',
    'jmm392'=>'1043300',
    'cpu125'=>'1056074',
    'jra428'=>'1055338',
    'xwa833'=>'1033130',
    'kjd523'=>'1016221',
    'jdw552'=>'1049330',
    'elw264'=>'1053951',
    'jva128'=>'1058111',
    'jjk965'=>'1056043',
    'cho741'=>'2179943',
    'rsa645'=>'1055993',
    'jpe670'=>'1057897',
    'vge206'=>'1058964',
    'mcl194'=>'2129733',
    'aor766'=>'1027447',
    'pts987'=>'1058513',
    'tjm604'=>'1051359',
    'stn424'=>'1003710',
    'two626'=>'1052365',
    'kas821'=>'1051792',
    'rbs599'=>'1003297',
    'har776'=>'1058670',
    'mwo292'=>'1045435',
    'pgr517'=>'1051542',
    'dch502'=>'1061243',
    'msg540'=>'1058057',
    'nmh249'=>'1003094',
    'lwa710'=>'1041769',
    'jkr320'=>'1003414',
    'xhe850'=>'1059133',
    'ser710'=>'1055613',
    'ccl754'=>'2206725',
    'jbl357'=>'1060583',
    'mec985'=>'1033352',
    'mjh531'=>'1056397',
    'dwe543'=>'1011815',
    'tav464'=>'1055606',
    'mll903'=>'1008970',
    'syo450'=>'1044272',
    'bjs962'=>'1060618',
    'ljb069'=>'1005720',
    'jcs643'=>'1058663',
    'res992'=>'1058781',
    'ssy450'=>'1060924',
    'mcm469'=>'1053338',
    'gya826'=>'1059904',
    'grm883'=>'1060015',
    'jwn341'=>'1059786',
    'tjh769'=>'1059851',
    'mab752'=>'1053369',
    'cbl517'=>'1047945',
    'bgr639'=>'1055483',
    'fma674'=>'1063244',
    'lho444'=>'1064642',
    'aha385'=>'1061208',
    'dcm863'=>'1064120',
    'dks845'=>'2171325',
    'jdc246'=>'1064279',
    'dlr363'=>'1064217',
    'hki884'=>'1059270',
    'wtt990'=>'1056004',
    'pge203'=>'1062425',
    'djb192'=>'1036839',
    'rax934'=>'1060555',
    'jal286'=>'2397527',
    'mzh511'=>'1064580',
    'cst567'=>'1066458',
    'wam924'=>'1065729',
    'lje629'=>'1062548',
    'rtj232'=>'1062255',
    'kkh665'=>'1066274',
    'mas572'=>'1063005',
    'ama702'=>'1066253',
    'dhj204'=>'1063577',
    'cinnmosk'=>'1017923',
    'zlu119'=>'1063665',
    'llc316'=>'1063472',
    'sgr302'=>'1065822',
    'cla486'=>'1038726',
    'jdl533'=>'1061875',
    'jsj360'=>'1036707',
    'mag641'=>'1062906',
    'cct810'=>'1066141',
    'stk897'=>'1068932',
    'eds393'=>'1069212',
    'ecz500'=>'1068571',
    'mja387'=>'1069922',
    'mka170'=>'1066379',
    'glg377'=>'1069435',
    'mrr427'=>'1064985',
    'kgs935'=>'1056693',
    'nal829'=>'1069068',
    'jnl186'=>'1069417',
    'jfs928'=>'1067133',
    'ise376'=>'1065979',
    'ycm569'=>'1069481',
    'ema212'=>'2391057',
    'asc380'=>'1070355',
    'bmd525'=>'1068930',
    'rnk801'=>'1068089',
    'blh670'=>'1067322',
    'nco146'=>'1065566',
    'gqi114'=>'1046497',
    'mbm363'=>'1037039',
    'pho669'=>'1069420',
    'smt546'=>'1066266',
    'cwi685'=>'1067449',
    'lmk445'=>'1054992',
    'nhi230'=>'1066404',
    'rle202'=>'1060697',
    'sch896'=>'1066032',
    'ucl535'=>'1061897',
    'tku996'=>'1065034',
    'jwg499'=>'1067927',
    'dmm685'=>'1068180',
    'sba689'=>'1042140',
    'scl669'=>'1068246',
    'cst694'=>'2047557',
    'hsn718'=>'1067954',
    'hwp673'=>'1069135',
    'zbu468'=>'1064439',
    'kca107'=>'2117014',
    'jmd448'=>'1072806',
    'sku680'=>'1020770',
    'bje168'=>'1009475',
    'tkt897'=>'1071074',
    'jyu692'=>'1071255',
    'mcj730'=>'1071828',
    'mve464'=>'1074491',
    'avs847'=>'1073544',
    'pms459'=>'1060934',
    'djo685'=>'1066024',
    'apm680'=>'1012126',
    'jlr180'=>'1068735',
    'bls304'=>'1073943',
    'bhj521'=>'1072878',
    'jsc331'=>'2357723',
    'lwa380'=>'1069091',
    'jac614'=>'1073312',
    'sfg360'=>'1006657',
    'slm724'=>'1076164',
    'ska243'=>'1068073',
    'ehg958'=>'1074582',
    'acg505'=>'1068543',
    'dev577'=>'1061814',
    'kak471'=>'1074965',
    'jfm658'=>'1063425',
    'jsv897'=>'1071327',
    'mep418'=>'1072982',
    'nlk432'=>'1070307',
    'med983'=>'1070472',
    'mlj650'=>'1074500',
    'amu429'=>'2376710',
    'yzz005'=>'1075730',
    'smw835'=>'1075560',
    'cpp967'=>'1075226',
    }
    changed=0
    username_hash.keys.each do |username|
      pi = Investigator.find_by_username(username)
      if pi.blank?
        puts "unable to find username #{username}"
      else
        if pi.employee_id.blank? or pi.employee_id < 1
          pi.employee_id = username_hash[username] 
          changed+=1
          pi.save!
        end
        if username_hash[username].to_s != pi.employee_id.to_s
          puts "username #{username} with employee_id #{username_hash[username]} does not match existing employee_id: #{pi.employee_id}"
        end
      end  
    end
    puts "insert_employee_ids completed. Processed #{username_hash.keys.length} entries. Changed #{changed} investigators"
  end

  def clean_model(class_model, attribute_name, match_names, accepted_name)
    match_names = match_names.split(",")
    match_names.each do |the_match|
      class_model.update_all( {"#{attribute_name}" => accepted_name}, ["lower(#{attribute_name}) like :like_match", {:like_match => the_match.strip.downcase+'%'} ] )
    end
  end

  task :countOldMemberships => :environment do
     block_timing("cleanup:countOldMemberships") {
        count_program_memberships_not_updated()
     }
  end

  task :purgeOldMemberships => :environment do
     block_timing("cleanup:purgeOldMemberships") {
        prune_program_memberships_not_updated()
     }
  end

  task :countFacultyUpdates => :environment do
     block_timing("cleanup:countFacultyUpdates") {
        count_faculty_updates()
     }
  end

  task :purgeUnupdatedFaculty => :environment do
     block_timing("cleanup:purgeUnupdatedFaculty") {
        prune_unupdated_faculty()
     }
  end

  task :cleanInvestigatorsUsername => :environment do
     block_timing("cleanup:cleanInvestigatorsUsername") {
       doCleanInvestigators(Investigator.find(:all, :conditions => "username like '%%.%%'"))
       doCleanInvestigators(Investigator.find(:all, :conditions => "username like '%%(%%'"))
       doCleanInvestigators(Investigator.find(:all, :conditions => "username like '%%)%%'"))
       doCleanInvestigators(Investigator.find(:all, :conditions => "username like '%%&%%'"))
     }
  end

  task :purgeNonMembers => :getAllInvestigatorsWithoutMembership do
     block_timing("cleanup:purgeNonMembers") {
       purgeInvestigators(@InvestigatorsWithoutMembership)
     }
  end

  task :delete_purged_investigators => :environment do
     block_timing("cleanup:delete_purged_investigators") {
       deletePurgedInvestigators()
      }
  end
  
  task :reinstate_investigators_with_valid_abstracts => :environment do
     block_timing("cleanup:reinstate_investigators_with_valid_abstracts") {
       investigators_to_reinstate = Investigators.deleted_with_valid_abstracts
       reinstateInvestigators(investigators_to_reinstate)
      }
  end

  task :reinstate_deleted_investigators => :environment do
     block_timing("cleanup:reinstate_investigators_with_valid_abstracts") {
       investigators_to_reinstate = Investigator.find_purged
       puts "found #{investigators_to_reinstate.length} investigators to reinstate"
       puts investigators_to_reinstate.map(&:username).inspect
       investigators_to_reinstate = []
       investigators_to_reinstate = Investigator.find_all_by_username_including_deleted(investigators_to_reinstate)
       reinstateInvestigators(investigators_to_reinstate)
      }
  end

  task :find_duplicate_tags => :environment do
     block_timing("cleanup:find_duplicate_tags") {
       findDuplicateTags()
      }
  end

  task :resolve_duplicate_tags => :environment do
     block_timing("cleanup:resolve_duplicate_tags") {
       resolveDuplicateTags()
      }
  end
  
  task :resolve_misformed_tags => :environment do
     block_timing("cleanup:resolve_misformed_tags") {
       resolveMisformedTags()
      }
  end

  task :findServiceInvestigatorsWithoutActivities => :environment do
     block_timing("cleanup:purgeServiceInvestigatorsWithoutActivities") {
       FindParttimeInvestigatorsWithoutActivities()
      }
  end
  
  task :purgeServiceInvestigatorsWithoutActivities => :environment do
     block_timing("cleanup:purgeServiceInvestigatorsWithoutActivities") {
       PurgeParttimeInvestigatorsWithoutActivities()
      }
  end

end

