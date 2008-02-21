# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include TagsHelper
  
  def for_moderators_of(record, &block)
    moderator_of?(record) && concat(capture(&block), block.binding)
  end
  
  # Only outputs the link if current_user is an admin
  def link_to_if_admin(text, link)
    if logged_in?
      link_to(text, link) if current_user.admin?
    end
  end
  
  def link_to_if_owner(user, text, link)
    if logged_in? && current_user == user
      link_to(text, link)
    end
  end
  
  def link_to_unless_owner(user, text, link)
    if logged_in? && current_user != user
      link_to(text, link)
    end
  end
  
  def nav_link(name, tab, options = {})
    css = 'active' if tab.to_s == @current_tab.to_s
    content_tag :li, link_to(content_tag(:b, name), options), :class => css
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
  
  # Same as pluralize, but doesn't output the count
  def pluralize_without_count(count, singular, plural = nil)
    if count == 1 || count == '1'
      singular
    elsif plural
      plural
    elsif Object.const_defined?("Inflector")
      Inflector.pluralize(singular)
    else
      singular + "s"
    end
  end
  
  # Basic date-only formatting, eg. "28th March 2007"
  def basic_date(date)
    h date.strftime("#{date.day.en.ordinal} %B, %Y")
  end
  
  # Basic short date-only formatting, eg. "28th Mar, 2007"
  def basic_short_date(date)
    h date.strftime("#{date.day.en.ordinal} %b, %Y")
  end
  
  def textile_helper_link
    '<a href="/textile.html" class="lightwindow" title="Textile Formatting">Textile Formatting enabled</a>'
  end
  
  def feed_icon_tag(title, url)
    (@feed_icons ||= []) << { :url => url, :title => title }
    link_to image_tag('feed-icon.png', :size => '14x14', :alt => "Subscribe to #{title}"), url
  end
  
  def pagination(collection)
    if collection.page_count > 1
      "<p class='pages'>" + 'Pages' + ": <strong>" + 
      will_paginate(collection, :inner_window => 10, :next_label => "next", :prev_label => "previous") +
      "</strong></p>"
    end
  end
  
  def next_page(collection)
    unless collection.current_page == collection.page_count or collection.page_count == 0
      "<p style='float:right;'>" + link_to("Next page", { :page => collection.current_page.next }.merge(params.reject{|k,v| k=="page"})) + "</p>"
    end
  end
  
  def topic_title_link(topic, options)
    if topic.title =~ /^\[([^\]]{1,15})\]((\s+)\w+.*)/
      "<span class='flag'>#{$1}</span>" + 
      link_to(h($2.strip), forum_topic_path(@forum, topic), options)
    else
      link_to(h(topic.title), forum_topic_path(@forum, topic), options)
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
