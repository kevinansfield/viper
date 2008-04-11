module ActivityLogger
  def add_activities(options = {})
    user = options[:user]
    activity = options[:activity] ||
               Activity.create!(:item => options[:item], :user => user)
    user.activities << activity
    user.friends.each { |c| c.activities << activity }
  end
end