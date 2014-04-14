class String
  def upcase_first_char
    slice(0).upcase + slice(1..-1)
  end

  def strip_tags
    ActionController::Base.helpers.strip_tags self
  end
end
