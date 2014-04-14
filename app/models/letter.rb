# A letter is a written message containing information from one party to another.
class Letter
  include ActiveModel::Model

  attr_accessor :sender_name, :sender_address
  attr_accessor :recipient_name, :recipient_address
  attr_accessor :date_of_writing
  attr_accessor :summary
end
