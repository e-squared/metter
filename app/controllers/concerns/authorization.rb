module Authorization
  extend ActiveSupport::Concern

  private
    def authorize_admin
      head :unauthorized unless @current_user.admin?
    end
end
