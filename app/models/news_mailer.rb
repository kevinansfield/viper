class NewsMailer < ActionMailer::ARMailer
  
  helper :application
  
  def posted_news(news)
    users = User.find_all_for_news_delivery
    users.each do |user|
      @recipients  = user.email
      @from        = "\"#{SITENAME}\" <#{VIPER_EMAIL}>"
      @subject     = "#{SITENAME} - #{news.title}"
      @sent_on     = Time.now
      @body[:user] = user
      @body[:news] = news
    end
  end
  
end
