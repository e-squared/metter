class ApplicationController < ActionController::Base
  include Security
  include Authentication
  include Authorization
  include Locale
end
