# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Enable the breakpoint server that script/breakpointer connects to
#config.breakpoint_server = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = true
config.action_controller.relative_url_root           = '/cancer' if ENV["HOME"] =~ /home/

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

config.after_initialize do
  Bcsec.configure do
    if RAILS_ROOT =~ /Users/ 
      login_config = File.join(RAILS_ROOT, %w(config logins development.yml))
      authority Bcsec::Authorities::Static.from_file(login_config)
      puts "loading local static bcsec file"
    else
      authority :netid
      central '/etc/nubic/bcsec-prod.yml'
    end
  end
end

