class Event < ActiveRecord::Base
  include HasToken

  normalize_attributes :description

  validates_presence_of :date, :description

  def self.inherited(base)
    base.instance_eval do
      def model_name
        Event.model_name
      end
    end

    super
  end

  def self.types
    [HistoryEvent, HolidayEvent, BirthEvent, DeathEvent]
  end

  def display
    "#{I18n.localize(date, :format => :long)}: #{description}"
  end
end

