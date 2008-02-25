require File.dirname(__FILE__) + '/../spec_helper'

describe Blog do
  before(:each) do
    @blog = Blog.new
  end

  it "should be valid" do
    @blog.should be_valid
  end
end
