module AwardsHelper
  
  def link_to_investigator_awards(investigator, name=nil) 
    name=investigator.last_name if name.blank?
    link_to name, 
      investigator_award_url(:id=>investigator.username), # can't use this form for usernames including non-ascii characters
       :class => 'investigator_awards',
       :title => "Go to #{name}: #{investigator.total_publications} pubs"
  end
  
  def number_to_dollars(amount)
    case amount.to_i
    when 1..10000
      amount
    when 10000..500000
      "$#{(amount.to_i/100).to_f/10}K"
    when 500000..5000000
      "$#{(amount.to_i/10000).to_f/100}M"
    when 5000000..500000000
      "$#{(amount.to_i/100000).to_f/10}M"
    when 500000000..5000000000000
      "$#{(amount.to_i/100000000).to_f/10}B"
    else
      "$#{amount}"
    end
  end
  
end
