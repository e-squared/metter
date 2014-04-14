# encoding: utf-8

module PeopleHelper
  def born(person)
    date = l(person.date_of_birth, :format => :long)
    place = person.place_of_birth

    if place
      t ".born_with_place", :date => date, :place => place
    else
      date
    end
  end

  def died(person, na = not_assigned)
    return na unless person.date_of_death

    date = l(person.date_of_death, :format => :long)
    place = person.place_of_death

    if place
      t ".died_with_place_and_age", :date => date, :place => place, :age => person.age
    else
      t ".died_with_age", :date => date, :age => person.age
    end
  end

  def living_years(person)
    result = "* #{person.date_of_birth.year}"
    result << ", † #{person.date_of_death.year}" if person.date_of_death
    result
  end

  def alternative_names(person, na = not_assigned)
    return na if person.alternative_names.empty?

    content_tag "ul", person.alternative_names.map { |name| content_tag("li", name) }.join.html_safe, :class => "alternative-names"
  end

  def wikipedia_link(person)
    if url = person.wikipedia_page_url
      link_to t(".show_wikipedia_page"), url, :target => "_blank", :class => "btn btn-small btn-external btn-wikipedia"
    end
  end
end
