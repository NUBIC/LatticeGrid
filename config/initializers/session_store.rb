# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_cancer_latticegrid_session',
  :secret      => 'd191041bea4ebc0533e3f68b1bb41c5a1233162b24232a0e15e70764ae12598a4b419a127e69139ff2ae849d5d563a3405e00306a47270aba9adead393d9ba76'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
