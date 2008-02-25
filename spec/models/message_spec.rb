require File.dirname(__FILE__) + '/../spec_helper'

describe Message do
  before(:each) do
    @message = Message.new
  end

  it "should be valid" do
    @message.should be_valid
  end
end
