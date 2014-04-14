module HasToken
  extend ActiveSupport::Concern

  included do
    before_create :assign_token
  end

  def to_param
    token
  end

  private
    def assign_token
      self.token = generate_token
    end

    # Generate a token by looping and ensuring it does not already exist.
    def generate_token
      loop do
        token = SecureRandom.base64(44).tr("+/=", "xyz").first(16).upcase
        break token unless self.class.where(:token => token).first
      end
    end
end

