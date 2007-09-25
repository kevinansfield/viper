class NewsObserver < ActiveRecord::Observer
  
  def after_create(news)
    if news.send_as_email?
      users = User.find_all_for_news_delivery
      users.each do |user|
        NewsMailer.deliver_posted_news(news, user)
      end
    end
  end

  def after_save(news)
  end
end
