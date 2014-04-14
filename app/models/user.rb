class User < ActiveRecord::Base
  include Trashable

  ADMIN_LOGIN = "root".freeze

  has_secure_password

  validates_presence_of :first_name, :last_name, :login
  validates_format_of :login, :with => /\A[a-z][a-z0-9]+\z/, :allow_blank => true
  validates_uniqueness_of :login, :case_sensitive => false, :allow_blank => true
  validates_length_of :first_name, :last_name, :login, :within => 2..50, :allow_blank => true
  validates_length_of :password, :within => 6..50, :allow_blank => true

  def name
    "#{first_name} #{last_name}"
  end

  def admin?
    login == ADMIN_LOGIN
  end

  def to_param
    login
  end
end

