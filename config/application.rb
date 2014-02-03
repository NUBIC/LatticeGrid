# -*- coding: utf-8 -*-
require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(assets: %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module LatticeGrid
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  class Application < Rails::Application
    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += Dir["#{config.root}/lib/**/"]

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.

    config.time_zone = 'UTC'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = 'utf-8'

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.action_controller.page_cache_directory = "#{::Rails.root}/public/cache"

    # necessary in order to run rake db:test:prepare
    # so that the *_vector columns are included in the test database
    # preferrably this would only be in the environments/test.rb file
    # but apparently this does not work
    config.active_record.schema_format = :sql
  end

  def LatticeGrid.the_instance
    if Rails.env == 'development'
      # 'defaults'
      'Feinberg'
    else
      case "#{File.expand_path(Rails.root)}"
      when /fsm/i
        'Feinberg'
      when /cancer/i
        'RHLCCC'
      when /rhlccc/i
        'RHLCCC'
      when /ccne/i
        'CCNE'
      when /lls/i
        'LLS'
      when /umich/i
        'UMich'
      when /uwisc/i
        'UWCCC'
      when /stanford/i
        'Stanford'
      when /ucsf/i
        'UCSF'
      when /cinj/i
        'CINJ'
      when /uchicago/i
        'UChicago'
      when /uic/i
        'UIC'
      when /aas/i
        'AAS'
      else
        'defaults'
      end
    end
  end

end

require 'will_paginate'
require 'taggable_pagination'
require 'taggable_information'

def lattice_grid_instance
  # LatticeGrid is defined above
  if defined?(@@lattice_grid_instance) && !@@lattice_grid_instance.blank?
    return @@lattice_grid_instance
  end
  @@lattice_grid_instance = 'defaults'

  # determine which lattice grid instance using logic above
  the_instance = LatticeGrid.the_instance
  if defined?(LatticeGrid) and !LatticeGrid.blank? and !the_instance.blank?
    @@lattice_grid_instance = the_instance
  end
  @@lattice_grid_instance
end

