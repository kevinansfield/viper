require File.dirname(__FILE__) + '/../spec_helper'
include ApplicationHelper
include UsersHelper
include AuthenticatedTestHelper

describe UsersHelper do
  before do
    @user = mock_user
  end
  

end
