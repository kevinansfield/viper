# == Schema Information
# Schema version: 49
#
# Table name: feeds
#
#  id          :integer(11)     not null, primary key
#  user_id     :integer(11)     
#  activity_id :integer(11)     
#

class Feed < ActiveRecord::Base
  belongs_to :activity
  belongs_to :user
end
