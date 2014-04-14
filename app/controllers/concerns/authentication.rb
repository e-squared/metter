module Authentication
  extend ActiveSupport::Concern

  included do
    helper_method :current_user
  end

  private
    def authenticate
      redirect_to login_path(:return_to => request.url) unless current_user
    end

    def ensure_logged_in
      head :bad_request unless current_user
    end

    def ensure_logged_out
      head :bad_request if current_user
    end

    def current_user
      return @current_user if defined?(@current_user)

      @current_user = User.where(:login => "guest").first
    end
end
