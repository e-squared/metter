ThinkingSphinx::Index.define :event, :with => :active_record do
  # fields
  indexes type
  indexes date
  indexes description

  set_property :field_weights => { :description => 100, :type => 10, :date => 50 }
end
