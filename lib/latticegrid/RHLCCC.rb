
# does CCSG access require authentication?
def LatticeGridHelper.require_authentication?
  return true
end

# support editing investigator profiles? Implies that authentication is supported!
def LatticeGridHelper.allow_profile_edits?
  return true
end

def LatticeGridHelper.include_summary_by_member?
  return true
end

# for cancer centers to 'deselect' publications from inclusion in the CCSG report
def LatticeGridHelper.show_cancer_related_checkbox?
  return true
end

def LatticeGridHelper.page_title
  return 'RHLCCC Faculty Publications'
end

def LatticeGridHelper.header_title
  return 'Cancer Center Member Publications and Abstracts Site'
end

def LatticeGridHelper.menu_head_abbreviation
  "Lurie Cancer Center"
end

def LatticeGridHelper.GetDefaultSchool()
  "Feinberg"
end

def LatticeGridHelper.home_url
  "http://www.cancer.northwestern.edu"
end

def LatticeGridHelper.global_limit_pubmed_search_to_institution?
  false
end
