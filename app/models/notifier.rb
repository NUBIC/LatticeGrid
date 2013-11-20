class Notifier < ActionMailer::Base
  default from: "mruchin@northwestern.edu"

  def reminder_message(investigator)
    headers { "Reply-to" => "mruchin@northwestern.edu" }
    @content_type = "text/html"

    @abstract = investigator.faculty_research_summary
    @last_name = investigator.last_name
    @login_url = profiles_url
    @pub_total = investigator.investigator_abstracts.count
    @pub_valid = investigator.abstracts.count
    @profile_url = show_investigator_url(:id => investigator.username, :page => 1)
    @edit_profile_url = profile_url(investigator.username)
    @edit_publications_url = edit_pubs_profile_url(investigator.username)
    mail(:to => investigator.email, :subject => 'Please approve your Lurie Cancer Center LatticeGrid profile')
  end

end
