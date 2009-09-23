def menu_head_abbreviation
  "Lurie Cancer Center"
end
def title_abbreviation
  "Lurie Cancer Center"
end

def GetDefaultSchool()
  "Feinberg"
end

def curl_host
    my_env = RAILS_ENV
    my_env = 'home' if public_path =~ /Users/ 
	case 
      when my_env == 'home': 'localhost:3000'
      when my_env == 'development': 'rails-dev.bioinformatics.northwestern.edu/latticegrid'
      when my_env == 'production': 'latticegrid.cancer.northwestern.edu'
      else 'rails-dev.bioinformatics.northwestern.edu/latticegrid'
	end 
end

def email_subject
  "Contact from the LatticeGrid Publications site at the Northwestern Robert H. Lurie Comprehensive Cancer Center"
end