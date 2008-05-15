# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def deluux_loc
    DELUUX_LOC
  end
  
  def app_id
    APP_ID
  end
  
  def is_owner?
    params[:dl_sig_owner_user] == params[:dl_sig_user]
  end

end
