require File.dirname(__FILE__) + '/../spec_helper'

describe Forum do
  define_models do
    model ForumTopic do
      stub :sticky, :sticky => 1, :last_updated_at => current_time - 132.days
    end
  end

  it "formats description with textile" do
    f = Forum.new :description  => '*Bold*'
    f.description.should        == '<p><strong>Bold</strong></p>'
    f.description_plain.should  == 'Bold'
    f.description_source.should == '*Bold*'
  end
  
  it "lists topics with sticky topics first" do
    forums(:default).topics.should == [forum_topics(:sticky), forum_topics(:other), forum_topics(:default)]
  end
  
  it "lists posts by created_at" do
    forums(:default).posts.should == [forum_posts(:default), forum_posts(:other)]
  end
  
  it "finds most recent post" do
    forums(:default).recent_post.should == forum_posts(:default)
  end
  
  it "finds most recent topic" do
    forums(:default).recent_topic.should == forum_topics(:other)
  end
  
  it "finds ordered forums" do
    Forum.ordered.should == [forums(:other), forums(:default)]
  end
end
