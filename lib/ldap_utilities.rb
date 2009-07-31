
def GetLDAPentry (uid)
  puts  uid
  id_filter = Net::LDAP::Filter.eq( "uid", uid)
  @ldap_connection.search( :base => @ldap_treebase, :filter => id_filter)
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
def InsertPI (pi_data)
  puts "InsertPI: this shouldn't happen - pi_data was nil" if pi_data.nil?
  raise "InsertPI: this shouldn't happen - pi_data was nil" if pi_data.nil?
  thePI = nil
  thePI = Investigator.find_by_username(pi_data.uid)
  begin 
    if thePI.nil? || thePI.id < 1 then
      thePI = Investigator.create! (
        :username => pi_data["uid"], 
        :last_name => pi_data["sn"],
        :middle_name => pi_data["nuMiddleName"],
        :first_name => pi_data["givenName"],
        :title =>  pi_data["title"],
        :business_phone => pi_data["telephoneNumber"],
        :employee_id => pi_data["employeeNumber"],
        :address1 => pi_data["postalAddress"],
        :mailcode => pi_data.ou[0],
        :email => pi_data["mail"]
        )
        thePI.save!
    end
  rescue ActiveRecord::RecordInvalid => error
    puts "InsertPI: raised an error for an investigator with the id of '#{pi_data.uid} with an error of #{error.inspect}"
     if thePI.nil? then # something bad happened
      puts "InsertPI: unable to find or insert investigator with the id of '#{pi_data.uid}"
      raise "InsertPI: unable to find or insert investigator with the id of  '#{pi_data.uid}"
    end
  end 
  thePI
end
