module Trashable
  extend ActiveSupport::Concern

  included do
    default_scope -> { where(:trashed => false) }
    scope :trashed, -> { where(:trashed => true) }
  end

  def trash
    update_attribute :trashed, true
  end
end

