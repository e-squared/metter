json.array! @events do |event|
  json.value event.date
  json.date l(event.date, :format => :full)
  json.truncated_description truncate(event.description, :length => 200)
  json.description event.description
  json.type tt(event)
  json.cssClass event.type.underscore.dasherize
  json.token event.token
end

