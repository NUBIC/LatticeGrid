
def GetLDAPentry(uid)
  ldap_connection = Net::LDAP.new :host => "directory.northwestern.edu"
  ldap_treebase = "ou=People, dc=northwestern,dc=edu"
  id_filter = Net::LDAP::Filter.eq( "uid", uid)
  ldap_connection.search( :base => ldap_treebase, :filter => id_filter)
end

def CleanLDAPvalue(val)
  return nil if val.nil?
  if val.kind_of?(Array) then
    return nil if val.length == 0
    val=CleanLDAPvalue(val[0])
  else
    val.gsub(/[\n-\[\]]*/,"").strip
  end
  return val
end

def CleanLDAPrecord(rec)
  # results are a hash
     rec.each  do |key,value| 
       rec[key]=CleanLDAPvalue(rec[key]) 
    end
  return rec
end

def AddToLDAPrecord(rec, keys, defaultval=nil)
  # results are a hash
  reckeys = Array.new
  rec.each {|x,y| reckeys << x.to_s.downcase }
  keys.each  do |key| 
     rec[key] = defaultval  if !reckeys.include?(key.downcase)
  end
  return rec
end

# may need to adapt the ldap attributes to the Investigator data model
def BuildPIobject(pi_data)
  puts "BuildPIobject: this shouldn't happen - pi_data was nil" if pi_data.nil?
  raise "BuildPIobject: this shouldn't happen - pi_data was nil" if pi_data.nil?
  thePI = nil
  thePI = Investigator.find_by_username(pi_data.uid)
  begin 
    if thePI.nil? || thePI.id < 1 then
      thePI = Investigator.new(
        :username => pi_data["uid"], 
        :last_name => pi_data["sn"],
        :middle_name => ((pi_data["displayname"].split(" ").length >2) ? pi_data["displayname"].split(" ")[1] : pi_data["numiddlename"]),
        :first_name => pi_data["givenName"])
    end
  rescue ActiveRecord::RecordInvalid => error
    puts "BuildPIobject: raised an error for an investigator with the id of '#{pi_data.uid} with an error of #{error.inspect}"
    if thePI.nil? then # something bad happened
      puts "BuildPIobject: unable to find or insert investigator with the id of '#{pi_data.uid}"
      raise "BuildPIobject: unable to find or insert investigator with the id of  '#{pi_data.uid}"
    end
  end 
  thePI
end

def MergePIrecords(thePI, pi_data)
  # trust LDAP
  if ! pi_data.blank?
    thePI.title = pi_data["title"] || thePI.title
    thePI.business_phone = pi_data["telephoneNumber"] || thePI.business_phone
    thePI.employee_id = pi_data["employeeNumber"] || thePI.employee_id
    thePI.address1 = pi_data["postalAddress"] || thePI.address1
    thePI.campus = pi_data["postalAddress"].split("$").last || thePI.campus if ! pi_data["postalAddress"].blank?
    # home_department is no longer a string
    thePI["home"] = pi_data.ou  if pi_data.ou !~ /People/
    #trust the internal system first
    thePI.email ||= pi_data["mail"]
    thePI.fax ||= pi_data["facsimiletelephonenumber"]
    #clean up the campus data
    thePI.campus = (thePI.campus =~ /CH|Chicago/) ? 'Chicago' : thePI.campus
    thePI.campus = (thePI.campus =~ /EV|Evanston/) ? 'Evanston' : thePI.campus
  end
  thePI
end

def CleanPIfromLDAP(pi_data)
  if pi_data.length > 0 then
    clean_rec = CleanLDAPrecord(pi_data[0])
    clean_rec = AddToLDAPrecord(clean_rec, ["nuMiddleName","employeeNumber","sn","uid","givenName","title","telephoneNumber","postalAddress","mail","facsimiletelephonenumber"])
    clean_rec = AddToLDAPrecord(clean_rec, ["ou"], "" )
    return clean_rec
  end
  pi_data
end

def MakePIfromLDAP(pi_data)
  if pi_data.length > 0 then
    clean_rec = CleanPIfromLDAP(pi_data)
    thePI = BuildPIobject(clean_rec)
    thePI=MergePIrecords(thePI, clean_rec)
    begin
      logger.info "#{thePI.id}  #{thePI.username} #{thePI.last_name} #{thePI.first_name}"
      logger.info pi_data.inspect
      logger.info thePI.inspect
    rescue Exception => error
      puts "#{thePI.id}  #{thePI.username} #{thePI.last_name} #{thePI.first_name}"
      puts pi_data.inspect
      puts thePI.inspect
    end
    return thePI
  end
end

# may need to adapt the ldap attributes to the Investigator data model
def CreateOrUpdatePI(thePI)
  puts "CreateOrUpdatePI: this shouldn't happen - thePI was nil" if thePI.nil?
  begin 
    thePI.save!
  rescue ActiveRecord::RecordInvalid => error
    puts "CreateOrUpdatePI: raised an error for an investigator with the id of '#{thePI.username} with an error of #{error.inspect}"
  end 
  thePI
end
