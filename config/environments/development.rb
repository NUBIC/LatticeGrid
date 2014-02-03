# -*- coding: utf-8 -*-
LatticeGrid::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  # Turn on page caching
  config.action_controller.perform_caching = true

  config.aker do
    # The authentication protocol to use for interactive access.
    # `:form` is the default.
    # ui_mode :cas

    # The authentication protocol(s) to use for non-interactive
    # access.  There is no default.
    # api_mode :http_basic

    # The portal to which this application belongs.  Optional.
    # portal :LatticeGrid
    login_config = File.join(Rails.root, %w(config logins development.yml))
    authority Aker::Authorities::Static.from_file(login_config)
  end

  # set the lattice_grid_instance for this env
  lattice_grid_instance
end
