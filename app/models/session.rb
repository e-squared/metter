class Session
  include ActiveModel::Model

  attr_accessor :login, :password

  validates_presence_of :login, :password
  validate :correct_credentials

  def user
    @user ||= User.where(:login => login).first
  end

  private
    def correct_credentials
      return unless login.present? && password.present?

      unless user && user.authenticate(password)
        errors.add :base, :invalid
      end
    end
end

