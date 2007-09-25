# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  # Only outputs the link if current_user is an admin
  def link_to_if_admin(text, link)
    if logged_in?
      link_to(text, link) if current_user.admin?
    end
  end
  
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
  
  def limit_text(text, length = 18)
    unless text.blank?
      text = text.to_s
      if text.length < length
        text
      else
        "#{text[0,length]}&hellip;"
      end
    end
  end
  
  def fallback_if_blank(chosen, fallback)
    chosen.blank? ? fallback : chosen    
  end
  
  # Create as many of these as you like, each should call a different partial 
  # 1. Render 'shared/sidebar_box' partial with the given options and block content
  def titled_box(title, color, options = {}, &block)
    block_to_partial('shared/titled_box', options.merge(:title => title, :color => color), &block)
  end
   
  # Sample helper #2
  #def un_rounded_box(title, options = {}, &block)
  #  block_to_partial('shared/un_rounded_box', options.merge(:title => title), &block)
  #end
  
  def sidebar_one_helper
    "#{controller.sidebar_one}"
  end
  
  def sidebar_two_helper
    "#{controller.sidebar_two}"
  end
  
  def display_edit_link(user, link)
    user == current_user ? link : nil
  end
  
  # Return an appropriate friendship status message
  def friendship_status(user, friend)
    friendship = Friendship.find_by_user_id_and_friend_id(user, friend)
    return "#{fallback_if_blank friend.profile.first_name, friend.login} is not your friend (yet)." if friendship.nil?
    case friendship.status
      when 'requested'
        "#{fallback_if_blank friend.profile.first_name, friend.login} would like to be your friend."
      when 'pending'
        return "You have requested friendship from #{fallback_if_blank friend.profile.first_name, friend.login}"
      when 'accepted'
        return "#{fallback_if_blank friend.profile.first_name, friend.login} is your friend."
    end
  end

  private
  
  # Only need this helper once, it will provide an interface to convert a block into a partial.
  # 1. Capture is a Rails helper which will 'capture' the output of a block into a variable
  # 2. Merge the 'body' variable into our options hash
  # 3. Render the partial with the given options hash. Just like calling the partial directly.
  def block_to_partial(partial_name, options = {}, &block)
    options.merge!(:body => capture(&block))
    concat(render(:partial => partial_name, :locals => options), block.binding)
  end
end
