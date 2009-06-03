@ldap_connection = Net::LDAP.new :host => "directory.northwestern.edu"
@ldap_treebase = "ou=People, dc=northwestern,dc=edu"

# sample ldap query from Northwestern
# ldap query run in 0.0598552227020264 seconds
#  [#<Net::LDAP::Entry:0x2441310 
#  @myhash={:telephonenumber=>["+1 312 503 3229"], :edupersonnickname=>["wak"], 
#     :dn=>["uid=wakibbe, ou=People, dc=northwestern, dc=edu"], 
#     :cn=>["Warren A Kibbe", "Warren", "A", "Kibbe", "Warren Kibbe", "Kibbe,Warren", "Warren wak Kibbe", "Warren wak", "wak Kibbe", "Kibbe,wak", "wak"], 
#     :title=>["Research Associate Professor"], 
#     :displayname=>["Warren A Kibbe"], 
#     :uidnumber=>["1566"], 
#     :mail=>["wakibbe@northwestern.edu"], 
#     :sn=>["Kibbe"], 
#     :uid=>["wakibbe"], 
#     :postaladdress=>["750 N Lake Shore Dr$11th Floor$CH"], 
#     :givenname=>["Warren"], 
#     :ou=>["NU Clinical and Translational Sciences Institute", "MED-Center for Genetic Med", "People"]}>]
#  telephonenumber is +1 312 503 3229
#  edupersonnickname is wak
#  dn is uid=wakibbe, ou=People, dc=northwestern, dc=edu
#  cn is Warren A KibbeWarrenAKibbeWarren KibbeKibbe,WarrenWarren wak KibbeWarren wakwak KibbeKibbe,wakwak
#  title is Research Associate Professor
#  displayname is Warren A Kibbe
#  uidnumber is 1566
#  mail is wakibbe@northwestern.edu
#  sn is Kibbe
#  uid is wakibbe
#  postaladdress is 750 N Lake Shore Dr$11th Floor$CH
#  givenname is Warren
#  ou is NU Clinical and Translational Sciences InstituteMED-Center for Genetic MedPeople

