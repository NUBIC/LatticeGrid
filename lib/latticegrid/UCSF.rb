
# does CCSG access require authentication?
def LatticeGridHelper.require_authentication?
  return false
end

# support editing investigator profiles? Implies that authentication is supported!
def LatticeGridHelper.allow_profile_edits?
  return false
end

def LatticeGridHelper.include_summary_by_member?
  return false
end

# show research description
def LatticeGridHelper.show_research_description?
  return false
end

# for cancer centers to 'deselect' publications from inclusion in the CCSG report
def LatticeGridHelper.show_cancer_related_checkbox?
  return true
end

def LatticeGridHelper.page_title
  return 'Helen Diller Family Comprehensive Cancer Center Faculty Publications'
end

def LatticeGridHelper.header_title
  return 'Cancer Center Member Publications and Abstracts Site'
end

def LatticeGridHelper.menu_head_abbreviation
  "Diller Cancer Center"
end

def LatticeGridHelper.get_default_school
  "UCSF"
end

def LatticeGridHelper.home_url
  "http://cancer.ucsf.edu/"
end

def LatticeGridHelper.curl_host
my_env = Rails.env
my_env = 'home' if public_path =~ /Users/
case
  when my_env == 'home' then 'localhost:3000'
  when my_env == 'development' then 'rails-staging2.nubic.northwestern.edu'
  when my_env == 'staging' then 'rails-staging2.nubic.northwestern.edu'
  when my_env == 'production' then 'latticegrid.cancer.ucsf.edu'
  else 'latticegrid.cancer.ucsf.edu/'
end
end

def LatticeGridHelper.curl_protocol
my_env = Rails.env
my_env = 'home' if public_path =~ /Users/
case
  when my_env == 'home' then 'http'
  when my_env == 'development' then 'http'
  when my_env == 'staging' then 'http'
  when my_env == 'production' then 'https'
  else 'http'
end
end

def profile_example_summaries()
  ""
end

def LatticeGridHelper.do_ldap?
 false
end


def LatticeGridHelper.ldap_perform_search?
 false
end

def LatticeGridHelper.ldap_host
 "directory.ucsf.edu"
end

def LatticeGridHelper.ldap_treebase
 "ou=People, dc=ucsf,dc=edu"
end

def LatticeGridHelper.include_awards?
 false
end

def LatticeGridHelper.allowed_ips
 # childrens: 199.125.
 # nmff: 209.107.
 # nmh: 165.20.
 # enh: 204.26
 # ric: 69.216
 [':1','127.0.*','165.124.*','129.105.*','199.125.*','209.107.*','165.20.*','204.26.*','69.216.*']
end

# build LatticeGridHelper.institutional_limit_search_string to identify all the publications at your institution

def LatticeGridHelper.institutional_limit_search_string
  '("San Francisco"[affil] OR "Diller"[affil] OR "UCSF"[affil])'
end

# limit searches to include the institutional_limit_search_string
def LatticeGridHelper.global_limit_pubmed_search_to_institution?
  false
end

def LatticeGridHelper.do_ldap?
  false
end

def edit_profile_link
  ""
end

