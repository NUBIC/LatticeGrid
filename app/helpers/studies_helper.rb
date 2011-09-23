module StudiesHelper
  def link_to_investigator_studies(investigator, name=nil) 
    name=investigator.last_name if name.blank?
    link_to name, 
      investigator_study_url(:id=>investigator.username), # can't use this form for usernames including non-ascii characters
       :class => 'investigator_awards',
       :title => "Go to #{name}: #{investigator.total_publications} pubs"
  end
end
