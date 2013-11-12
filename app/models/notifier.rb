class Notifier < ActionMailer::Base
  
  def reminder_message(last_name, to, from, subject, profile_url, login_url, edit_publications_url, edit_profile_url, pub_total, pub_valid, abstract)
     @recipients   = to
     @from         = from
     headers         "Reply-to" => "#{from}"
     @subject      = subject
     @sent_on      = Time.now
     @content_type = "text/html"

     body[:last_name]  = last_name
     body[:profile_url] = profile_url       
     body[:login_url] = login_url       
     body[:edit_publications_url] = edit_publications_url       
     body[:edit_profile_url] = edit_profile_url       
     body[:pub_total] = pub_total       
     body[:pub_valid] = pub_valid       
     body[:abstract] = abstract       
   end

end
