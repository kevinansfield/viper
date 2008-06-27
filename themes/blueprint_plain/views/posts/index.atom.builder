atom_feed do |feed|
  feed.title "#{@user.full_name}'s Blog Posts | #{SITENAME}"
  feed.updated(@posts.first.created_at)
  
  for post in @posts
  	feed.entry(post.blog, post) do |entry|
  	  entry.title(post.title)
  	  entry.content(post.body, :type => :html)
  	  entry.author do |author|
  	  	author.name(post.blog.user.full_name)
  	  end
  	end
  end
end