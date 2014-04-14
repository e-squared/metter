require "metter/ext"
require "metter/parsers/dating"

module Metter
  LOCALES = %w(en de).freeze

  class << self
    def locales
      LOCALES
    end
  end
end
