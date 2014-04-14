module ActiveRecord
  class Base
    def display
      return title if respond_to?(:title)
      return name  if respond_to?(:name)

      to_s
    end
  end
end
