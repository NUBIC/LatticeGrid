ActionController::Routing::Routes.draw do |map|
  # need to add .js to any rjs files we cache
#  map.connect 'abstracts/admin', :controller => 'abstracts', :action => 'ccsg', :conditions => { :method => :get } #legacy url. delete after 12/1/09
  map.show_investigator 'investigators/:id/show/:page', {:controller => "investigators",:action => "show", :conditions => { :method => :get }  }
  map.abstracts_by_year 'abstracts/:id/year_list/:page', {:controller => "abstracts",:action => "year_list", :conditions => { :method => :get } }
  map.abstracts_search 'abstracts/search/:page', {:controller => 'abstracts', :action => 'search', :conditions => { :method => :get } }
  map.index_orgs 'orgs/index', :controller => 'orgs', :action => 'index'  #handle the route for orgs_path to make sure it is cached properly
  map.resources :orgs, :only => [:index, :show], :collection => { :stats => :get, :list => :get, :centers => :get, :departments => :get, :programs => :get, :department_collaborations => :get }, 
    :member => {:full_show => :get, :show_investigators => :get, :list_abstracts_during_period_rjs => :post }
  map.resources :investigators, :only => [:index, :show], :member => {:full_show => :get, :show_all_tags => :get}, :collection => { :list_all => :get }
  map.resources :copublications, :only => [:show], :member => {:investigator_colleagues => :get}

# manually added rjs routes to enforce .js format
  map.tag_cloud_side_investigator '/investigators/:id/tag_cloud_side.js', :action=>"tag_cloud_side", :controller=>"investigators",  :conditions => { :method => :get }
  map.tag_cloud_side_copublication '/copublications/:id/tag_cloud_side.js', :action=>"tag_cloud_side", :controller=>"copublications",  :conditions => { :method => :get }
  map.tag_cloud_investigator '/investigators/:id/tag_cloud.js', :action=>"tag_cloud", :controller=>"investigators",  :conditions => { :method => :get }
  map.tag_cloud_copublication '/copublications/:id/tag_cloud.js', :action=>"tag_cloud", :controller=>"copublications",  :conditions => { :method => :get }
  map.short_tag_cloud_org '/orgs/:id/short_tag_cloud.js', :action=>"short_tag_cloud", :controller=>"orgs",  :conditions => { :method => :get }
  map.tag_cloud_org '/orgs/:id/tag_cloud.js', :action=>"tag_cloud", :controller=>"orgs",  :conditions => { :method => [:get, :post] }
  
  map.tag_cloud_by_year_abstract '/abstracts/:id/tag_cloud_by_year.js', :action=>"tag_cloud_by_year", :controller=>"abstracts",  :conditions => { :method => :get }
   
  map.resources :abstracts, :only => [:index, :show], :collection => { :search => [:get, :post], :ccsg => :get, :tag_cloud => :get, :current => :get },
    :member => {:set_deleted_date => [:get,:post],  :full_year_list => :get, :year_list => :get, :endnote => :get, :full_tagged_abstracts => :get, :tagged_abstracts => [:get, :post] }
  map.resources :graphs, :only => [:none], :member => {:show_member => :get, :show_org => :get}
  map.resources :graphviz, :only => [:none], :member => {:show_member => :get, :show_member_mesh => :get, :show_org_mesh => :get, :show_org => :get}

  map.connect 'abstracts/investigator_listing/:id', :controller => 'abstracts', :action => 'investigator_listing'
  map.connect 'orgs/abstracts_during_period/:id', :controller => 'orgs', :action => 'abstracts_during_period'
  map.connect 'ccsg', :controller => 'abstracts', :action => 'ccsg', :conditions => { :method => :get }
  map.connect 'admin', :controller => 'abstracts', :action => 'ccsg', :conditions => { :method => :get }
  map.tag_cloud 'tag_cloud', :controller => 'abstracts', :action => 'tag_cloud', :conditions => { :method => :get }
  map.impact_factor 'impact_factor/:year/:sortby', :controller => 'abstracts', :action => 'impact_factor', :conditions => { :method => :get }
  map.formatted_impact_factor 'impact_factor/:year.:format', :controller => 'abstracts', :action => 'impact_factor', :sortby=>'', :conditions => { :method => :get }
  map.high_impact 'high_impact', :controller => 'abstracts', :action => 'high_impact', :conditions => { :method => :get }
  map.org_nodes 'org_nodes/:id', :controller => 'graphs', :action => 'org_nodes' #need this for some of the flash xml calls
  map.member_nodes 'member_nodes/:id', :controller => 'graphs', :action => 'member_nodes' #need this for some of the flash xml calls

  map.send_graphviz_image 'send_graphviz_image/:id/:analysis/:distance/:stringency/:include_orphans/:program.:format', :controller => 'graphviz', :action => 'send_graphviz_image'
  map.restless_graphviz 'get_graphviz/', :controller => 'graphviz', :action => 'get_graphviz'
#  map.graphviz 'graph/:id/graphviz/:distance/:stingency/:program.:format', :controller => 'graphviz', :action => 'graphviz'

  map.connect ':controller/:id/:action/:page'
  map.connect ':controller/:id/:action'  #need this for some of the rjs calls and the sparklines

#  map.root :controller => 'abstracts', :action => 'list', :conditions => { :method => :get }

end
