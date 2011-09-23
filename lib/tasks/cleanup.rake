namespace :cleanup do
  
  task :countries => :environment do
    clean_country("Australia","Australia")
    clean_country("Belgium","Belgium")
    clean_country("Brazil","Brazil")
    clean_country("Canada","Canada")
    clean_country("CH,Switzerland,Swistzerland","Switzerland")
    clean_country("DE,Germany,Ger","Germany")
    clean_country("England,U.K.,UK,United Kingdom,United Kingdon,United-Kingdom","United Kingdom")
    clean_country("France","France")
    clean_country("India","India")
    clean_country("Brazil","Brazil")
    clean_country("U.S.A.,United States,United States of America,US","United States of America")
    clean_country("Netherlands,The Netherlands","Netherlands")
    
  end
  
  task :email => :environment do
    Investigator.update_all("email = lower(email)") 
  end

end

def clean_model(class_model, attribute_name, match_names, accepted_name)
  match_names = match_names.split(",")
  match_names.each do |the_match|
    class_model.update_all( {"#{attribute_name}" => accepted_name}, ["lower(#{attribute_name}) like :like_match", {:like_match => the_match.strip.downcase+'%'} ] )
  end
end