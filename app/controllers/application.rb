require "fb/facebook_web_session"
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  around_filter :catch_errors
  before_filter :create_fb_session

  class AccessDenied < StandardError; end
  class AuthenticationError < StandardError; end

  def self.protected_actions
    [ :edit, :update, :destroy ]
  end

  def check_auth
    raise AccessDenied unless is_owner?
  end

  def is_owner?
    params[:dl_sig_owner_user] == params[:dl_sig_user]
  end

  def logged_in? 
    params[:dl_sig_user].to_i > 0 
  end

  
  def catch_errors
    begin
      yield

    rescue AccessDenied
      flash[:notice] = "You can't go in there."
      redirect_to params[:dl_sig_root_loc]
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "Sorry, can't find that page."
      redirect_to params[:dl_sig_root_loc]
    end
  end

  def create_fb_session
    @api_key = params[:dl_sig_api_key]
    @api_secret = DELUUX_API_SECRET
    @fb_session = RFacebook::FacebookWebSession.new(@api_key, @api_secret)
    @fb_session.session_key = params[:dl_sig_session_key]
  end

  def app_redirect_to(options = {}, response_status = {})
      params.each{ |k,v|
        if k[0..2] == "dl_"
          options[k] = v
        end
      }
    redirect_to(options, response_status)
  end

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  #protect_from_forgery # :secret => '307b8a34c931d02b46ef87ce7449305c'
end
