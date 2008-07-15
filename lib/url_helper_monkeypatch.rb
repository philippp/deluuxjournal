module ActionView
    module Helpers #:nodoc:
      module UrlHelper

        def link_to(name, options = {}, html_options = nil)
          url = case options
                when String
                  options
                when :back
                  @controller.request.env["HTTP_REFERER"] || 'javascript:history.back()'
                else
                  options = add_dl_keys options
                  self.url_for(options)
                end

          if html_options
            html_options = html_options.stringify_keys
            href = html_options['href']
            convert_options_to_javascript!(html_options, url)
            tag_options = tag_options(html_options)
          else
            tag_options = nil
          end

          href_attr = "href=\"#{url}\"" unless href
          "<a #{href_attr}#{tag_options}>#{name || url}</a>"
        end


        # Provides a set of methods for making links and getting URLs that
        # depend on the routing subsystem (see ActionController::Routing).
        # This allows you to use the same format for links in views
        # and controllers.

        def url_for(options = {})
          case options
          when Hash
            options = add_dl_keys options
            show_path =  options[:host].nil? ? true : false
            options = { :only_path => show_path }.update(options.symbolize_keys)
            escape  = options.key?(:escape) ? options.delete(:escape) : true
            url     = @controller.send(:url_for, options)
          when String
            escape = true
            url    = options
          when NilClass
            url = @controller.send(:url_for, nil)
          else
            escape = false
            url    = polymorphic_path(options)
          end

          escape ? escape_once(url) : url
        end
      end
  end
end


