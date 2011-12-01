require 'graph_generator'

def build_graphviz_restfulpath(gparams, format='svg')
  # map to restful order
  # 'send_graphviz_image/:id/:analysis/:distance/:stringency/:include_orphans/start_date/end_date/:program.:format',
  
  send_graphviz_image_url(gparams[:id],gparams[:analysis],gparams[:distance],gparams[:stringency],gparams[:include_orphans], gparams[:start_date], gparams[:end_date], gparams[:program], format)
end

def build_graphviz_filepath(gparams)
   # map to restful order
   # 'send_graphviz_image/:id/:analysis/:distance/:stringency/:include_orphans/start_date/end_date/:program.:format',

   "graphs/#{clean_filename(gparams[:id])}/#{gparams[:analysis]}/#{gparams[:distance]}/#{gparams[:stringency]}/#{gparams[:include_orphans]}/#{gparams[:start_date].to_date.to_s(:integer_date)}/#{gparams[:end_date].to_date.to_s(:integer_date)}/"
 end

 # was handle_graphviz_params
  
 def set_graphviz_defaults(gparams={})
   gparams[:program] ||= "neato" 
   gparams[:analysis] ||= "member"
   gparams[:start_date] ||= 5.years.ago.to_date.to_s(:justdate)
   gparams[:end_date] ||= Date.tomorrow.to_s(:justdate)
   gparams[:format] ||= "svg"
   if gparams[:analysis].include?("org_org")
     gparams[:stringency] ||= "10"
   end
   if gparams[:analysis].include?("org")
     gparams[:distance] ||= "0"
     gparams[:stringency] ||= "3"
   end
   if gparams[:analysis].include?("mesh") and gparams[:analysis] != "mesh"
     gparams[:stringency] ||= "2000"
     gparams[:stringency] = "2000" if gparams[:stringency].to_i < 500
   end
   if gparams[:analysis] == "mesh"
     gparams[:distance] ||= "0"
     gparams[:stringency] ||= "4"
     gparams[:include_orphans] ||= "1"
   end
   gparams[:distance] ||= "1"
   gparams[:stringency] ||= "1"
   gparams[:include_orphans] ||= "0"
   gparams[:id] ||= "cam493"
   if gparams[:distance] == "2" and gparams[:program] == "dot"
     gparams[:program] = "neato"
   end
   if gparams[:include_orphans] != "1" or gparams[:include_orphans] == "null"
     gparams[:include_orphans] = "0"
   end
   gparams
 end

