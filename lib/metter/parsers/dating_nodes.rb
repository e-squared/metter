require "date"
require File.expand_path("../../../holiday", __FILE__)

module Dating
  class DayMonthYear < Treetop::Runtime::SyntaxNode
    def eval(env = {})
      y = year.eval(env)
      m = month.eval(env)
      d = day.eval(env)

      Date.new(y, m, d)
    end
  end

  class MonthYear < Treetop::Runtime::SyntaxNode
    def eval(env = {})
      y = year.eval(env)
      m = month.eval(env)

      Date.new(y, m, 1)..Date.new(y, m, -1)
    end
  end

  class YearOnly < Treetop::Runtime::SyntaxNode
    def eval(env = {})
      y = year.eval(env)

      Date.new(y, 1, 1)..Date.new(y, 12, 31)
    end
  end

  class BeginningOfMonth < Treetop::Runtime::SyntaxNode
    def eval(env = {})
      y = year.eval(env)
      m = month.eval(env)

      Date.new(y, m, 1)..Date.new(y, m, 10)
    end
  end

  class MiddleOfMonth < Treetop::Runtime::SyntaxNode
    def eval(env = {})
      y = year.eval(env)
      m = month.eval(env)

      Date.new(y, m, 11)..Date.new(y, m, 20)
    end
  end

  class EndOfMonth < Treetop::Runtime::SyntaxNode
    def eval(env = {})
      y = year.eval(env)
      m = month.eval(env)

      Date.new(y, m, 21)..Date.new(y, m, -1)
    end
  end

  class BeginningOfYear < Treetop::Runtime::SyntaxNode
    def eval(env = {})
      y = year.eval(env)

      Date.new(y, 1, 1)..Date.new(y, 1, 10)
    end
  end

  class MiddleOfYear < Treetop::Runtime::SyntaxNode
    def eval(env = {})
      y = year.eval(env)

      Date.new(y, 6, 20)..Date.new(y, 7, 10)
    end
  end

  class EndOfYear < Treetop::Runtime::SyntaxNode
    def eval(env = {})
      y = year.eval(env)

      Date.new(y, 12, 21)..Date.new(y, 12, 31)
    end
  end

  class DayMonthYearToDayMonthYear < Treetop::Runtime::SyntaxNode
    def eval(env = {})
      start.eval(env)..stop.eval(env)
    end
  end

  class DayMonthToDayMonthYear < Treetop::Runtime::SyntaxNode
    def eval(env = {})
      date2 = stop.eval(env)
      date1 = Date.new(date2.year, start_month.eval(env), start_day.eval(env))

      date1..date2
    end
  end

  class MonthYearToMonthYear < Treetop::Runtime::SyntaxNode
    def eval(env = {})
      start.eval(env).first..stop.eval(env).last
    end
  end

  class MonthToMonthYear < Treetop::Runtime::SyntaxNode
    def eval(env = {})
      m1 = start.eval(env)
      m2 = stop.eval(env)
      y  = year.eval(env)

      Date.new(y, m1, 1)..Date.new(y, m2, -1)
    end
  end

  class DayToDayMonthYear < Treetop::Runtime::SyntaxNode
    def eval(env = {})
      d1 = start.eval(env)
      d2 = stop.eval(env)
      m  = month.eval(env)
      y  = year.eval(env)

      Date.new(y, m, d1)..Date.new(y, m, d2)
    end
  end

  class HolidayYear < Treetop::Runtime::SyntaxNode
    def eval(env = {})
      n = holiday.eval(env)
      y = year.eval(env)

      Holiday.parse "#{n} #{y}"
    end
  end

  class Year < Treetop::Runtime::SyntaxNode
    def eval(env = {})
      year = number.eval(env)

      if year < 100
        if base = env[:base] || env["base"]
          base = base.respond_to?(:acts_like_date?) || base.respond_to?(:acts_like_time?) ? base.year : base.to_i
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
  end
end
