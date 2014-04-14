json.value @person.name
json.name @person.name
json.descriptionTruncated truncate(@person.description, :length => 100)
json.description @person.description
json.years living_years(@person)
json.wikipediaUrl @person.wikipedia_page_url
json.gndUrl @person.gnd_page_url
json.lccnUrl @person.lccn_page_url
json.viafUrl @person.viaf_page_url
json.worldcatUrl @person.worldcat_page_url
json.born born(@person)
json.died died(@person, nil)
json.about @person.wikipedia_about_html
json.alternativeNames alternative_names(@person, nil)
json.imageUrl @person.image_url
json.birthYear @person.date_of_birth.year
json.dateOfBirth @person.date_of_birth
json.dateOfDeath @person.date_of_death
