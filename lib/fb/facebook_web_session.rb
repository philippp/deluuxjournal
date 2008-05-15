# Copyright (c) 2007, Matt Pizzimenti (www.livelearncode.com)
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
# 
# Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
# 
# Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
# 
# Neither the name of the original author nor the names of contributors
# may be used to endorse or promote products derived from this software
# without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

#
# Some code was inspired by techniques used in Alpha Chen's old client.
# Some code was ported from the official PHP5 client.
#

require "fb/facebook_session"

module RFacebook
  
  class FacebookWebSession < FacebookSession
    
    attr_accessor :session_uid, :session_key
    attr_writer :request
    
    def get_valid_fb_params(params, timeout = nil, namespace = 'fb_sig')
      
      prefix = namespace + '_'
      prefix_len = prefix.length
      fb_params = Hash.new
      params.each do |k,v|
        if k.starts_with?(prefix)
          suffix = k.sub(prefix, '')
          fb_params[suffix] = v
        end
      end
      if (timeout and (fb_params['time'].nil? or (Time.now.to_i - fb_params['time'].to_i > timeout.to_i)))
        fb_params = {}
      end
      if (params[namespace].nil? or !verify_sig(fb_params, params[namespace]))
        fb_params = {}
      end
      @fb_params = fb_params
      return fb_params
    end
    
    def verify_sig (params, expected_sig)
      return generate_sig(params, @api_secret) == expected_sig
    end
    
    
    def generate_sig(params = {}, secret = {})
      begin
        args = []
        params.each do |k,v|
          s = "#{k}=#{v[0]}" if v and v.instance_of?(CGI::Cookie) and v[0]
          s = "#{k}=#{v}" if v.instance_of?(String)
          args << s
        end
        sorted_array = args.sort
        request_str = sorted_array.join("")
        param_signature = Digest::MD5.hexdigest("#{request_str}#{secret}") # uses Template method get_secret
        return param_signature
      rescue
        nil
      end
    end
    
    def do_get_session(auth_token)
      xml = auth_getSession('auth_token' => auth_token)
      ses = Hash.new
      ['uid','session_id','expires'].each { |k| 
        elem = xml.at(k)
        ses[k] = elem.nil? ? nil : elem.inner_html
      }

      puts ses.inspect;
      puts "Session.uid = "+ses['uid'].to_s
      return ses
    end
    
    def in_frame
      return (!@fb_params['in_canvas'].nil? or !@fb_params['in_iframe'].nil?)
    end
    
    def in_fb_canvas
      return !@fb_params['in_canvas'].nil? 
    end
    
    def mockajax?
      return !@fb_params['in_mockajax_url'].nil? 
    end
    
    def get_loggedin_user
      return session_uid
    end
    
    def current_url
      url = @request.request_uri
      #if leading slash then remove
      return url.sub('/', '') if url.starts_with?('/')
    end
    
    def require_install
      if (@session_uid)
        if users_isAppInstalled()
          return @session_uid
        end
      end
      redirect(get_install_url(current_url()))
    end
    
    def require_frame
      unless (in_frame())
        redirect(get_login_url(:next => current_url(), :fbframe => true))
      end
    end
    
    def get_add_url(nxt = nil)
      url = get_facebook_url() + '/add.php?api_key=' + @api_key
      unless nxt.nil?
        url += '&next=' + (nxt)
      end
      return url
    end
    
    def get_install_url(nxt = nil)
      url = get_facebook_url() + '/install.php?api_key=' + @api_key
      unless nxt.nil?
        url += '&next=' + (nxt)
      end
      return url
    end
    
    def get_facebook_url (subdomain='www')
      return "http://localhost"
    end
    
    # Function: get_login_url
    #   Gets the authentication URL
    #
    # Parameters:
    #   options.next          - the page to redirect to after login
    #   options.popup         - boolean, whether or not to use the popup style (defaults to true)
    #   options.skipcookie    - boolean, whether to force new Facebook login (defaults to false)
    #   options.hidecheckbox  - boolean, whether to show the "infinite session" option checkbox
    def get_login_url(options={})
      # options
      path_next = options[:next] ||= nil
      popup = (options[:popup] == nil) ? true : false
      skipcookie = (options[:skipcookie] == nil) ? false : true
      hidecheckbox = (options[:hidecheckbox] == nil) ? false : true
      fbframe = (options[:fbframe] == nil) ? false : true
      
      # get some extra portions of the URL
      optionalNext = (path_next == nil) ? "" : "&next=#{CGI.escape(path_next.to_s)}"
      optionalFrame = (fbframe == true) ? "&fbframe=true" : ""
      optionalPopup = (popup == true) ? "&popup=true" : ""
      optionalSkipCookie = (skipcookie == true) ? "&skipcookie=true" : ""
      optionalHideCheckbox = (hidecheckbox == true) ? "&hide_checkbox=true" : ""
      
      # build and return URL
      return "http://#{LOGIN_SERVER_BASE_URL}#{LOGIN_SERVER_PATH}?v=1.0&api_key=#{@api_key}#{optionalPopup}#{optionalNext}#{optionalSkipCookie}#{optionalHideCheckbox}#{optionalFrame}"
    end
    
    # Function: activate_with_token
    #   Gets the session information available after current user logs in.
    # 
    # Parameters:
    #   auth_token    - string token passed back by the callback URL
    def activate_with_token(auth_token)
      result = call_method("auth.getSession", {:auth_token => auth_token})
      if result != nil
        @session_uid = result.at("uid").inner_html
        @session_key = result.at("session_key").inner_html
      end
    end
    
    # Function: activate_with_previous_session
    #   Sets the session key directly (for example, if you have an infinite session key)
    # 
    # Parameters:
    #   key    - the session key to use
    def activate_with_previous_session(key)
      # set the session key
      @session_key = key
      
      # determine the current user's id
      result = call_method("users.getLoggedInUser")
      @session_uid = result.at("users_getLoggedInUser_response").inner_html
    end
    
    def is_valid?
      return (is_activated? and !session_expired?)
    end
    
    protected
    
    def is_activated?
      return (@session_key != nil)
    end
    
    # Function: get_secret
    #   Template method, used by super::signature to generate a signature
    def get_secret(params)
      
      return @api_secret
      
    end
    
  end
  
  
  
end