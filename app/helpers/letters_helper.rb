module LettersHelper
  def format_dates(dates)
    dates.map do |date|
      if date.is_a?(Range)
        localize(date.first) + " ... " + localize(date.last)
      else
        localize(date)
      end
    end.join("<br>").html_safe
  end

  def parse_and_layout_queries(queries, env)
    first_query = queries.shift
    result      = [{ :parsed => Dating.parse(first_query, env), :queries => [first_query] }]

    queries.each do |query|
      parsed = Dating.parse(query, env)

      if parsed == result.last[:parsed] && result.last[:queries].size < 4
        result.last[:queries] << query
      else
        result << { :parsed => parsed, :queries => [query] }
      end
    end

    result
  end
end
