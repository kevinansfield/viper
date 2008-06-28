require File.dirname(__FILE__) + '/../spec_helper'
  
# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead
# Then, you can remove it from this and the units test.
include AuthenticatedTestHelper

describe PeopleController do
  fixtures :users

  it 'allows signup' do
    lambda do
      create_user
      response.should be_redirect
    end.should change(User, :count).by(1)
  end

  
  it 'signs up user in pending state' do
    create_user
    assigns(:user).reload
    assigns(:user).should be_pending
  end

  it 'signs up user with activation code' do
    create_user
    assigns(:user).reload
    assigns(:user).activation_code.should_not be_nil
  end
  it 'requires login on signup' do
    lambda do
      create_user(:login => nil)
      assigns[:user].errors.on(:login).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  it 'requires password on signup' do
    lambda do
      create_user(:password => nil)
      assigns[:user].errors.on(:password).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  it 'requires password confirmation on signup' do
    lambda do
      create_user(:password_confirmation => nil)
      assigns[:user].errors.on(:password_confirmation).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end

  it 'requires email on signup' do
    lambda do
      create_user(:email => nil)
      assigns[:user].errors.on(:email).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  
  it 'activates user' do
    User.authenticate('aaron', 'monkey').should be_nil
    get :activate, :activation_code => users(:aaron).activation_code
    response.should redirect_to('/login')
    flash[:notice].should_not be_nil
    flash[:error ].should     be_nil
    User.authenticate('aaron', 'monkey').should == users(:aaron)
  end
  
  it 'does not activate user without key' do
    get :activate
    flash[:notice].should     be_nil
    flash[:error ].should_not be_nil
  end
  
  it 'does not activate user with blank key' do
    get :activate, :activation_code => ''
    flash[:notice].should     be_nil
    flash[:error ].should_not be_nil
  end
  
  it 'does not activate user with bogus key' do
    get :activate, :activation_code => 'i_haxxor_joo'
    flash[:notice].should     be_nil
    flash[:error ].should_not be_nil
  end
  
  def create_user(options = {})
    post :create, :user => { :login => 'quire', :email => 'quire@example.com',
      :password => 'quire69', :password_confirmation => 'quire69' }.merge(options)
  end
end

describe PeopleController do
  describe "route generation" do
    it "should route userss's 'index' action correctly" do
      route_for(:controller => 'userss', :action => 'index').should == "/users"
    end
    
    it "should route userss's 'new' action correctly" do
      route_for(:controller => 'userss', :action => 'new').should == "/signup"
    end
    
    it "should route {:controller => 'userss', :action => 'create'} correctly" do
      route_for(:controller => 'userss', :action => 'create').should == "/register"
    end
    
    it "should route userss's 'show' action correctly" do
      route_for(:controller => 'userss', :action => 'show', :id => '1').should == "/users/1"
    end
    
    it "should route userss's 'edit' action correctly" do
      route_for(:controller => 'userss', :action => 'edit', :id => '1').should == "/users/1/edit"
    end
    
    it "should route userss's 'update' action correctly" do
      route_for(:controller => 'userss', :action => 'update', :id => '1').should == "/users/1"
    end
    
    it "should route userss's 'destroy' action correctly" do
      route_for(:controller => 'userss', :action => 'destroy', :id => '1').should == "/users/1"
    end
  end
  
  describe "route recognition" do
    it "should generate params for userss's index action from GET /users" do
      params_from(:get, '/users').should == {:controller => 'userss', :action => 'index'}
      params_from(:get, '/users.xml').should == {:controller => 'userss', :action => 'index', :format => 'xml'}
      params_from(:get, '/users.json').should == {:controller => 'userss', :action => 'index', :format => 'json'}
    end
    
    it "should generate params for userss's new action from GET /users" do
      params_from(:get, '/users/new').should == {:controller => 'userss', :action => 'new'}
      params_from(:get, '/users/new.xml').should == {:controller => 'userss', :action => 'new', :format => 'xml'}
      params_from(:get, '/users/new.json').should == {:controller => 'userss', :action => 'new', :format => 'json'}
    end
    
    it "should generate params for userss's create action from POST /users" do
      params_from(:post, '/users').should == {:controller => 'userss', :action => 'create'}
      params_from(:post, '/users.xml').should == {:controller => 'userss', :action => 'create', :format => 'xml'}
      params_from(:post, '/users.json').should == {:controller => 'userss', :action => 'create', :format => 'json'}
    end
    
    it "should generate params for userss's show action from GET /users/1" do
      params_from(:get , '/users/1').should == {:controller => 'userss', :action => 'show', :id => '1'}
      params_from(:get , '/users/1.xml').should == {:controller => 'userss', :action => 'show', :id => '1', :format => 'xml'}
      params_from(:get , '/users/1.json').should == {:controller => 'userss', :action => 'show', :id => '1', :format => 'json'}
    end
    
    it "should generate params for userss's edit action from GET /users/1/edit" do
      params_from(:get , '/users/1/edit').should == {:controller => 'userss', :action => 'edit', :id => '1'}
    end
    
    it "should generate params {:controller => 'userss', :action => update', :id => '1'} from PUT /users/1" do
      params_from(:put , '/users/1').should == {:controller => 'userss', :action => 'update', :id => '1'}
      params_from(:put , '/users/1.xml').should == {:controller => 'userss', :action => 'update', :id => '1', :format => 'xml'}
      params_from(:put , '/users/1.json').should == {:controller => 'userss', :action => 'update', :id => '1', :format => 'json'}
    end
    
    it "should generate params for userss's destroy action from DELETE /users/1" do
      params_from(:delete, '/users/1').should == {:controller => 'userss', :action => 'destroy', :id => '1'}
      params_from(:delete, '/users/1.xml').should == {:controller => 'userss', :action => 'destroy', :id => '1', :format => 'xml'}
      params_from(:delete, '/users/1.json').should == {:controller => 'userss', :action => 'destroy', :id => '1', :format => 'json'}
    end
  end
  
  describe "named routing" do
    before(:each) do
      get :new
    end
    
    it "should route users_path() to /users" do
      users_path().should == "/users"
      formatted_users_path(:format => 'xml').should == "/users.xml"
      formatted_users_path(:format => 'json').should == "/users.json"
    end
    
    it "should route new_user_path() to /users/new" do
      new_user_path().should == "/users/new"
      formatted_new_user_path(:format => 'xml').should == "/users/new.xml"
      formatted_new_user_path(:format => 'json').should == "/users/new.json"
    end
    
    it "should route user_(:id => '1') to /users/1" do
      user_path(:id => '1').should == "/users/1"
      formatted_user_path(:id => '1', :format => 'xml').should == "/users/1.xml"
      formatted_user_path(:id => '1', :format => 'json').should == "/users/1.json"
    end
    
    it "should route edit_user_path(:id => '1') to /users/1/edit" do
      edit_user_path(:id => '1').should == "/users/1/edit"
    end
  end
  
end
