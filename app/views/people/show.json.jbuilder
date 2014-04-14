json.(@person, :name, :alternative_names, :image_url, :wikipedia_page_url)
json.born born(@person)
json.died died(@person)
json.about @person.wikipedia_about_html.presence || @person.description

