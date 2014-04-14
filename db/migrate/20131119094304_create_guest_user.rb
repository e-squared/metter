class CreateGuestUser < ActiveRecord::Migration
  def up
    User.create! :login => "guest", :password => "secret", :password_confirmation => "secret", :first_name => "Guest", :last_name => "User", :locale => "en"
  end
end
