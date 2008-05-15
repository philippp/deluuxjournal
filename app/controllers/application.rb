# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  
  around_filter :catch_errors
  
  class AccessDenied < StandardError; end
  class AuthenticationError < StandardError; end

  def self.protected_actions
    [ :edit, :update, :destroy ]
  end

  def check_auth
    params[:dl_sig_owner_user] == params[:dl_sig_user] or raise AccessDenied
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
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  #protect_from_forgery # :secret => '307b8a34c931d02b46ef87ce7449305c'
end
