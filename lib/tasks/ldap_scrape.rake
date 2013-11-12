require 'pubmed_config' #look here to change the default time spans
require 'ldap_utilities' #specific methods

require 'rubygems'

task :getLDAP => :environment do
  #get the pubmed ids
   if ENV["uid_list"].nil?
     puts "couldn't find a uid_list parameter. Please call as 'rake getLDAP uid_list=uid1,uid2,uid3'" 
   else
     block_timing("getLDAP") {
       puts "uid_list: "+ENV["uid_list"]
       ENV["uid_list"].split(',').each do | uid |
         pi_data = GetLDAPentry(uid)
         puts pi_data.inspect
         thePI=MakePIfromLDAP(pi_data)
         #CreateOrUpdatePI(thePI)
       end
     }
    end
end

