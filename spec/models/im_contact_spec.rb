require File.dirname(__FILE__) + '/../spec_helper'

describe ImContact do
  before(:each) do
    @im_contact = ImContact.new
  end

  it "should be valid" do
    @im_contact.should be_valid
  end
end
