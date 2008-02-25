require File.dirname(__FILE__) + '/../spec_helper'

describe Article do
  before(:each) do
    @article = Article.new
  end

  it "should be valid" do
    @article.should be_valid
  end
end
