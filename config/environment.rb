# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
#RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  config.gem 'mislav-will_paginate',
            :lib => 'will_paginate',
            :source => 'http://gems.github.com',
            :version => '~> 2.3.6'
  
  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"
  # config.gem "ruby-graphviz"
  
  #config.gem "pg"  # remove if ruby 1.8.5 or earlier is used

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]
  config.plugins = [ :awesome_nested_set, :princely, :acts_as_taggable_on_steroids ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
  config.action_controller.session = {
    :session_key => '_test_session',
    :secret      => 'this is a  2.0 rails requirement'
  }
  
  # change the cache root
  #config.action_controller.page_cache_directory = File.join(RAILS_ROOT, 'public', 'cache')
  
end


  # Add new inflection rules using the following format 
  # (all these examples are active by default):
ActiveSupport::Inflector.inflections do |inflect|
  #   inflect.plural /^(ox)$/i, '\1en'
  #   inflect.singular /^(ox)en/i, '\1'
  #   inflect.irregular 'person', 'people'
  #   inflect.uncountable %w( fish sheep )
    inflect.uncountable %w( mesh )
end

Time::DATE_FORMATS[:justdate] = "%m/%d/%Y"
#ActiveRecord::Validations::DateTime.us_date_format = true

#This require is here (After Rails has loaded) because
# it hooks into ActiveRecord and ActionView
require 'will_paginate'
require 'taggable_pagination'
require 'taggable_information'


begin
  require 'PDFRender'
  ActionView::Template.register_template_handler 'rpdf', ActionView::PDFRender
rescue NameError, LoadError
  puts "PDFRender didn't load properly"
end
begin
  require 'RMagick'
rescue NameError, LoadError
  puts "RMagick didn't load properly"
  # RMagick didn't load right
end
begin
  require 'sparklines'
rescue NameError, LoadError
  puts "sparklines didn't load properly"
  # sparklines didn't load right
end
