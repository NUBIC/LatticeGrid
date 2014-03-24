# -*- coding: utf-8 -*-

##
# Helper module for profiles controller
module ProfilesHelper
  require 'config' # adds allowed_ips list
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
    return Investigator.new(username: 'invalid') if !defined?(current_user) || current_user.nil?
    return @@current_user_model if current_user_model_exists?
    @@current_user_model = Investigator.find_by_username(current_user.username.strip.downcase)
    @@current_user_model = Investigator.new(username: current_user.username.strip.downcase) if @@current_user_model.blank?
    @@current_user_model
  end

  def current_user_model_exists?
    defined?(@@current_user_model) &&
    !@@current_user_model.blank? &&
    !@@current_user_model.username.blank? &&
    @@current_user_model.username == current_user.username.strip.downcase
  end

  # validate if a login has occurred
  def check_login
    begin
      if (current_user.blank? || current_user.username.blank?) && !session[:user_id].blank?
        logger.error('logout occurred')
        session[:user_id] = nil
      elsif session[:user_id].blank? && !current_user_model.blank? && !current_user.blank?
        session[:user_id] = current_user_model.id
        session[:user_id] =  '1' if session[:user_id].blank?
        logger.error('login occurred')
        log_request('login')
      elsif (current_user.blank? || current_user.username.blank?) && session[:user_id].blank?
        # no logged in user and no session
        redirect_to check_login_redirect_path
      end
    rescue NoMethodError => nme
      session[:user_id] = nil unless session[:user_id].blank?
      logger.error("ProfilesHelper#check_login - #{nme.message}")
      redirect_to '/login'
    end
  end

  def check_login_redirect_path
    if LatticeGridHelper.require_authentication?
      "/login?url=#{Rack::Utils.escape(request.fullpath)}"
    else
      '/welcome/unauthorized'
    end
  end

  # Logging helper for the database activity log
  def log_request(activity = nil)
    return unless @logged.nil?
    @logged = true
    if current_user_model.blank? || current_user_model.id.blank?
      the_id = -1
     else
      the_id = current_user_model.id
    end
    action = activity || controller_name + ':' + action_name
    log_entry = Log.create(
        investigator_id: the_id,
        activity: action,
        controller_name: controller_name,
        action_name: action_name,
        created_ip: request.remote_ip,
        params: params.inspect)
     log_entry.save
  end

end
