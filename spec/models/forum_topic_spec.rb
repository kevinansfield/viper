require File.dirname(__FILE__) + '/../spec_helper'

describe ForumTopic do
  before(:each) do
    @forum_topic = ForumTopic.new
  end

  it "should be valid" do
    @forum_topic.should be_valid
  end
end
