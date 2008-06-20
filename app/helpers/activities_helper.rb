module ActivitiesHelper

  # Given an activity, return a message for the feed for the activity's class.
  def feed_message(activity)
    # Switch on the class.to_s.  (The class itself is long & complicated.)
    user = activity.user
    activity_type = activity.item.class.to_s
    case activity_type
    when "Post"
      post = activity.item
      blog = post.blog
      view_blog = blog_link("View #{user.name}'s blog", blog)
      %(#{user_link(user)} made a blog post titled
        #{post_link(blog, post)}.<br /> #{view_blog})
    when "Comment"
      # Switch on the commentable class as Comment is polymorphic
      comment_type = activity.item.commentable.class.to_s
      case comment_type
        when "Wall"
          %(#{user_link(user)} wrote on #{wall_link(activity.item.commentable.user)}.)
        when "Post"
          post = activity.item.commentable
          blog = post.blog
          %(#{user_link(user)} made a comment on
            #{someones(blog.user)} blog post #{post_link(blog, post)}.)
        else
          raise "Invalid comment type #{comment_type.inspect}"
      end
    when "Friendship"
      %(#{user_link(activity.item.user)} and
        #{user_link(activity.item.friend)}
        are now friends.)
    when "ForumPost"
      post = activity.item
      %(#{user_link(user)} made a post on the forum topic
        #{forum_topic_link(post.topic)}.)
    when "ForumTopic"
      %(#{user_link(user)} created the new discussion topic
        #{form_topic_link(activity.item)}.)
    when "Avatar"
      %(#{user_link(user)} updated their profile picture.)
    when "Profile"
      %(#{user_link(user)} updated their profile information.)
    when "Article"
      %(#{user_link(user)} posted an article titled #{article_link(activity.item)}.)
    when "Bio"
      %(#{user_link(user)} updated their bio information.)
    else
      raise "Invalid activity type #{activity_type.inspect}"
    end
  end
  
  def minifeed_message(activity)
    user = activity.user
    activity_type = activity.item.class.to_s
    case activity_type
    when "Post"
      post = activity.item
      blog = post.blog
      %(#{user_link(user)} made a
        #{post_link("new blog post", blog, post)})
    when "Comment"
      # Switch on the commentable class as Comment is polymorphic
      comment_type = activity.item.commentable.class.to_s
      case comment_type
        when "Post"
          post = activity.item.commentable
          %(#{user_link(user)} made a comment on #{someones(post.blog.user)} 
            #{post_link("blog post", post.blog, post)})
        when "Wall"
          %(#{user_link(user)} wrote on #{wall_link(activity.item.commentable.user)})
        else
          raise "Invalid comment type #{comment_type.inspect}"
      end
    when "Friendship"
      %(#{user_link(user)} and #{user_link(activity.item.friend)}
        have connected.)
    when "ForumPost"
      topic = activity.item.topic
      # TODO: deep link this to the post
      %(#{user_link(user)} made a #{forum_topic_link("forum post", topic)}.)
    when "User"
      %(#{user_link(user)} joined the network!)
    when "ForumTopic"
      %(#{user_link(user)} created a 
        #{forum_topic_link("new discussion topic", activity.item)}.)
    when "Avatar"
      %(#{user_link(user)} updated their profile picture.)
    when "Profile"
      %(#{user_link(user)} updated their profile information.)
    when "Article"
      %(#{user_link(user)} posted a #{article_link("new article", activity.item)}.)
    when "Bio"
      %(#{user_link(user)} updated their bio information.)
    else
      raise "Invalid activity type #{activity_type.inspect}"
    end
  end

  def someones(user, link = true)
    if link
      current_user == user ? "your" : "#{user_link(user)}'s"
    else
      current_user == user ? "your" : "#{user.name}'s"
    end
  end

  def user_link(text, user = nil)
    if user.nil?
      user = text
      text = user.name
    end
    link_to(text, user)
  end
  
  def blog_link(text, blog)
    link_to(text, blog_path(blog))
  end
  
  def post_link(text, blog, post = nil)
    if post.nil?
      post = blog
      blog = text
      text = post.title
    end
    link_to(text, blog_post_path(blog, post))
  end
  
  def forum_topic_link(text, topic = nil)
    if topic.nil?
      topic = text
      text = topic.title
    end
    link_to(text, forum_topic_posts_path(topic.forum, topic))
  end

  # Return a link to the wall.
  def wall_link(user)
    link_to("#{someones(user, false)} wall",
            user_path(user, :anchor => "wall"))
  end
  
  def article_link(text, article = nil)
    if article.nil?
      article = text
      text = article.title
    end
    link_to(text, category_article_path(article.category, article))
  end
end
