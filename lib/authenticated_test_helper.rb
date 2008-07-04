module AuthenticatedTestHelper
  # Sets the current user in the session from the user fixtures.
  def login_as(user)
    @request.session[:user_id] = user ? users(user).id : nil
  end

  def authorize_as(user)
    @request.env["HTTP_AUTHORIZATION"] = user ? ActionController::HttpAuthentication::Basic.encode_credentials(users(user).login, 'monkey') : nil
  end
  
  # rspec
  def mock_user
    user = mock_model(User, :id => 1,
      :login  => 'user_name',
      :to_xml => "User-in-XML", :to_json => "User-in-JSON", 
      :errors => [])
    user.stub!(:full_name).and_return('user_name')
    user.stub!(:first_name).and_return('user_name')
    user.stub!(:last_name).and_return('user_name')
    user
  end  
end
