
# does CCSG access require authentication?
def LatticeGridHelper.require_authentication?
  return true
end

# email_from address for messages coming from LatticeGrid
def LatticeGridHelper.from_address
  return 'Warren Kibbe <wakibbe@northwestern.edu>'
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

def LatticeGridHelper.organization_name
  "Robert H. Lurie Comprehensive Cancer Center"
end

def latticegrid_high_impact_description
  "<p>Researchers in the #{LatticeGridHelper.organization_name} publish thousands of articles in peer-reviewed journals every year.  The following recommended reading showcases a selection of their recent work.</p>
  "
end

def LatticeGridHelper.google_analytics
   "<script type='text/javascript'>

     var _gaq = _gaq || [];
     _gaq.push(['_setAccount', 'UA-30100146-1']);
     _gaq.push(['_trackPageview']);

     (function() {
       var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
       ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
       var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
     })();

   </script>"
end
 
# profile example summaries
def profile_example_summaries()
  out = "<p>Example summaries:"  
  out << "<ul>"
  out << "<li>"
  out << link_to("Cancer Control Example", investigator_url('rbe510'))
  out << "<li>"
  out << link_to("Basic Science Example", investigator_url('tvo')) 
  out << "<li>"
  out << link_to("Clinical Program Example", investigator_url('lpl530'))
  out << "</ul>"
  out << "</p>"
  out
end


def LatticeGridHelper.home_url
  "http://www.cancer.northwestern.edu"
end

def LatticeGridHelper.email_subject
  "Contact from the LatticeGrid Publications site at the Northwestern Robert H. Lurie Comprehensive Cancer Center"
end

def LatticeGridHelper.global_limit_pubmed_search_to_institution?
  false
end

def LatticeGridHelper.include_awards?
  true
end

def LatticeGridHelper.include_studies?
  true
end
