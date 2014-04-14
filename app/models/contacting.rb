class Contacting < ActiveRecord::Base
  include HasToken

  normalize_attributes :name, :email, :subject, :message

  validates :name, :email, :subject, :message, :presence => true
  validates :email, :email_address_format => true, :allow_blank => true

  def deliver_mail
    require "mail"

    mail = Mail.new

    mail.reply_to = "#{name} <#{email}>"
    mail.from     = ENV["CONTACT_SENDER_EMAIL"]
    mail.to       = ENV["CONTACT_RECIPIENT_EMAIL"]
    mail.subject  = "[metter]  #{subject}"
    mail.body     = message

    mail.delivery_method :smtp, {
      :address    => ENV['SMTP_ADDRESS'],
      :port       => ENV['SMTP_PORT'],
      :user_name  => ENV['SMTP_USER'],
      :password   => ENV['SMTP_PASSWORD'],
      :authentication       => :plain,
      :enable_starttls_auto => true
    }

    mail.deliver!
  end
end

