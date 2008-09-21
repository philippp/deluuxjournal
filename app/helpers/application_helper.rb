# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def app_link_to(name, options = {}, html_options = nil)
      params.each{ |k,v|
        if k[0..2] == "dl_"
          options[k] = v
        end
      }
    link_to(name, options, html_options)
  end

  def abbreviate(original, max_length)
    return original if original.length < max_length
    return original[0..max_length-3]+"..."
  end

  def deluux_loc
    DELUUX_LOC
  end

  def app_id
    APP_ID
  end

  def is_owner?
    params[:dl_sig_owner_user] == params[:dl_sig_user]
  end

  def logged_in? 
    params[:dl_sig_user].to_i > 0 
  end
  
end
