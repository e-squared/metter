# encoding: utf-8

require "csv"

namespace :db do
  namespace :import do
    desc "Import people data into database"
    task :people => :environment do
      file_path = Rails.root.join("db", "import", "people.tab").to_s
      errors = []
      i = 0

      CSV.foreach file_path, :col_sep => "\t", :quote_char => "\t" do |input|
        i += 1

        begin
          person = Person.create! do |person|
            person.name                 = input[1].squish.sub(/\s*\([^\)]+\)\s*$/, "")
            person.description          = input[2].squish.upcase_first_char
            person.date_of_birth        = input[3].squish
            person.place_of_birth       = input[4].presence && input[4].squish.upcase_first_char
            person.date_of_death        = input[5].presence && input[5].squish
            person.place_of_death       = input[6].presence && input[6].squish.upcase_first_char
            person.alternative_names    = input[7].to_s.split(";").map(&:squish)
            person.wikipedia_identifier = input[0].squish
          end

          puts "#{i} -- #{person.name}"
        rescue ActiveRecord::RecordInvalid => exc
          errors << "#{input[0]} -- #{exc.message}"
          puts errors.last
        end
      end

      puts
      puts errors.join("\n")
    end

    desc "Import authority control data into database"
    task :authority => :environment do
      file_path = Rails.root.join("db", "import", "authority.tab").to_s

      IO.readlines(file_path).each_with_index do |line, i|
        next if line.blank? || line =~ /^\s*\d+\s*$/

        puts i.to_s

        wikipedia_identifier, rest = line.split("|", 2)

        person = Person.where(:wikipedia_identifier => wikipedia_identifier).first

        next unless person

        authorities = rest.split("|").map { |s| s.split("=", 2) }

        authorities.each do |(a, n)|
          puts "--> #{a}: #{n}"

          method = "#{a.downcase}_identifier="

          if person.respond_to?(method)
            person.send method, n if n.present?
          end
        end

        person.save :validate => false
      end
    end

    desc "Parse Wikipedia pages for image and longer description"
    task :parse_wikipedia => :environment do
      errors = []

      Person.where(:wikipedia_about_html => nil).find_each do |person|
        next unless person.wikipedia_identifier

        puts "Parsing person ##{person.id} (#{person.wikipedia_identifier}) ..."

        begin
          data  = person.parse_wikipedia_data
          image = data[:image_url]
          about = data[:about_html]

          person.wikipedia_image_url = image

          if about.blank?
            puts " --> no about html found"
            errors << "Person ##{person.id} (#{person.wikipedia_identifier}) -- no about html found"
          else
            clone = about.gsub(/<b>|<\/b>|<i>|<\/i>/, "")

            if clone =~ /<|>/
              puts " --> about html has unrecognized html tags: #{clone}"
              errors << "Person ##{person.id} (#{person.wikipedia_identifier}) -- about html has unrecognized tags: #{clone}"
            elsif about !~ /\A(\s*[A-Za-z-]+){0,4}\s*<b>/
              puts " --> about html does not start with a bold tag: #{about}"
              errors << "Person ##{person.id} (#{person.wikipedia_identifier}) -- about html does not start with a bold tag"
            else
              person.wikipedia_about_html = about

              new_alternative_names = about.scan(/<b>"?(.*?)"?<\/b>/).flatten.map { |name| name.gsub(/<\/?i>|&#160;/, " ").squish }.map(&:presence).compact.uniq - [person.name, *person.alternative_names]

              if new_alternative_names.any?
                puts " --> new alternative names found: #{new_alternative_names.inspect}"
                #errors << "Person ##{person.id} (#{person.wikipedia_identifier}) -- new alternative names found: #{new_alternative_names.inspect}"

                person.alternative_names += new_alternative_names
              end
            end
          end

          person.save!
        rescue => exc
          puts " --> ERROR: #{exc.message} (#{exc.class})"
          errors << "Person ##{person.id} (#{person.wikipedia_identifier}) -- ERROR: #{exc.message} (#{exc.class})"
        end
      end

      puts
      puts errors.join("\n")
    end

    namespace :events do
      task :clean do
        Event.delete_all
      end

      desc "Import history, holidays, births and deaths into the events table"
      task :all => [:environment, :clean, :history, :holidays, :births_and_deaths] do
      end

      desc "Parse Wikipedia pages for historic events and add them to the database"
      task :history => :environment do
        days_in_months = {
          "January"   => [1..31, 1],
          "February"  => [1..29, 2],
          "March"     => [1..31, 3],
          "April"     => [1..30, 4],
          "May"       => [1..31, 5],
          "June"      => [1..30, 6],
          "July"      => [1..31, 7],
          "August"    => [1..31, 8],
          "September" => [1..30, 9],
          "October"   => [1..31, 10],
          "November"  => [1..30, 11],
          "December"  => [1..31, 12]
        }

        infos    = []
        warnings = []
        errors   = []

        days_in_months.each do |month_name, (days, month)|
          days.each do |day|
            month_name_and_day = "#{month_name}_#{day}"
            wikipedia_url = "http://en.wikipedia.org/wiki/#{month_name_and_day}"

            puts "Parsing #{month_name} #{day} (#{wikipedia_url})..."

            html = Http.get(wikipedia_url)
            doc  = Nokogiri::HTML::Document.parse(html)
            head = doc.xpath("//h2[span[text()='Events']]")[0]

            unless head
              puts " --> ERROR: no events headline found"
              errors << "#{wikipedia_url} -- no events headline found"
              next
            end

            list = head.next_element
            list = list.next_element if list.name == "div"

            if list.name != "ul"
              puts " --> ERROR: no events list found"
              errors << "#{wikipedia_url} -- no events list found"
              next
            end

            items = list.xpath("li")

            if items.empty?
              puts " --> ERROR: no event items found"
              errors << "#{wikipedia_url} -- no event items found"
              next
            end

            items.each do |item|
              year, description = item.content.split(/–/, 2).map(&:squish)

              unless description
                puts " --> ERROR: no event description found for \"#{year}\""
                errors << "#{wikipedia_url} -- no event description found for \"#{year}\""
                next
              end

              if year !~ /^\d\d\d\d?$/
                puts " --> INFO: discarding item \"#{item.content}\""
                infos << "#{wikipedia_url} -- discarding item \"#{item.content}\""
                next
              end

              date =
                begin
                  Date.new year.to_i, month, day
                rescue => exc
                  puts " --> ERROR: #{exc.message} (#{exc.class}) for item \"#{description}\" (#{year}, #{month}, #{day})"
                  warnings << "#{wikipedia_url} -- #{exc.message} (#{exc.class}) for item \"#{description}\" (#{year}, #{month}, #{day})"
                  next
                end

              # puts " * #{date} -- #{description.truncate(200)}"
              HistoryEvent.create! :date => date, :description => description.upcase_first_char
            end
          end
        end

        puts
        puts "INFOS:"
        puts infos.join("\n")

        puts
        puts "WARNINGS:"
        puts warnings.join("\n")

        puts
        puts "ERRORS:"
        puts errors.join("\n")
      end

      desc "Import births and deaths from people's data as events"
      task :births_and_deaths => :environment do
        Person.where("rank > 0").find_each do |person|
          puts "Importing birth (and death) events of person with ID #{person.id}"

          BirthEvent.create! :date => person.date_of_birth, :description => "#{person.name}, #{person.description}, is born."

          if person.dead?
            DeathEvent.create! :date => person.date_of_death, :description => "#{person.name}, #{person.description}, dies at age #{person.age}."
          end
        end
      end

      desc "Import holidays as events"
      task :holidays => :environment do
        (500..2013).each do |year|
          puts "Importing holidays for year #{year}"

          Holiday.names.each do |name|
            if date = Dating.parse("#{name} #{year}").try(:first)
              #puts "#{date} -- #{name}"
              HolidayEvent.create!(:date => date, :description => name) rescue nil
            end
          end
        end
      end
    end
  end
end

