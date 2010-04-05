def build_graphviz_restfulpath(gparams, format='svg')
  # map to restful order
  # 'send_graphviz_image/:id/:analysis/:distance/:stringency/:include_orphans/:program.:format',
  
  send_graphviz_image_url(gparams[:id],gparams[:analysis],gparams[:distance],gparams[:stringency],gparams[:include_orphans], gparams[:program], format)
end

def build_graphviz_filepath(gparams)
   # map to restful order
   # 'send_graphviz_image/:id/:analysis/:distance/:stringency/:include_orphans/:program.:format',

   "graphs/#{gparams[:id]}/#{gparams[:analysis]}/#{gparams[:distance]}/#{gparams[:stringency]}/#{gparams[:include_orphans]}/"
 end

 # was handle_graphviz_params
  
 def set_graphviz_defaults(gparams={})
   gparams[:program] ||= "neato" 
   gparams[:analysis] ||= "member"
   gparams[:format] ||= "svg"
   if gparams[:analysis].include?("org")
     gparams[:distance] ||= "0"
     gparams[:stringency] ||= "3"
   end
   if gparams[:analysis].include?("mesh")
     gparams[:stringency] ||= "2000"
     gparams[:stringency] = "2000" if gparams[:stringency].to_i < 500
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

