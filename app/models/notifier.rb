# -*- coding: utf-8 -*-
class Notifier < ActionMailer::Base
  SENDER = "mruchin@northwestern.edu"
  default from: SENDER

  def reminder_message(investigator)
    @content_type = "text/html"

    @abstract = investigator.faculty_research_summary
    @last_name = investigator.last_name
    @login_url = profiles_url
    @pub_total = investigator.investigator_abstracts.count
    @pub_valid = investigator.abstracts.count
    @profile_url = show_investigator_url(:id => investigator.username, :page => 1)
    @edit_profile_url = profile_url(investigator.username)
    @edit_publications_url = edit_pubs_profile_url(investigator.username)
    mail(:to => investigator.email, :reply_to => SENDER, :subject => 'Please approve your Lurie Cancer Center LatticeGrid profile')
  end

end
