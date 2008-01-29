class Admin::AbstractAdminController < ApplicationController
  before_filter :admin_required
  
  layout "admin"
  
  def reset_partials
    self.sidebar_one = nil
    self.sidebar_two = '/layouts/admin_sidebar_two'
    self.maincol_one = nil
    self.maincol_two = nil
  end
end