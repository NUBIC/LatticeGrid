module ProfilesHelper
  require 'config' #adds allowed_ips list
  require 'ldap_utilities' 

  def before_create(model)
    model.created_ip ||= request.remote_ip if defined?(request)
    model.created_id = current_user_model.id if defined?(current_user_model)
    before_update(model)
  end 

  def before_update(model)
    model.updated_ip = request.remote_ip if defined?(request)
    model.updated_id = current_user_model.id if defined?(current_user_model)
  end 
  
  def current_user_model
    return Investigator.new(:username=>"invalid")  if ! defined?(current_user) or current_user.nil?
    return @@current_user_model if defined?(@@current_user_model) and ! @@current_user_model.blank? and ! @@current_user_model.username.blank? and @@current_user_model.username == current_user.username.strip.downcase
    @@current_user_model = Investigator.find_by_username(current_user.username.strip.downcase)
    if @@current_user_model.blank?
      #create the user
      # we don't want to do this for this application
      #@@current_user_model = create_the_user(current_user.username)
      @@current_user_model = Investigator.new(:username=>current_user.username.strip.downcase)
    end
     @@current_user_model
  end
    
  def create_the_user(username)
    return nil if username.blank?
    the_user = Investigator.new(:username=>username.strip.downcase)
    begin
      pi_data = GetLDAPentry(username) if LatticeGridHelper.do_ldap? 
      if pi_data.nil?
        if defined?(logger)
          logger.warn("Probable error reaching the LDAP server in GetLDAPentry: GetLDAPentry returned null using netid #{username}.")
        else
          puts "Probable error reaching the LDAP server in GetLDAPentry: GetLDAPentry returned null using netid #{username}."
        end
      elsif pi_data.blank?
        if defined?(logger)
          logger.warn("Entry not found. GetLDAPentry returned null using netid #{username}.")
        else
          puts "Entry not found. GetLDAPentry returned null using netid #{username}."
        end
      else
        ldap_rec = CleanPIfromLDAP(pi_data)
        the_user = BuildPIobject(ldap_rec)
        the_user = MergePIrecords(the_user,ldap_rec)
        if the_user.new_record?
          before_create(the_user)
          the_user.save!
        end
      end
    rescue Exception => error
      begin
        logger.error("Probable error reaching the LDAP server in GetLDAPentry: #{error.message}")
      rescue
        puts "Probable error reaching the LDAP server in GetLDAPentry: #{error.message}"
      end
    end
    the_user
  end
  
  #validate if a login has occurred
  def check_login
    if (current_user.blank? or current_user.username.blank?) and !session[:user_id].blank? 
      logger.error("logout occurred")
      session[:user_id] = nil
    elsif session[:user_id].blank? and !current_user_model.blank? and !current_user.blank? 
      session[:user_id] = current_user_model.id
      session[:user_id] =  '1' if session[:user_id].blank?
      logger.error("login occurred")
      log_request('login')
    end
  end

  # Logging helper for the database activity log
  
  def log_request(activity=nil)
    return if ! @logged.nil?
    @logged=true 
    if current_user_model.blank? or current_user_model.id.blank? then
      the_id = -1
     else
      the_id = current_user_model.id
    end
    log_entry = Log.create( 
        :investigator_id => the_id,
        :activity => activity || self.controller_name + ":" + self.action_name,
        :controller_name => self.controller_name,
        :action_name => self.action_name,
        :created_ip => request.remote_ip,
        :params => params.inspect)
     log_entry.save
  end
  
end
