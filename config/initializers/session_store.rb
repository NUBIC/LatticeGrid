# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_isb_colleagues_session',
  :secret      => '7a645c541df5c7345369bc637bac7d1f44b357a82e35c4e59643958d16944b7aa0227040a3c9569a198869a25d5ade893862644b3e3d20327bc46c7729d6023a'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
