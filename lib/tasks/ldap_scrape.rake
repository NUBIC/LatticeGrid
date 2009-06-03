require 'net/ldap'
require 'ldap_config' #look here to change the default ldap info
require 'pubmed_config' #look here to change the default time spans
require 'ldap_utilities' #specific methods

require 'rubygems'

task :getLDAP => :environment do
  #get the pubmed ids
   if ENV["uid_list"].nil?
     puts "couldn't find a uid_list parameter. Please call as 'rake getLDAP uid_list=uid1,uid2,uid3'" 
   else
     start = Time.now
     puts "uid_list: "+ENV["uid_list"]
     ENV["uid_list"].split(',').each do | uid |
       pi_data = GetLDAPentry(uid)
       if pi_data.length > 0 then
         thePI = CleanLDAPrecord(pi_data[0])
         thePI = AddToLDAPrecord(thePI, ["nuMiddleName","employeeNumber","sn","uid","givenName","title","telephoneNumber","postalAddress","mail"])
         thePI = AddToLDAPrecord(thePI, ["ou"], Array.new )
          thePI = InsertPI (thePI)
         puts "#{thePI.id}  #{thePI.username} #{thePI.last_name} #{thePI.first_name}"
        end
     end
     stop = Time.now
     elapsed_seconds = stop.to_f - start.to_f
     puts "ldap query run in #{elapsed_seconds} seconds" if @verbose
   end
end

