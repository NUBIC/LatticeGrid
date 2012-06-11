ActionController::Routing::Routes.draw do |map|
  # need to add .js to any rjs files we cache

  map.show_investigator 'investigators/:id/show/:page', {:controller => "investigators",:action => "show", :conditions => { :method => :get }  }
  map.show_org 'orgs/:id/show/:page', {:controller => "orgs",:action => "show", :conditions => { :method => :get }  }
  map.abstracts_by_year 'abstracts/:id/year_list/:page', {:controller => "abstracts",:action => "year_list", :conditions => { :method => :get } }
  map.abstracts_search_by_year 'abstracts/:id/search/:page', {:controller => "abstracts",:action => "year_list", :conditions => { :method => :get } }
  map.abstracts_searchpage 'abstracts/search/:page', {:controller => 'abstracts', :action => 'search', :conditions => { :method => [:get, :post] } }
  map.abstracts_search 'abstracts/search', {:controller => 'abstracts', :action => 'search', :conditions => { :method => :get } }
  map.investigator_listing 'profiles/investigator_listing/:id', {:controller => 'profiles', :action => 'investigator_listing'}
  map.award_listing 'awards/listing', {:controller => 'awards', :action => 'listing'}
  map.recent_awards 'awards/recent', {:controller => 'awards', :action => 'recent', :conditions => { :method =>  [:get, :post] } }
  map.ad_hoc_by_pi_awards 'awards/ad_hoc_by_pi', {:controller => 'awards', :action => 'ad_hoc_by_pi', :conditions => { :method =>  [:get, :post] } }
  map.ad_hoc_by_pi_studies 'studies/ad_hoc_by_pi', {:controller => 'studies', :action => 'ad_hoc_by_pi', :conditions => { :method =>  [:get, :post] } }
  
  map.index_orgs 'orgs/index', :controller => 'orgs', :action => 'index'  #handle the route for orgs_path to make sure it is cached properly
  map.resources :orgs, :only => [:index, :show], 
    :collection => { :stats => :get, :period_stats => [:get,:post], :list => :get, :centers => :get, :orgs => :get, :departments => :get, :programs => :get, :department_collaborations => :get, :investigator_abstracts_during_period => [:get, :post], :classifications => :get }, 
    :member => {:full_show => :get, :show_investigators => :get, :list_abstracts_during_period_rjs => :post, :classification_orgs => :get, :program_members => :get }
  map.resources :investigators, :only => [:index, :show], :member => {:full_show => :get, :show_all_tags => :get, :publications => :get, :abstract_count => :get, :preview => :get, :search => :get, :investigators_search => :get, :research_summary => :get, :tag_cloud_list => :get, :title => :get, :home_department => :get, :bio=>:get, :email=>:get, :affiliations=>:get}, :collection => { :list_all => :get, :listing => :get, :list_by_ids => [:post, :get] }
  map.resources :cytoscape, :only => [:index, :show], :member => {:investigators => :get, :protovis => :get, :jit => :get, :awards => :get, :studies => :get, :d3_data => :get, :chord=>:get, :show_org=>:get, :awards_org=>:get, :studies_org=>:get, :show_all=>:get, :org_all=>:get}, :collection => {:d3_data => :get, :chord=>:get, :chord_by_date => [:get, :post]}
  map.resources :awards,  :only => [:index, :show], :collection => {:disallowed => [:get, :post], :listing => [:get, :post], :org => [:get, :post]}, :member => {:investigator => :get, :org => [:get, :post]}
  map.resources :studies, :only => [:index, :show], :collection => {:disallowed => [:get, :post], :listing => [:get, :post]}, :member => {:investigator => :get, :org => :get}
  map.resources :profiles, :except=>[:destroy,:new], :member => {:reminder => :get, :edit_pubs => :get, :investigator_listing => [:get, :post]}, :collection => { :splash => :get, :recent_unvalidated => :get, :recent => :get, :ccsg => :get, :admin => :get, :list_summaries => :get, :list_summaries_by_program => [:get, :post], :list_investigators => :get, :edit_investigators => :get}
  map.resources :audits, :only => [:index, :show], :collection => { :view_logins => :get, :view_all_logins=> :get, :view_approved_profiles => :get, :view_approved_publications => :get, :faculty_data=>:get, :login_data=>:get, :approved_profile_data=>:get, :approved_publication_data=>:get, :view_publication_approvers=>:get, :view_profile_approvers=>:get, :view_logins_without_approvals=>:get}
  
  map.resources :mesh, :only => [:index], :member => {:search => :get, :investigators => :get, :investigator => :get, :investigator_tags => :get, :tag_count => :get, :investigator_count => :get}
  map.investigator_mesh_tags 'mesh/investigator/:username.:format', {:controller => "mesh", :action => "investigator", :conditions => { :method => :get }  }
  map.investigator_abstract_count 'investigators/:username/abstract_count.:format', {:controller => "investigators", :action => "abstract_count", :conditions => { :method => :get }  }
  map.resources :copublications, :only => [:show], :member => {:investigator_colleagues => :get}

# manually added rjs routes to enforce .js format
  map.collaborators_investigator 'investigators/:id/collaborators.js', :action=>"collaborators", :controller=>"investigators",  :conditions => { :method => :get }
  map.barchart_investigator 'investigators/:id/barchart.js', :action=>"barchart", :controller=>"investigators",  :conditions => { :method => :get }
  map.barchart_org 'orgs/:id/barchart.js', :action=>"barchart", :controller=>"orgs",  :conditions => { :method => :get }
  map.tag_cloud_side_investigator 'investigators/:id/tag_cloud_side.js', :action=>"tag_cloud_side", :controller=>"investigators",  :conditions => { :method => :get }
  map.tag_cloud_side_copublication 'copublications/:id/tag_cloud_side.js', :action=>"tag_cloud_side", :controller=>"copublications",  :conditions => { :method => :get }
  map.tag_cloud_investigator 'investigators/:id/tag_cloud.js', :action=>"tag_cloud", :controller=>"investigators",  :conditions => { :method => :get }
  map.tag_cloud_copublication 'copublications/:id/tag_cloud.js', :action=>"tag_cloud", :controller=>"copublications",  :conditions => { :method => :get }
  map.short_tag_cloud_org 'orgs/:id/short_tag_cloud.js', :action=>"short_tag_cloud", :controller=>"orgs",  :conditions => { :method => :get }
  map.tag_cloud_org 'orgs/:id/tag_cloud.js', :action=>"tag_cloud", :controller=>"orgs",  :conditions => { :method => [:get, :post] }
  map.tag_cloud_by_year_abstract 'abstracts/:id/tag_cloud_by_year.js', :action=>"tag_cloud_by_year", :controller=>"abstracts",  :conditions => { :method => :get }

# manually added html route for the top mesh terms in the tag cloud
  map.tag_cloud_list '/investigators/:id/tag_cloud_list.json', :action=>"tag_cloud_list", :controller=>"investigators", :conditions => { :method => :get }
   
  map.resources :abstracts, :only => [:index, :show], :collection => { :search => [:get, :post], :tag_cloud => :get, :current => :get, :add_pubmed_ids => [:get, :post], :update_pubmed_id => [:get, :post], :add_abstracts => :get, :high_impact_by_month => :get, :high_impact => :get },
    :member => {:set_deleted_date => [:get,:post], :set_is_cancer => [:get,:post], :impact_factor => :get, :set_investigator_abstract_end_date => [:get,:post], :tag_cloud_by_year => :get, :full_year_list => :get, :year_list => :get, :journal_list => :get, :endnote => :get, :full_tagged_abstracts => :get, :tagged_abstracts => [:get, :post] }
  map.resources :graphs, :only => [:none], :member => {:show_member => :get, :show_org => :get}
  map.resources :graphviz, :only => [:none], :member => {:investigator_wheel => :get, :org_wheel => :get, :show_member => :get, :show_member_mesh => :get, :show_mesh => :get, :show_org_mesh => :get, :show_org => :get, :show_org_org => :get, :show_member_award => :get}
  map.investigator_wheel_data 'graphviz/:id/investigator_wheel_data.js', :action =>'investigator_wheel_data', :controller => 'graphviz', :conditions => {:method=>[:get,:post]}
  map.org_wheel_data 'graphviz/:id/org_wheel_data.js', :action =>'org_wheel_data', :controller => 'graphviz', :conditions => {:method=>[:get,:post]}
  map.connect 'orgs/abstracts_during_period/:id', :controller => 'orgs', :action => 'abstracts_during_period'
  map.connect 'ccsg', :controller => 'profiles', :action => 'ccsg', :conditions => { :method => :get }
  map.connect 'admin', :controller => 'profiles', :action => 'ccsg', :conditions => { :method => :get }
  map.tag_cloud 'tag_cloud', :controller => 'abstracts', :action => 'tag_cloud', :conditions => { :method => :get }
  map.impact_factor 'impact_factor/:year/:sortby', :controller => 'abstracts', :action => 'impact_factor', :conditions => { :method => :get }
  map.formatted_impact_factor 'impact_factor/:year.:format', :controller => 'abstracts', :action => 'impact_factor', :sortby=>'', :conditions => { :method => :get }
  map.high_impact 'high_impact.:format', :controller => 'abstracts', :action => 'high_impact', :conditions => { :method => :get }
  map.org_nodes 'org_nodes/:id', :controller => 'graphs', :action => 'org_nodes' #need this for some of the flash xml calls
  map.member_nodes 'member_nodes/:id', :controller => 'graphs', :action => 'member_nodes' #need this for some of the flash xml calls
  map.profile_edit 'profiles_edit/:id', :controller => 'profiles', :action => 'edit' #need this to work with a form
  map.publications_edit 'publications_edit/:id', :controller => 'profiles', :action => 'edit_pubs' #need this to work with a form
  map.member_protovis_data "member_protovis_data/:id", :controller => 'cytoscape', :action => 'member_protovis_data'
  map.member_cytoscape_data "member_cytoscape_data/:id/:depth/:include_publications/:include_awards/:include_studies", :controller => 'cytoscape', :action => 'member_cytoscape_data'
  map.org_cytoscape_data "org_cytoscape_data/:id/:depth/:include_publications/:include_awards/:include_studies", :controller => 'cytoscape', :action => 'org_cytoscape_data'
  map.chord_date_data "cytoscape/:start_date/:end_date/d3_date_data.:format", :controller => 'cytoscape', :action => 'd3_date_data'
  map.chord_by_date "cytoscape/:start_date/:end_date/chord_by_date", :controller => 'cytoscape', :action => 'chord_by_date'
  map.investigators_search "investigators_search/:id", :controller => 'investigators', :action => 'investigators_search'
  map.investigators_search_all "investigators_search_all/:id", :controller => 'investigators', :action => 'search'
  map.direct_search "direct_search/:id", :controller => 'investigators', :action => 'direct_search', :format=>'xml'
  map.proxy_googlechart "proxy_googlechart/:id", :controller => 'sparklines', :action => 'proxy_googlechart'
  map.cytoscape_member "cytoscape/:id/:depth", :controller => 'cytoscape', :action => 'show'
  map.cytoscape_show_all "cytoscape/:id/show_all/:depth", :controller => 'cytoscape', :action => 'show_all'
  map.cytoscape_awards "cytoscape/:id/awards/:depth", :controller => 'cytoscape', :action => 'awards'
  map.cytoscape_studies "cytoscape/:id/studies/:depth", :controller => 'cytoscape', :action => 'studies'
  map.cytoscape_show_org "cytoscape/:id/show_org/:depth", :controller => 'cytoscape', :action => 'show_org'
  map.cytoscape_awards_org "cytoscape/:id/awards_org/:depth", :controller => 'cytoscape', :action => 'awards_org'
  map.send_graphviz_image 'send_graphviz_image/:id/:analysis/:distance/:stringency/:include_orphans/:start_date/:end_date/:program.:format', :controller => 'graphviz', :action => 'send_graphviz_image'
  map.send_graphviz_image_orig 'send_graphviz_image/:id/:analysis/:distance/:stringency/:include_orphans/:program.:format', :controller => 'graphviz', :action => 'send_graphviz_image'
  map.restless_graphviz 'get_graphviz/', :controller => 'graphviz', :action => 'get_graphviz'
    
#  map.graphviz 'graph/:id/graphviz/:distance/:stingency/:program.:format', :controller => 'graphviz', :action => 'graphviz'
  map.logout "/logout", :controller => 'access', :action => 'logout'

  map.connect ':controller/:id/:action/:page'
  map.connect ':controller/:id/:action'  #need this for some of the rjs calls and the sparklines

#  map.root :controller => 'abstracts', :action => 'list', :conditions => { :method => :get }

end
