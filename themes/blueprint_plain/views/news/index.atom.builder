atom_feed do |feed|
  feed.title "#{SITENAME} News"
  feed.updated(@news.first.created_at)
  
  for news_item in @news
  	feed.entry(news_item, :url => news_item_url(news_item)) do |entry|
  	  entry.title(news_item.title)
  	  entry.content(news_item.body, :type => :html)
  	end
  end
end