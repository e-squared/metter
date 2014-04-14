# encoding: utf-8

require "date"

require "active_support/core_ext/string/filters"
require "active_support/core_ext/time/calculations"
require "active_support/core_ext/date/calculations"

module Holiday
  def parse(holiday_and_year, base = nil)
    tokens = holiday_and_year.squish.split(" ")

    year = normalize_year(tokens.pop, base) if tokens.last =~ /^['´`]?\d+$/

    tokens.shift if tokens.first =~ /^the$/i
    holiday = tokens.join("_").downcase.gsub(/ä/, 'ae').gsub(/ö/, 'öe').gsub(/ü/, 'üe').gsub(/ß/, 'ss').gsub(/[^a-z_]/, "").to_sym

    return nil unless respond_to?(holiday)

    if year
      send holiday, year
    else
      send holiday
    end
  end

  def names
    [
      "New Year's Day",
      "Valentine's Day",
      "Ash Wednesday",
      "Palm Sunday",
      "Holy Wednesday",
      "Maundy Thursday",
      "Good Friday",
      "Holy Saturday",
      "Easter Sunday",
      "Easter Monday",
      "Ascension Day",
      "Pentecost Sunday",
      "Whit Monday",
      "Christmas Eve",
      "Christmas Day",
      "Boxing Day",
      "New Year's Eve",
      "Mother's Day",
      "Father's Day",
      "Boss Day",
      "Independence Day",
      "Veterans Day",
      "Alaska Day",
      "Flag Day",
      "Halloween",
      "Martin Luther King Day",
      "Labor Day",
      "Columbus Day",
      "Presidents' Day",
      "Saint Patrick's Day",
      "All Saints' Day",
      "Memorial Day",
      "Thanksgiving"
    ]
  end

  def date_defined_for?(name)
    tokens = name.squish.split(" ")
    tokens.shift if tokens.first =~ /^the$/i
    holiday = tokens.join("_").downcase.gsub(/[^a-z_]/, "").to_sym

    respond_to? holiday
  end

  # See http://de.wikipedia.org/wiki/Gau%C3%9Fsche_Osterformel#Eine_erg.C3.A4nzte_Osterformel
  def easter(year)
    k = year / 100
    m = 15 + (3 * k + 3) / 4 - (8 * k + 13) / 25
    s = 2 - (3 * k + 3) / 4
    a = year % 19
    d = (19 * a + m) % 30
    r = (d + a / 11) / 29

    og = 21 + d - r
    sz = 7 - (year + year / 4 + s) % 7
    oe = 7 - (og - sz) % 7
    os = og + oe

    if os > 31
      Date.new year, 4, os - 31
    else
      Date.new year, 3, os
    end
  end

  alias :easter_sunday :easter
  alias :ostern :easter
  alias :ostersonntag :easter

  def ash_wednesday(year)
    easter(year) - 46
  end

  alias :aschermittwoch :ash_wednesday

  def palm_sunday(year)
    easter(year) - 7
  end

  alias :palmsonntag :palm_sunday

  def holy_wednesday(year)
    easter(year) - 4
  end

  alias :spy_wednesday :holy_wednesday
  alias :karmittwoch :holy_wednesday

  def maundy_thursday(year)
    easter(year) - 3
  end

  alias :holy_thursday :maundy_thursday
  alias :covenant_thursday :maundy_thursday
  alias :great_and_holy_thursday :maundy_thursday
  alias :sheer_thursday :maundy_thursday
  alias :thursday_of_mysteries :maundy_thursday
  alias :gruendonnerstag :maundy_thursday

  def good_friday(year)
    easter(year) - 2
  end

  alias :holy_friday :good_friday
  alias :great_friday :good_friday
  alias :black_friday :good_friday
  alias :easter_friday :good_friday
  alias :karfreitag :good_friday

  def holy_saturday(year)
    easter(year) - 1
  end

  alias :great_sabbath :holy_saturday
  alias :black_saturday :holy_saturday
  alias :easter_eve :holy_saturday
  alias :joyous_saturday :holy_saturday
  alias :saturday_of_light :holy_saturday
  alias :easter_saturday :holy_saturday
  alias :karsamstag :holy_saturday
  alias :karsonnabend :holy_saturday

  def easter_monday(year)
    easter(year) + 1
  end

  alias :ostermontag :easter_monday

  def ascension(year)
    easter(year) + 39
  end

  alias :feast_of_the_ascension :ascension
  alias :ascension_thursday :ascension
  alias :ascension_day :ascension
  alias :solemnity_of_the_ascension_of_the_lord :ascension
  alias :christi_himmelfahrt :ascension

  def pentecost(year)
    easter(year) + 49
  end

  alias :pentecost_sunday :pentecost
  alias :whit_sunday :pentecost
  alias :whitsun :pentecost
  alias :pfingsten :pentecost
  alias :pfingstsonntag :pentecost

  def whit_monday(year)
    pentecost(year) + 1
  end

  alias :pentecost_monday :whit_monday
  alias :monday_of_the_holy_spirit :whit_monday
  alias :pfingstmontag :whit_monday

  def silvester(year)
    Date.new year, 12, 31
  end

  alias :sylvester :silvester
  alias :sylwester :silvester
  alias :szilveszter :silvester
  alias :new_years_eve :silvester

  def new_years_day(year)
    Date.new year, 1, 1
  end

  alias :neujahr :new_years_day
  alias :neujahrstag :new_years_day

  def valentines_day(year)
    Date.new(year, 2, 14) if year >= 1300
  end

  alias :valentinstag :valentines_day

  def christmas_eve(year)
    christmas(year) - 1
  end

  alias :heilig_abend :christmas_eve

  def christmas(year)
    Date.new year, 12, 25
  end

  alias :christmas_day :christmas
  alias :weihnachten :christmas
  alias :erster_weihnachtsfeiertag :christmas

  def boxing_day(year)
    christmas(year) + 1 if year >= 1600
  end

  alias :zweiter_weihnachtsfeiertag :boxing_day

  def mothers_day(year)
    second_sunday_in(5, year) if year >= 1900
  end

  def fathers_day(year)
    third_sunday_in(6, year) if year >= 1900
  end

  def boss_day(year)
    Date.new(year, 10, 16) if year >= 1958
  end

  def independence_day(year = 1776)
    Date.new(year, 7, 4) if year >= 1776
  end

  alias :fourth_of_july :independence_day

  def veterans_day(year)
    Date.new(year, 11, 11) if year >= 1918
  end

  alias :armistice_day :veterans_day
  alias :remembrance_day :veterans_day
  alias :poppy_day :veterans_day
  alias :saint_martins_day :veterans_day
  alias :st_martins_day :veterans_day
  alias :feast_of_saint_martin :veterans_day
  alias :feast_of_st_martin :veterans_day
  alias :martinstag :veterans_day
  alias :martinmas :veterans_day

  def alaska_day(year = 1867)
    Date.new(year, 10, 18) if year >= 1867
  end

  def flag_day(year = 1777)
    Date.new(year, 6, 14) if year >= 1777
  end

  def halloween(year)
    Date.new(year, 10, 31) if year >= 1837
  end

  alias :all_hallows_eve :halloween

  def martin_luther_king_day(year)
    third_monday_in(1, year) if year >= 1986
  end

  alias :martin_luther_king_jr_day :martin_luther_king_day

  def labor_day(year)
    first_monday_in(9, year) if year >= 1894
  end

  alias :labour_day :labor_day

  def columbus_day(year)
    if year >= 1971
      second_monday_in 10, year
    elsif year >= 1792
      Date.new year, 10, 12
    end
  end

  def presidents_day(year)
    if year >= 1971
      third_monday_in 2, year
    elsif year >= 1879
      Date.new year, 2, 22
    end
  end

  alias :washingtons_birthday :presidents_day

  def saint_patricks_day(year)
    Date.new(year, 3, 17) if year >= 1600
  end

  alias :feast_of_saint_patrick :saint_patricks_day
  alias :feast_of_st_patrick :saint_patricks_day
  alias :patricks_day :saint_patricks_day
  alias :saint_paddys_day :saint_patricks_day
  alias :paddys_day :saint_patricks_day
  alias :st_pattys_day :saint_patricks_day
  alias :st_patricks_day :saint_patricks_day

  def all_saints_day(year)
    Date.new(year, 11, 1) if year >= 609
  end

  alias :all_hallows :all_saints_day
  alias :solemnity_of_all_saints :all_saints_day
  alias :feast_of_all_saints :all_saints_day

  def memorial_day(year)
    last_monday_in(5, year) if year >= 1869
  end

  alias :decoration_day :memorial_day

  def thanksgiving(year)
    if year >= 1941
      fourth_thursday_in 11, year
    elsif year >= 1939
      penultimate_thursday_in 11, year
    elsif year >= 1863
      last_thursday_in 11, year
    end
  end

  alias :thanksgiving_day :thanksgiving

  private
    def first_sunday_in(month, year)
      first_week = Date.new(year, month, 1)
      first_week + days_til_sunday(first_week)
    end

    def second_sunday_in(month, year)
      second_week = Date.new(year, month, 8)
      second_week + days_til_sunday(second_week)
    end

    def third_sunday_in(month, year)
      third_week = Date.new(year, month, 15)
      third_week + days_til_sunday(third_week)
    end

    def first_monday_in(month, year)
      first_week = Date.new(year, month, 1)
      first_week + days_til_monday(first_week)
    end

    def second_monday_in(month, year)
      second_week = Date.new(year, month, 8)
      second_week + days_til_monday(second_week)
    end

    def third_monday_in(month, year)
      third_week = Date.new(year, month, 15)
      third_week + days_til_monday(third_week)
    end

    def last_monday_in(month, year)
      day = Date.new(year, month, 1).end_of_month

      while day.wday != 1
        day -= 1
      end

      day
    end

    def fourth_thursday_in(month, year)
      day = Date.new(year, month, 22)

      while day.wday != 4
        day += 1
      end

      day
    end

    def penultimate_thursday_in(month, year)
      day = Date.new(year, month, 1).end_of_month - 7

      while day.wday != 4
        day -= 1
      end

      day
    end

    def last_thursday_in(month, year)
      day = Date.new(year, month, 1).end_of_month

      while day.wday != 4
        day -= 1
      end

      day
    end

    def days_til_sunday(date)
      (7 - date.wday) % 7
    end

    def days_til_monday(date)
      dts = days_til_sunday(date)
      dts == 6 ? 0 : dts + 1
    end

    def normalize_year(year, base)
      year = year.gsub(/^['´`]/, "").to_i

      if year < 100
        if base
          base = base.year if base.respond_to?(:acts_like_date?) || base.respond_to?(:acts_like_time?)
          century = base - base % 100
          year = century + year

          if year < base
            year += 100
          end
        else
          if year + 2000 > Date.today.year
            year += 1900
          else
            year += 2000
          end
        end
      end

      year
    end

  extend self
end
