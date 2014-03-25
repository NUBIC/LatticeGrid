# -*- coding: utf-8 -*-
LatticeGrid::Application.routes.draw do

  root to: 'welcome#index'
  match 'investigators/:id/collaborators.js' => 'investigators#collaborators', as: :collaborators_investigator, via: :get
  match 'investigators/:id/barchart.js' => 'investigators#barchart', as: :barchart_investigator, via: :get
  match 'cytoscape/:id/d3_investigator_wordle_data.js' => 'cytoscape#d3_investigator_wordle_data', as: :d3_investigator_wordle_data, via: :get
  match 'cytoscape/:id/d3_investigator_similarity_wordle_data.js' => 'cytoscape#d3_investigator_similarity_wordle_data', as: :d3_investigator_similarity_wordle_data, via: :get
  match 'cytoscape/:id/d3_investigator_difference_wordle_data.js' => 'cytoscape#d3_investigator_difference_wordle_data', as: :d3_investigator_difference_wordle_data, via: :get
  match 'cytoscape/:id/d3_investigator_chord_data.js' => 'cytoscape#d3_investigator_chord_data', as: :d3_investigator_chord_data, via: :get
  match 'cytoscape/d3_all_investigators_chord_data.js' => 'cytoscape#d3_all_investigators_chord_data', as: :d3_all_investigators_chord_data, via: :get
  match 'cytoscape/:id/d3_program_investigators_chord_data.js' => 'cytoscape#d3_program_investigators_chord_data', as: :d3_program_investigators_chord_data, via: :get
  match 'cytoscape_d3_investigator_edge_data.js' => 'cytoscape#d3_investigator_edge_data', as: :d3_investigator_edge_data, via: :get
  match 'orgs/:id/barchart.js' => 'orgs#barchart', as: :barchart_org, via: :get
  match 'investigators/:id/tag_cloud_side.js' => 'investigators#tag_cloud_side', as: :tag_cloud_side_investigator, via: :get
  match 'copublications/:id/tag_cloud_side.js' => 'copublications#tag_cloud_side', as: :tag_cloud_side_copublication, via: :get
  match 'investigators/:id/tag_cloud.js' => 'investigators#tag_cloud', as: :tag_cloud_investigator, via: :get
  match 'copublications/:id/tag_cloud.js' => 'copublications#tag_cloud', as: :tag_cloud_copublication, via: :get
  match 'orgs/:id/short_tag_cloud.js' => 'orgs#short_tag_cloud', as: :short_tag_cloud_org, via: :get
  match 'orgs/:id/tag_cloud.js' => 'orgs#tag_cloud', as: :tag_cloud_org, via: [:get, :post]
  match 'abstracts/:id/tag_cloud_by_year.js' => 'abstracts#tag_cloud_by_year', as: :tag_cloud_by_year_abstract, via: :get
  match '/investigators/:id/tag_cloud_list.json' => 'investigators#tag_cloud_list', as: :tag_cloud_list, via: :get

  resources :abstracts, only: [:index, :show] do
    collection do
      get :feed
      get :search
      post :search
      get :tag_cloud
      get :current
      get :add_pubmed_ids
      post :add_pubmed_ids
      get :update_pubmed_id
      post :update_pubmed_id
      get :add_abstracts
      get :high_impact_by_month
      get :high_impact
    end
    member do
      get :set_deleted_date
      post :set_deleted_date
      get :set_is_cancer
      post :set_is_cancer
      get :impact_factor
      get :set_investigator_abstract_end_date
      post :set_investigator_abstract_end_date
      get :tag_cloud_by_year
      get :full_year_list
      get :year_list
      get :journal_list
      get :endnote
      get :full_tagged_abstracts
      get :tagged_abstracts
      post :tagged_abstracts
    end
  end

  resources :graphs, only: [:none] do
    member do
      get :show_member
      get :show_org
    end
  end

  resources :graphviz, only: [:none] do
    member do
      get :investigator_wheel
      get :org_wheel
      get :show_member
      get :show_member_mesh
      get :show_mesh
      get :show_org_mesh
      get :show_org
      get :show_org_org
      get :show_member_award
    end
  end

  resources :admin

  match 'graphviz/:id/investigator_wheel_data.js' => 'graphviz#investigator_wheel_data', as: :investigator_wheel_data, via: [:get, :post]
  match 'graphviz/:id/org_wheel_data.js' => 'graphviz#org_wheel_data', as: :org_wheel_data, via: [:get, :post]

  match 'investigators/:id/show/:page' => 'investigators#show', as: :show_investigator, via: :get
  match 'orgs/:id/show/:page' => 'orgs#show', as: :show_org, via: :get
  match 'abstracts/:id/year_list/:page' => 'abstracts#year_list', as: :abstracts_by_year, via: :get
  match 'abstracts/:id/search/:page' => 'abstracts#year_list', as: :abstracts_search_by_year, via: :get
  match 'abstracts/search/:page' => 'abstracts#search', as: :abstracts_searchpage, via: [:get, :post]
  match 'abstracts/search' => 'abstracts#search', as: :abstracts_search, via: :get
  match 'profiles/investigator_listing/:id' => 'profiles#investigator_listing', as: :investigator_listing
  match 'awards/listing' => 'awards#listing', as: :award_listing
  match 'awards/recent' => 'awards#recent', as: :recent_awards, via: [:get, :post]
  match 'awards/ad_hoc_by_pi' => 'awards#ad_hoc_by_pi', as: :ad_hoc_by_pi_awards, via: [:get, :post]
  match 'studies/ad_hoc_by_pi' => 'studies#ad_hoc_by_pi', as: :ad_hoc_by_pi_studies, via: [:get, :post]
  match 'orgs/index' => 'orgs#index', as: :index_orgs

  resources :orgs, only: [:index, :show] do
    collection do
      get :stats
      get :period_stats
      post :period_stats
      get :list
      get :centers
      get :orgs
      get :departments
      get :programs
      get :department_collaborations
      get :investigator_abstracts_during_period
      post :investigator_abstracts_during_period
      get :classifications
    end
    member do
      get :full_show
      get :show_investigators
      post :list_abstracts_during_period_rjs
      get :classification_orgs
      get :program_members
    end
  end

  resources :investigators, only: [:index, :show] do
    collection do
      get :list_all
      post :list_all
      get :listing
      post :list_by_ids
      get :list_by_ids
    end
    member do
      get :full_show
      get :show_all_tags
      get :publications
      get :abstract_count
      get :show_colleagues
      get :preview
      get :search
      get :investigators_search
      get :research_summary
      get :tag_cloud_list
      get :title
      get :home_department
      get :bio
      get :email
      get :affiliations
    end
  end

  resources :cytoscape, only: [:index, :show] do
    collection do
      get :d3_data
      get :chord_by_date
      post :chord_by_date
      get :all_investigator_chord
      get :investigator_edge_bundling
      post :show_all_orgs
      get :show_all_orgs
      get :chord
      post :show_all_orgs_old
      get :show_all_orgs_old
      post :export
      get :export
    end
    member do
      get :showjs
      get :investigators
      get :protovis
      get :jit
      get :awards
      get :studies
      get :d3_data
      get :investigator_wordle
      get :simularity_wordle
      get :difference_wordle
      get :program_chord
      get :investigator_chord
      get :all_investigator_chord
      get :show_org
      get :show_org_org
      get :awards_org
      get :studies_org
      get :show_all
      get :org_all
    end
  end

  resources :awards, only: [:index, :show] do
    collection do
      get :disallowed
      post :disallowed
      get :listing
      post :listing
      get :org
      post :org
    end
    member do
      get :investigator
      get :org
      post :org
    end
  end

  resources :studies, only: [:index, :show] do
    collection do
      get :disallowed
      post :disallowed
      get :listing
      post :listing
    end
    member do
      get :investigator
      get :org
    end
  end

  resources :profiles, except: [:destroy, :new] do
    collection do
      get :list_orgs
      get :edit_orgs
      post :edit_orgs
      put :edit_orgs
      put :update_orgs
      get :splash
      get :recent_unvalidated
      get :recent
      get :ccsg
      get :admin
      get :list_summaries
      get :list_summaries_by_program
      post :list_summaries_by_program
      get :list_investigators
      get :edit_investigators
    end
    member do
      get :reminder
      get :edit_pubs
      get :investigator_listing
      post :investigator_listing
    end
  end

  resources :audits, only: [:index, :show] do
    collection do
      get :view_logins
      get :view_all_logins
      get :view_approved_profiles
      get :view_approved_publications
      get :faculty_data
      get :login_data
      get :approved_profile_data
      get :approved_publication_data
      get :view_publication_approvers
      get :view_profile_approvers
      get :view_logins_without_approvals
    end
  end

  resources :mesh, only: [:index] do
    member do
      get :search
      get :investigators
      get :investigator
      get :investigator_tags
      get :tag_count
      get :investigator_count
    end
  end

  match 'mesh/investigator/:username.:format' => 'mesh#investigator', as: :investigator_mesh_tags, via: :get
  match 'investigators/:username/abstract_count.:format' => 'investigators#abstract_count', as: :investigator_abstract_count, via: :get

  resources :copublications, only: [:show] do
    member do
      get :investigator_colleagues
    end
  end

  match 'orgs/abstracts_during_period/:id' => 'orgs#abstracts_during_period'
  match 'ccsg' => 'profiles#ccsg', via: :get
  match 'admin' => 'profiles#ccsg', via: :get
  match 'tag_cloud' => 'abstracts#tag_cloud', as: :tag_cloud, via: :get
  match 'impact_factor/:year/:sortby' => 'abstracts#impact_factor', as: :impact_factor, via: :get
  match 'impact_factor/:year.:format' => 'abstracts#impact_factor', as: :formatted_impact_factor, :sortby => '', via: :get
  match 'high_impact.:format' => 'abstracts#high_impact', as: :high_impact, via: :get
  match 'org_nodes/:id' => 'graphs#org_nodes', as: :org_nodes
  match 'member_nodes/:id' => 'graphs#member_nodes', as: :member_nodes
  # match 'profiles_edit/:id' => 'profiles#edit', as: :profile_edit, via: [:get, :post]
  # match 'publications_edit/:id' => 'profiles#edit_pubs', as: :publications_edit, via: [:get, :post]
  match '/profiles/admin_edit', to: 'profiles#admin_edit', as: :admin_profiles_edit, via: :post # added psf for Rails upgrade - to replace two lines above
  match 'member_protovis_data/:id' => 'cytoscape#member_protovis_data', as: :member_protovis_data
  match 'member_cytoscape_data/:id/:depth/:include_publications/:include_awards/:include_studies' => 'cytoscape#member_cytoscape_data', as: :member_cytoscape_data
  match 'org_cytoscape_data/:id/:depth/:include_publications/:include_awards/:include_studies' => 'cytoscape#org_cytoscape_data', as: :org_cytoscape_data
  match 'org_org_cytoscape_data/:id/:depth/:include_publications/:include_awards/:include_studies' => 'cytoscape#org_org_cytoscape_data', as: :org_org_cytoscape_data
  match 'all_org_cytoscape_data/:include_publications/:include_awards/:include_studies/:start_date/:end_date' => 'cytoscape#all_org_cytoscape_data', as: :all_org_cytoscape_data
  match 'cytoscape/:start_date/:end_date/d3_date_data.:format' => 'cytoscape#d3_date_data', as: :chord_date_data
  match 'cytoscape/:start_date/:end_date/chord_by_date' => 'cytoscape#chord_by_date', as: :chord_by_date
  match 'investigators_search/:id' => 'investigators#investigators_search', as: :investigators_search
  match 'investigators_search_all/:id' => 'investigators#search', as: :investigators_search_all
  # this will handle the main search - replacing 'investigators#investigators_search', 'investigators#search', & 'abstracts#search'
  match 'welcome/search' => 'welcome#search', as: :welcome_search, via: :get
  match 'welcome/unauthorized' => 'welcome#unauthorized', as: :welcome_unauthorized, via: :get
  match 'direct_search/:id' => 'investigators#direct_search', as: :direct_search, :format => 'xml'
  match 'proxy_googlechart/:id' => 'sparklines#proxy_googlechart', as: :proxy_googlechart
  match 'cytoscape/:id/:depth' => 'cytoscape#show', as: :cytoscape_member
  match 'cytoscape/:id/show_all/:depth' => 'cytoscape#show_all', as: :cytoscape_show_all
  match 'cytoscape/:id/awards/:depth' => 'cytoscape#awards', as: :cytoscape_awards
  match 'cytoscape/:id/studies/:depth' => 'cytoscape#studies', as: :cytoscape_studies
  match 'cytoscape/:id/show_org/:depth' => 'cytoscape#show_org', as: :cytoscape_show_org
  match 'cytoscape/:id/awards_org/:depth' => 'cytoscape#awards_org', as: :cytoscape_awards_org
  match 'cytoscape/:id/d3_investigator_data' => 'cytoscape#d3_investigator_data', as: :cytoscape_publications_investigator
  match 'send_graphviz_image/:id/:analysis/:distance/:stringency/:include_orphans/:start_date/:end_date/:program.:format' => 'graphviz#send_graphviz_image', as: :send_graphviz_image
  match 'send_graphviz_image/:id/:analysis/:distance/:stringency/:include_orphans/:program.:format' => 'graphviz#send_graphviz_image', as: :send_graphviz_image_orig
  match 'get_graphviz/' => 'graphviz#get_graphviz', as: :restless_graphviz
  match '/logout' => 'access#logout', as: :logout
  match ':controller/:id/:action/:page' => '#index'
  match ':controller/:id/:action' => '#index'
end
