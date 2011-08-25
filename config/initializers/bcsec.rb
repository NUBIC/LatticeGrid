# In config/initializers/bcsec.rb
require "bcsec"
Bcsec.configure do
  # The authentication protocol to use for interactive access.
  # `:form` is the default.
  #ui_mode :form

  # The authentication protocol(s) to use for non-interactive
  # access.  There is no default.
  #api_mode :http_basic

  # The portal to which this application belongs.  Optional.
  #portal :ENU
end
