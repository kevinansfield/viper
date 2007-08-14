# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  # Generates html for top nav links, including active page styling
  def nav_link(name, options = {}, html_options = nil, *parameters_for_method_reference)
    if html_options
      html_options = html_options.stringify_keys
      convert_options_to_javascript!(html_options)
      tag_options = tag_options(html_options)
    else
      tag_options = nil
    end
    
    if current_page?(options)
      current = " class=\"active\""
    end
     
    url = options.is_a?(String) ? options : self.url_for(options, *parameters_for_method_reference)
    "<li#{current}><a href=\"#{url}\"#{tag_options}><b>#{name || url}</b></a></li>"
  end
end
