# -*- coding: utf-8 -*-

##
# LatticeGridHelper module overrides for
# Robert H. Lurie Comprehensive Cancer Center (RHLCCC)
module LatticeGridHelper
  # does CCSG access require authentication?
  def self.require_authentication?
    true
  end

  # email_from address for messages coming from LatticeGrid
  def self.from_address
    'Warren Kibbe <wakibbe@northwestern.edu>'
  end

  # support editing investigator profiles? Implies that authentication is supported!
  def self.allow_profile_edits?
    true
  end

  # for cancer centers to 'deselect' publications from inclusion in the CCSG report
  def self.show_cancer_related_checkbox?
    true
  end

  def self.page_title
    'RHLCCC Faculty Publications'
  end

  def self.header_title
    'Cancer Center Member Publications and Abstracts Site'
  end

  def self.menu_head_abbreviation
    'Lurie Cancer Center'
  end

  def self.get_default_school
    'Feinberg'
  end

  def self.organization_name
    'Robert H. Lurie Comprehensive Cancer Center'
  end

  def latticegrid_high_impact_description
    desc = '<p>'
    desc << "Researchers in the #{LatticeGridHelper.organization_name} publish thousands of articles in peer-reviewed journals every year.  "
    desc << 'The following recommended reading showcases a selection of their recent work.'
    desc << '</p>'
    desc
  end

  def self.google_analytics
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
  def profile_example_summaries
    out = '<p>Example summaries:'
    out << '<ul>'
    out << '<li>'
    out << link_to('Cancer Control Example', investigator_url('rbe510'))
    out << '<li>'
    out << link_to('Basic Science Example', investigator_url('tvo'))
    out << '<li>'
    out << link_to('Clinical Program Example', investigator_url('lpl530'))
    out << '</ul>'
    out << '</p>'
    out
  end


  def self.home_url
    'http://www.cancer.northwestern.edu'
  end

  def self.email_subject
    'Contact from the LatticeGrid Publications site at the Northwestern Robert H. Lurie Comprehensive Cancer Center'
  end

  def self.global_limit_pubmed_search_to_institution?
    false
  end

  def self.include_awards?
    true
  end

  def self.include_studies?
    true
  end
end
