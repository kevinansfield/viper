require File.dirname(__FILE__) + '/../spec_helper'

describe ForumPost do
  before(:each) do
    @forum_post = ForumPost.new
  end

  it "should be valid" do
    @forum_post.should be_valid
  end
end
