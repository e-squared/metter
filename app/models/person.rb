class Person < ActiveRecord::Base
  include HasToken

  normalize_attributes :name, :description, :place_of_birth, :place_of_death, :wikipedia_identifier, :gnd_identifier, :viaf_identifier, :lccn_identifier, :wikipedia_image_url, :wikipedia_about_html

  attr_accessor :unformatted_date_of_birth, :unformatted_date_of_death

  before_validation :parse_date_of_birth, :parse_date_of_death

  validates_presence_of :name, :description, :date_of_birth, :rank
  validates_length_of :name, :place_of_birth, :place_of_death, :maximum => 250, :allow_blank => true
  validates_uniqueness_of :wikipedia_identifier, :allow_blank => true
  validates_numericality_of :rank, :only_integer => true, :allow_blank => true
  validate :ensure_date_of_birth_is_recognized
  validate :ensure_date_of_death_is_recognized
  validate :ensure_date_of_death_not_before_date_of_birth
  validate :ensure_person_living_years_not_more_than_125

  before_save :sanitize_alternative_names

  def age
    return unless date_of_birth.respond_to?(:year)

    ref_date = date_of_death || Date.today
    ref_date.year - date_of_birth.year - ((ref_date.month > date_of_birth.month || (ref_date.month == date_of_birth.month && ref_date.day >= date_of_birth.day)) ? 0 : 1)
  end

  def dead?
    date_of_death.present?
  end

  def image_url
    wikipedia_image_url
  end

  def wikipedia_page_url
    return unless wikipedia_identifier

    ENV["WIKIPEDIA_PAGE_URL_TEMPLATE"] % wikipedia_identifier
  end

  def gnd_page_url
    return unless gnd_identifier

    ENV["GND_PAGE_URL_TEMPLATE"] % gnd_identifier
  end

  def viaf_page_url
    return unless viaf_identifier

    ENV["VIAF_PAGE_URL_TEMPLATE"] % viaf_identifier
  end

  def lccn_page_url
    return unless lccn_identifier

    a, b, c = lccn_identifier.split("/")
    c = c.rjust(6, "0") rescue c

    ENV["LCCN_PAGE_URL_TEMPLATE"] % [a, b, c].join
  end

  def worldcat_page_url
    return unless lccn_identifier

    ENV["WORLDCAT_PAGE_URL_TEMPLATE"] % lccn_identifier.gsub("/", "-")
  end

  def wikipedia_api_url(options = {})
    return unless wikipedia_identifier

    options.reverse_merge! :action => "parse", :format => "json", :prop => "text"
    options[:prop] = Array(options[:prop]).join("|")
    options[:pageid] = wikipedia_identifier

    ENV["WIKIPEDIA_API_URL_TEMPLATE"] % options.to_param
  end

  def parse_wikipedia_data
    result = {}
    html   = Http.get(wikipedia_api_url)["parse"]["text"]["*"] rescue nil

    if html
      result[:html]       = html
      result[:image_url]  = (html =~ /\s+class="image"><img\s+.*?src="([^"]+)"/ && $1)
      result[:about_html] = (html =~ /(<\/table>|<\/div>|<\/dl>|\A)\s*<p>(.*?)<\/p>/ && $2.gsub(/<small[^>]*>.*?<\/small>/, "").gsub(/<sup[^>]*>.*?<\/sup>/, "").gsub(/<span\s.*?class="IPA"><a\s.*?<\/a><\/span>/, "").gsub(/<a\s[^>]+>(.*?)<\/a>/, '\1').gsub(/<span style="display:none">\(.*?\)<\/span>/, "").gsub(/\([^\)]+\)/, "").gsub(/\([^\)]+\)/, "").gsub(/<span[^>]*>.*?<\/span>/, "").gsub(/<\/span>|<br\s*\/?>/, "").squish.gsub(/\s+,/, ",").presence)
    end

    result
  end

  private
    def ensure_date_of_death_not_before_date_of_birth
      if date_of_death && date_of_birth && date_of_death < date_of_birth
        errors.add :date_of_death, :invalid
      end
    end

    def ensure_person_living_years_not_more_than_125
      if age && age > 125
        errors.add :date_of_death, :invalid
      end
    end

    def ensure_date_of_birth_is_recognized
      if date_of_birth == :unrecognized
        errors.add :date_of_birth, :unrecognized
      end
    end

    def ensure_date_of_death_is_recognized
      if date_of_death == :unrecognized
        errors.add :date_of_death, :unrecognized
      end
    end

    def sanitize_alternative_names
      self.alternative_names = alternative_names.map(&:presence).compact.uniq
    end

    def parse_date_of_birth
      if unformatted_date_of_birth.present?
        self.date_of_birth = 
          if dating = Dating.parse(unformatted_date_of_birth)
            dating.dates.first
          else
            :unrecognized
          end
      end
    end

    def parse_date_of_death
      if unformatted_date_of_death.present?
        self.date_of_death = 
          if dating = Dating.parse(unformatted_date_of_death)
            dating.dates.first
          else
            :unrecognized
          end
      end
    end
end

