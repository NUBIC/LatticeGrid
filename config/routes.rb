ActionController::Routing::Routes.draw do |map|
  map.connect 'abstracts/admin', :controller => 'abstracts', :action => 'ccsg', :conditions => { :method => :get } #legacy url. delete after 12/1/09
  map.show_investigator 'investigators/:id/show/:page', {:controller => "investigators",:action => "show", :conditions => { :method => :get }  }
  map.abstracts_by_year 'abstracts/:id/year_list/:page', {:controller => "abstracts",:action => "year_list", :conditions => { :method => :get } }
  map.index_programs 'programs/index', :controller => 'programs', :action => 'index'  #handle the route for programs_path to make sure it is cached properly
  map.resources :programs, :only => [:index, :show], :collection => { :program_stats => :get, :list_programs => :get }, 
    :member => {:full_show => :get, :show_investigators => :get, :list_abstracts_during_period_rjs => :post}
   map.resources :investigators, :only => [:index, :show], :member => {:full_show => :get}, :collection => { :list_all => :get }
   
  map.resources :abstracts, :only => [:index, :show], :collection => { :search => [:get, :post], :ccsg => :get, :tag_cloud => :get },
    :member => {:full_year_list => :get, :endnote => :get, :tag => :get, :full_tag => :get, }
  map.resources :graphs, :only => [:none], :member => {:show_member => :get, :show_program => :get}

  map.connect 'programs/abstracts_during_period/:id', :controller => 'programs', :action => 'abstracts_during_period'
  map.connect 'ccsg', :controller => 'abstracts', :action => 'ccsg', :conditions => { :method => :get }
  map.connect 'admin', :controller => 'abstracts', :action => 'ccsg', :conditions => { :method => :get }
  map.abstract_search 'abstracts/search/:page', :controller => 'abstracts', :action => 'search', :method => [:get, :post]
  map.tag_cloud 'tag_cloud', :controller => 'abstracts', :action => 'tag_cloud', :conditions => { :method => :get }
  map.impact_factor 'impact_factor/:year/:sortby', :controller => 'abstracts', :action => 'impact_factor', :conditions => { :method => :get }
  map.connect 'impact_factor/:year', :controller => 'abstracts', :action => 'impact_factor', :sortby=>'', :conditions => { :method => :get }
  map.connect 'impact_factor', :controller => 'abstracts', :action => 'impact_factor', :conditions => { :method => :get }
  map.high_impact 'high_impact', :controller => 'abstracts', :action => 'high_impact', :conditions => { :method => :get }
  map.program_nodes 'program_nodes/:id', :controller => 'graphs', :action => 'program_nodes' #need this for some of the flash xml calls
  map.member_nodes 'member_nodes/:id', :controller => 'graphs', :action => 'member_nodes' #need this for some of the flash xml calls
  map.connect ':controller/:id/:action/:page'
  map.connect ':controller/:id/:action'  #need this for some of the rjs calls and the sparklines

#  map.root :controller => 'abstracts', :action => 'list', :conditions => { :method => :get }


  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'

end
