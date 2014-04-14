ThinkingSphinx::Index.define :person, :with => :active_record do
  # fields
  indexes :name, :facet => true
  indexes description
  indexes alternative_names
  indexes date_of_birth
  indexes place_of_birth

  # attributes
  # has :id, :as => :person_id
  has rank, :as => :person_rank

  set_property :field_weights => { :name => 100, :alternative_names => 10, :description => 5 }
end
