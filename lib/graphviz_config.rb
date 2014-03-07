require 'graph_generator'

def date_handler(the_date)
  if the_date =~ /([0-9]+\/[0-9]+\/[0-9]+)/
    the_date = Date.strptime(the_date, "%m/%d/%Y").to_s(:integer_date)
  elsif the_date =~ /([0-9]+\-[0-9]+\-[0-9]+)/
    the_date = the_date.to_date.to_s(:integer_date)
  end
  the_date
end

def build_graphviz_restfulpath(gparams, format = 'svg')
  # map to restful order
  # 'send_graphviz_image/:id/:analysis/:distance/:stringency/:include_orphans/start_date/end_date/:program.:format'
  send_graphviz_image_url(gparams[:id],
                          gparams[:analysis],
                          gparams[:distance],
                          gparams[:stringency],
                          gparams[:include_orphans],
                          date_handler(gparams[:start_date]),
                          date_handler(gparams[:end_date]),
                          gparams[:program],
                          format)
end

def build_graphviz_filepath(gparams)
  # map to restful order
  # 'send_graphviz_image/:id/:analysis/:distance/:stringency/:include_orphans/start_date/end_date/:program.:format',
  "graphviz/#{clean_filename(gparams[:id])}/#{gparams[:analysis]}/#{gparams[:distance]}/#{gparams[:stringency]}/#{gparams[:include_orphans]}/#{date_handler(gparams[:start_date])}/#{date_handler(gparams[:end_date])}/"
end

 # was handle_graphviz_params
def set_graphviz_defaults(gparams = {})
  gparams[:program] ||= 'neato'
  gparams[:analysis] ||= 'member'
  gparams[:start_date] ||= 5.years.ago.to_date.to_s(:justdate)
  gparams[:end_date] ||= Date.tomorrow.to_s(:justdate)
  gparams[:format] ||= 'svg'
  gparams[:stringency] ||= '10' if gparams[:analysis].include?('org_org')
  if gparams[:analysis].include?('org')
    gparams[:distance] ||= '0'
    gparams[:stringency] ||= '3'
  end
  if gparams[:analysis].include?('mesh') && gparams[:analysis] != 'mesh'
    gparams[:stringency] ||= '2000'
    gparams[:stringency] = '2000' if gparams[:stringency].to_i < 500
  end
  if gparams[:analysis] == 'mesh'
    gparams[:distance] ||= '0'
    gparams[:stringency] ||= '4'
    gparams[:include_orphans] ||= '1'
  end
  gparams[:distance] ||= '1'
  gparams[:stringency] ||= '1'
  gparams[:include_orphans] ||= '0'
  gparams[:id] ||= 'cam493'
  gparams[:program] = 'neato' if gparams[:distance] == '2' && gparams[:program] == 'dot'
  gparams[:include_orphans] = '0' if gparams[:include_orphans] != '1' || gparams[:include_orphans] == 'null'
  gparams
end
