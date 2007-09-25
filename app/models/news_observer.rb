class NewsObserver < ActiveRecord::Observer
  
  def after_create(news)
    NewsMailer.deliver_posted_news(news) if news.send_as_email?
  end

  def after_save(news)
  end
end
