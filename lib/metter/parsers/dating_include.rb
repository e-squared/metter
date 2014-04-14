require "active_support/core_ext/string/filters"

module Dating
  module Include
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def parse(text, env = {})
        @@parser ||= DatingParser.new

        downcased_text = text.downcase

        if result = @@parser.parse(downcased_text)
          downcased_text.replace text
          result.eval env
        else
          nil
        end
      end
    end
  end

  class ParseResult
    attr_reader :dates, :certainty, :comment, :sorting_date

    def initialize(dates, certainty = 100, comment = nil)
      @dates        = dates
      @certainty    = certainty
      @comment      = comment
      @sorting_date = dates.map { |date| date.is_a?(Range) ? [date.first, date.last] : date }.flatten.sort.first
    end
  end
end
