require File.expand_path("../test_helper", __FILE__)
require File.expand_path("../dating_nodes", __FILE__)

Treetop.load File.expand_path("../dating", __FILE__)

class DatingParserTest < MiniTest::Unit::TestCase
  include ParserTestHelper

  def setup
    @parser = DatingParser.new
  end

  def test_unparsable_query_returns_empty_array
    assert_equal nil, Dating.parse("this does not make any sense at all")
  end

  def test_day_month_year
    date = [Date.new(2013, 7, 4)]

    assert_equal date, parse("   4 July 2013    ")

    assert_equal date, parse("4 July 2013")
    assert_equal date, parse("4/Jul/2013")
    assert_equal date, parse("Thursday, July 4, 2013")
    assert_equal date, parse("July 4th, 2013")
    assert_equal date, parse("04 July 2013")
    assert_equal date, parse("Thu July 04, 2013")
    assert_equal date, parse("July 04th, 2013")

    assert_equal date, parse("[Thursday], July 4, 2013")
    assert_equal date, parse("Thursday, [July] 4, 2013")
    assert_equal date, parse("Thursday, July [4], 2013")
    assert_equal date, parse("Thursday, July 4, [2013]")
    assert_equal date, parse("[Thursday], [July] [4], [2013]")

    assert_equal date, parse("4 Jul 2013")
    assert_equal date, parse("Thu, Jul 4, 2013")
    assert_equal date, parse("Jul 4th, 2013")
    assert_equal date, parse("Thursday 04 Jul 2013")
    assert_equal date, parse("Jul 04, 2013")
    assert_equal date, parse("Jul 04th, 2013")

    assert_equal date, parse("4 Julasdf 2013")

    assert_equal date, parse("2013-7-4")
    assert_equal date, parse("2013-7-04")
    assert_equal date, parse("2013-07-4")
    assert_equal date, parse("2013-07-04")

    assert_equal date, parse("[2013]-07-04")
    assert_equal date, parse("2013-[07]-04")
    assert_equal date, parse("2013-07-[04]")
    assert_equal date, parse("[2013]-[07]-[04]")

    assert_equal date, parse("7/4/2013")
    assert_equal date, parse("7/04/2013")
    assert_equal date, parse("07/4/2013")
    assert_equal date, parse("07/04/2013")

    assert_equal date, parse("[07]/04/2013")
    assert_equal date, parse("07/[04]/2013")
    assert_equal date, parse("07/04/[2013]")
    assert_equal date, parse("[07]/[04]/[2013]")

    assert_equal date, parse("4. July 2013")
    assert_equal date, parse("4. of July 2013")
    assert_equal date, parse("Thu 4. of July 2013")
    assert_equal date, parse("the 4th of July 2013")
    assert_equal date, parse("Thursday the 4th of July 2013")
    assert_equal date, parse("July the 4th, 2013")
    assert_equal date, parse("Thursday, July the 4th, 2013")

    assert_equal date, parse("Thursday, the Fourth of July 2013")
    assert_equal date, parse("[Thursday], the Fourth of July 2013")
    assert_equal date, parse("Thursday, the [Fourth] of July 2013")
    assert_equal date, parse("Thursday, the Fourth of [July] 2013")
    assert_equal date, parse("Thursday, the Fourth of July [2013]")
    assert_equal date, parse("[Thursday], the [Fourth] of [July] [2013]")

    assert_equal date, parse("4 July 13")
    assert_equal date, parse("Thursday 4 July 13")

    assert_equal date, parse("July 4. 2013")

    assert_equal [Date.new(2004, 7, 4)], parse("4 July 04")
  end

  def test_month_year
    month_in_year = [Date.new(1995, 3, 1)..Date.new(1995, 3, 31)]

    assert_equal month_in_year, parse("Mar 1995")
    assert_equal month_in_year, parse("March 1995")

    assert_equal month_in_year, parse("?? Mar 1995")
    assert_equal month_in_year, parse("[??] Mar 1995")
    assert_equal month_in_year, parse("(??) Mar 1995")
    assert_equal month_in_year, parse("? March 1995")
    assert_equal month_in_year, parse("[?] March 1995")
    assert_equal month_in_year, parse("(?) March 1995")
    assert_equal month_in_year, parse("Mar ??, 1995")
    assert_equal month_in_year, parse("Mar [??], 1995")
    assert_equal month_in_year, parse("Mar (??), 1995")
    assert_equal month_in_year, parse("March ?, 1995")
    assert_equal month_in_year, parse("March [?], 1995")
    assert_equal month_in_year, parse("March (?), 1995")

    assert_equal month_in_year, parse("??st Mar 1995")
    assert_equal month_in_year, parse("[??]nd Mar 1995")
    assert_equal month_in_year, parse("(??)rd Mar 1995")
    assert_equal month_in_year, parse("?th March 1995")
    assert_equal month_in_year, parse("[?]. March 1995")
    assert_equal month_in_year, parse("(?) of March 1995")
    assert_equal month_in_year, parse("Mar the ??, 1995")
    assert_equal month_in_year, parse("Mar [??]st, 1995")
    assert_equal month_in_year, parse("Mar the (??)nd, 1995")
    assert_equal month_in_year, parse("March ?rd, 1995")
    assert_equal month_in_year, parse("March [?]th, 1995")
    assert_equal month_in_year, parse("March the (?)., 1995")

    assert_equal month_in_year, parse("3/1995")
    assert_equal month_in_year, parse("03/1995")

    assert_equal month_in_year, parse("3/?/1995")
    assert_equal month_in_year, parse("3/[?]/1995")
    assert_equal month_in_year, parse("3/(?)/1995")

    assert_equal month_in_year, parse("03/?/1995")
    assert_equal month_in_year, parse("03/[?]/1995")
    assert_equal month_in_year, parse("03/(?)/1995")

    assert_equal month_in_year, parse("3/??/1995")
    assert_equal month_in_year, parse("3/[??]/1995")
    assert_equal month_in_year, parse("3/(??)/1995")

    assert_equal month_in_year, parse("03/??/1995")
    assert_equal month_in_year, parse("03/[??]/1995")
    assert_equal month_in_year, parse("03/(??)/1995")

    assert_equal month_in_year, parse("1995-3-?")
    assert_equal month_in_year, parse("1995-3-[?]")
    assert_equal month_in_year, parse("1995-3-(?)")

    assert_equal month_in_year, parse("1995-03-?")
    assert_equal month_in_year, parse("1995-03-[?]")
    assert_equal month_in_year, parse("1995-03-(?)")

    assert_equal month_in_year, parse("1995-3-??")
    assert_equal month_in_year, parse("1995-3-[??]")
    assert_equal month_in_year, parse("1995-3-(??)")

    assert_equal month_in_year, parse("1995-03-??")
    assert_equal month_in_year, parse("1995-03-[??]")
    assert_equal month_in_year, parse("1995-03-(??)")
  end

  def test_year
    year = [Date.new(1945, 1, 1)..Date.new(1945, 12, 31)]

    assert_equal year, parse("1945")

    assert_equal year, parse("1945-?-?")
    assert_equal year, parse("1945-[?]-[?]")
    assert_equal year, parse("1945-(?)-(?)")

    assert_equal year, parse("1945-??-??")
    assert_equal year, parse("1945-[??]-[??]")
    assert_equal year, parse("1945-(??)-(??)")

    assert_equal year, parse("?/?/1945")
    assert_equal year, parse("[?]/[?]/1945")
    assert_equal year, parse("(?)/(?)/1945")

    assert_equal year, parse("??/??/1945")
    assert_equal year, parse("[??]/[??]/1945")
    assert_equal year, parse("(??)/(??)/1945")

    assert_equal year, parse("? ? 1945")
    assert_equal year, parse("[?] [?] 1945")
    assert_equal year, parse("(?) (?) 1945")

    assert_equal year, parse("?? ?? 1945")
    assert_equal year, parse("[??] [??] 1945")
    assert_equal year, parse("(??) (??) 1945")

    assert_equal year, parse("? ?, 1945")
    assert_equal year, parse("[?] [?], 1945")
    assert_equal year, parse("(?) (?), 1945")

    assert_equal year, parse("?? ??, 1945")
    assert_equal year, parse("[??] [??], 1945")
    assert_equal year, parse("(??) (??), 1945")
  end

  def test_beginning_of_month
    period = [Date.new(1850, 2, 1)..Date.new(1850, 2, 10)]

    assert_equal period, parse("Beginning of February 1850")
    assert_equal period, parse("Beginning of February, 1850")

    assert_equal period, parse("the Beginning of February 1850")
    assert_equal period, parse("the Beginning of February, 1850")

    assert_equal period, parse("Beginning of Feb 1850")
    assert_equal period, parse("Beginning of Feb, 1850")

    assert_equal period, parse("the Beginning of Feb 1850")
    assert_equal period, parse("the Beginning of Feb, 1850")

    assert_equal period, parse("Early February 1850")
    assert_equal period, parse("early February, 1850")

    assert_equal period, parse("Early Feb 1850")
    assert_equal period, parse("early Feb, 1850")
  end

  def test_middle_of_month
    period = [Date.new(1850, 2, 11)..Date.new(1850, 2, 20)]

    assert_equal period, parse("Middle of February 1850")
    assert_equal period, parse("Middle of February, 1850")

    assert_equal period, parse("the Middle of February 1850")
    assert_equal period, parse("the Middle of February, 1850")

    assert_equal period, parse("Middle of Feb 1850")
    assert_equal period, parse("Middle of Feb, 1850")

    assert_equal period, parse("the Middle of Feb 1850")
    assert_equal period, parse("the Middle of Feb, 1850")

    assert_equal period, parse("mid-February 1850")
    assert_equal period, parse("Mid- February 1850")
    assert_equal period, parse("mid February 1850")

    assert_equal period, parse("Mid-February, 1850")
    assert_equal period, parse("mid- February, 1850")
    assert_equal period, parse("Mid February, 1850")

    assert_equal period, parse("mid-Feb 1850")
    assert_equal period, parse("Mid- Feb 1850")
    assert_equal period, parse("mid Feb 1850")

    assert_equal period, parse("Mid-Feb, 1850")
    assert_equal period, parse("mid- Feb, 1850")
    assert_equal period, parse("Mid Feb, 1850")
  end

  def test_end_of_month
    period = [Date.new(1850, 2, 21)..Date.new(1850, 2, -1)]

    assert_equal period, parse("End of February 1850")
    assert_equal period, parse("End of February, 1850")

    assert_equal period, parse("the End of February 1850")
    assert_equal period, parse("the End of February, 1850")

    assert_equal period, parse("End of Feb 1850")
    assert_equal period, parse("End of Feb, 1850")

    assert_equal period, parse("the End of Feb 1850")
    assert_equal period, parse("the End of Feb, 1850")

    assert_equal period, parse("Late February 1850")
    assert_equal period, parse("late February, 1850")

    assert_equal period, parse("Late Feb 1850")
    assert_equal period, parse("late Feb, 1850")
  end

  def test_beginning_of_year
    period = [Date.new(1969, 1, 1)..Date.new(1969, 1, 10)]

    assert_equal period, parse("Beginning of 1969")
    assert_equal period, parse("the Beginning of 1969")
  end

  def test_middle_of_year
    period = [Date.new(1969, 6, 20)..Date.new(1969, 7, 10)]

    assert_equal period, parse("Middle of 1969")
    assert_equal period, parse("the Middle of 1969")
  end

  def test_end_of_year
    period = [Date.new(1969, 12, 21)..Date.new(1969, 12, 31)]

    assert_equal period, parse("End of 1969")
    assert_equal period, parse("the End of 1969")
  end

  def test_day_month_year_to_day_month_year
    period = [Date.new(1976, 12, 10)..Date.new(1979, 4, 7)]

    assert_equal period, parse("from December 10th, 1976 to April 7th, 1979")
    assert_equal period, parse("from December 10, 1976 to April 7, 1979")
    assert_equal period, parse("from Dec 10th, 1976 to Apr 7th, 1979")
    assert_equal period, parse("from Dec 10, 1976 to Apr 7, 1979")

    assert_equal period, parse("from 10 December 1976 to 7 April 1979")
    assert_equal period, parse("from 10 Dec 1976 to 7 Apr 1979")

    assert_equal period, parse("from 1976-12-10 to 1979-04-07")
    assert_equal period, parse("from 1976-12-10 to 1979-4-7")

    assert_equal period, parse("from 12/10/1976 to 04/07/1979")
    assert_equal period, parse("from 12/10/1976 to 4/7/1979")

    assert_equal period, parse("December 10th, 1976 to April 7th, 1979")
    assert_equal period, parse("December 10, 1976 to April 7, 1979")
    assert_equal period, parse("Dec 10th, 1976 to Apr 7th, 1979")
    assert_equal period, parse("Dec 10, 1976 to Apr 7, 1979")

    assert_equal period, parse("10 December 1976 to 7 April 1979")
    assert_equal period, parse("10 Dec 1976 to 7 Apr 1979")

    assert_equal period, parse("1976-12-10 to 1979-04-07")
    assert_equal period, parse("1976-12-10 to 1979-4-7")

    assert_equal period, parse("12/10/1976 to 04/07/1979")
    assert_equal period, parse("12/10/1976 to 4/7/1979")

    assert_equal period, parse("December 10th, 1976 - April 7th, 1979")
    assert_equal period, parse("December 10, 1976 - April 7, 1979")
    assert_equal period, parse("Dec 10th, 1976 - Apr 7th, 1979")
    assert_equal period, parse("Dec 10, 1976 - Apr 7, 1979")

    assert_equal period, parse("10 December 1976 - 7 April 1979")
    assert_equal period, parse("10 Dec 1976 - 7 Apr 1979")

    assert_equal period, parse("1976-12-10 - 1979-04-07")
    assert_equal period, parse("1976-12-10 - 1979-4-7")

    assert_equal period, parse("12/10/1976 - 04/07/1979")
    assert_equal period, parse("12/10/1976 - 4/7/1979")

    assert_equal period, parse("12/10/1976-04/07/1979")
    assert_equal period, parse("12/10/1976-4/7/1979")

    assert_equal period, parse("from December 10th, 1976 to 04/07/1979")
    assert_equal period, parse("from December 10th, 1976 to 1979-04-07")
    assert_equal period, parse("from December 10th, 1976 to 7 Apr 1979")

    assert_equal period, parse("12/10/1976 to April 7th, 1979")
    assert_equal period, parse("1976-12-10 to April 7th, 1979")
    assert_equal period, parse("12/10/1976 to April 7, 1979")
    assert_equal period, parse("1976-12-10 to 7 April 1979")

    assert_equal period, parse("December 10th, 1976 - 04/07/1979")
    assert_equal period, parse("December 10th, 1976 - 1979-04-07")

    assert_equal period, parse("12/10/1976 - April 7th, 1979")
    assert_equal period, parse("1976-12-10 - April 7th, 1979")

    assert_equal period, parse("from 1976-12-10 to 04/07/1979")
    assert_equal period, parse("12/10/1976 to 1979-04-07")

    assert_equal period, parse("1976-12-10 - 04/07/1979")
    assert_equal period, parse("12/10/1976 - 1979-04-07")
  end

  def test_month_year_to_month_year
    period = [Date.new(1976, 12, 1)..Date.new(1979, 4, 30)]

    assert_equal period, parse("from December 1976 to April 1979")
    assert_equal period, parse("from Dec 1976 to Apr 1979")

    assert_equal period, parse("from ? Dec 1976 to ? Apr 1979")
    assert_equal period, parse("from [??] Dec 1976 to [??] Apr 1979")

    assert_equal period, parse("from 12/1976 to 4/1979")
    assert_equal period, parse("from 12/?/1976 to 4/?/1979")
    assert_equal period, parse("from 12/(??)/1976 to 4/(??)/1979")

    assert_equal period, parse("from 1976-12-? to 1979-04-?")
    assert_equal period, parse("from 1976-12-[??] to 1979-04-[??]")

    assert_equal period, parse("December 1976 to April 1979")
    assert_equal period, parse("Dec 1976 to Apr 1979")

    assert_equal period, parse("? Dec 1976 to ? Apr 1979")
    assert_equal period, parse("[??] Dec 1976 to [??] Apr 1979")

    assert_equal period, parse("12/1976 to 4/1979")
    assert_equal period, parse("12/?/1976 to 4/?/1979")
    assert_equal period, parse("12/(??)/1976 to 4/(??)/1979")

    assert_equal period, parse("1976-12-? to 1979-04-?")
    assert_equal period, parse("1976-12-[??] to 1979-04-[??]")

    assert_equal period, parse("December 1976 - April 1979")
    assert_equal period, parse("Dec 1976 - Apr 1979")

    assert_equal period, parse("? Dec 1976 - ? Apr 1979")
    assert_equal period, parse("[??] Dec 1976 - [??] Apr 1979")

    assert_equal period, parse("12/1976 - 4/1979")
    assert_equal period, parse("12/?/1976 - 4/?/1979")
    assert_equal period, parse("12/(??)/1976 - 4/(??)/1979")

    assert_equal period, parse("1976-12-? - 1979-04-?")
    assert_equal period, parse("1976-12-[??] - 1979-04-[??]")
  end

  def test_month_to_month_year
    period = [Date.new(2005, 3, 1)..Date.new(2005, 10, 31)]

    assert_equal period, parse("from March to October 2005")
    assert_equal period, parse("from Mar to Oct 2005")

    assert_equal period, parse("March to October 2005")
    assert_equal period, parse("Mar to Oct 2005")

    assert_equal period, parse("March - October 2005")
    assert_equal period, parse("Mar - Oct 2005")

    assert_equal period, parse("March-October 2005")
    assert_equal period, parse("Mar-Oct 2005")

    assert_equal period, parse("from 03 to 10 2005")
    assert_equal period, parse("03 to 10 2005")
    assert_equal period, parse("03 - 10 2005")
    assert_equal period, parse("03-10 2005")

    assert_equal period, parse("from 3 to 10 2005")
    assert_equal period, parse("3 to 10 2005")
    assert_equal period, parse("3 - 10 2005")
    assert_equal period, parse("3-10 2005")

    assert_equal period, parse("from March to October, 2005")
    assert_equal period, parse("from Mar to Oct, 2005")

    assert_equal period, parse("March to October, 2005")
    assert_equal period, parse("Mar to Oct, 2005")

    assert_equal period, parse("March - October, 2005")
    assert_equal period, parse("Mar - Oct, 2005")

    assert_equal period, parse("March-October, 2005")
    assert_equal period, parse("Mar-Oct, 2005")

    assert_equal period, parse("from 03 to 10, 2005")
    assert_equal period, parse("03 to 10, 2005")
    assert_equal period, parse("03 - 10, 2005")
    assert_equal period, parse("03-10, 2005")

    assert_equal period, parse("from 3 to 10, 2005")
    assert_equal period, parse("3 to 10, 2005")
    assert_equal period, parse("3 - 10, 2005")
    assert_equal period, parse("3-10, 2005")
  end

  def test_day_to_day_month_year
    period = [Date.new(1963, 11, 20)..Date.new(1963, 11, 24)]

    assert_equal period, parse("11/20-24/1963")

    assert_equal period, parse("from 20 to 24 November 1963")
    assert_equal period, parse("from 20. to 24. November 1963")
    assert_equal period, parse("from 20th to 24th November 1963")

    assert_equal period, parse("from November 20 to 24, 1963")
    assert_equal period, parse("from November 20. to 24., 1963")
    assert_equal period, parse("from November 20th to 24th, 1963")

    assert_equal period, parse("20 to 24 November 1963")
    assert_equal period, parse("20. to 24. November 1963")
    assert_equal period, parse("20th to 24th November 1963")

    assert_equal period, parse("November 20 to 24, 1963")
    assert_equal period, parse("November 20. to 24., 1963")
    assert_equal period, parse("November 20th to 24th, 1963")

    assert_equal period, parse("20 - 24 November 1963")
    assert_equal period, parse("20. - 24. November 1963")
    assert_equal period, parse("20th - 24th November 1963")

    assert_equal period, parse("November 20 - 24, 1963")
    assert_equal period, parse("November 20. - 24., 1963")
    assert_equal period, parse("November 20th - 24th, 1963")

    assert_equal period, parse("20-24 November 1963")
    assert_equal period, parse("20.-24. November 1963")
    assert_equal period, parse("20th-24th November 1963")

    assert_equal period, parse("November 20-24, 1963")
    assert_equal period, parse("November 20.-24., 1963")
    assert_equal period, parse("November 20th-24th, 1963")

    assert_equal period, parse("20th-24 November 1963")
    assert_equal period, parse("20.-24th November 1963")
    assert_equal period, parse("20-24. November 1963")

    assert_equal period, parse("November 20-24th, 1963")
    assert_equal period, parse("November 20.-24, 1963")
    assert_equal period, parse("November 20th-24., 1963")

    assert_equal period, parse("from 20 to 24 Nov 1963")
    assert_equal period, parse("from 20. to 24. Nov 1963")
    assert_equal period, parse("from 20th to 24th Nov 1963")

    assert_equal period, parse("from Nov 20 to 24, 1963")
    assert_equal period, parse("from Nov 20. to 24., 1963")
    assert_equal period, parse("from Nov 20th to 24th, 1963")

    assert_equal period, parse("20 to 24 Nov 1963")
    assert_equal period, parse("20. to 24. Nov 1963")
    assert_equal period, parse("20th to 24th Nov 1963")

    assert_equal period, parse("Nov 20 to 24, 1963")
    assert_equal period, parse("Nov 20. to 24., 1963")
    assert_equal period, parse("Nov 20th to 24th, 1963")

    assert_equal period, parse("20 - 24 Nov 1963")
    assert_equal period, parse("20. - 24. Nov 1963")
    assert_equal period, parse("20th - 24th Nov 1963")

    assert_equal period, parse("Nov 20 - 24, 1963")
    assert_equal period, parse("Nov 20. - 24., 1963")
    assert_equal period, parse("Nov 20th - 24th, 1963")

    assert_equal period, parse("20-24 Nov 1963")
    assert_equal period, parse("20.-24. Nov 1963")
    assert_equal period, parse("20th-24th Nov 1963")

    assert_equal period, parse("Nov 20-24, 1963")
    assert_equal period, parse("Nov 20.-24., 1963")
    assert_equal period, parse("Nov 20th-24th, 1963")

    assert_equal period, parse("20th-24 Nov 1963")
    assert_equal period, parse("20.-24th Nov 1963")
    assert_equal period, parse("20-24. Nov 1963")

    assert_equal period, parse("Nov 20-24th, 1963")
    assert_equal period, parse("Nov 20.-24, 1963")
    assert_equal period, parse("Nov 20th-24., 1963")

    assert_equal period, parse("November the 20th and 24th, 1963")
    assert_equal period, parse("the 20. and 24. of November 1963")
  end

  def test_day_month_to_day_month_year
    period = [Date.new(1903, 4, 7)..Date.new(1903, 12, 10)]

    assert_equal period, parse("from 7 April to 10 December 1903")
    assert_equal period, parse("from 7th Apr to 10th Dec 1903")
    assert_equal period, parse("from April 7 to December 10, 1903")
    assert_equal period, parse("from April the 7th to December the 10th, 1903")

    assert_equal period, parse("7 April to 10 December 1903")
    assert_equal period, parse("7th Apr to 10th Dec 1903")
    assert_equal period, parse("April 7 to December 10, 1903")
    assert_equal period, parse("April the 7th to December the 10th, 1903")

    assert_equal period, parse("7 April - 10 December 1903")
    assert_equal period, parse("7th Apr - 10th Dec 1903")
    assert_equal period, parse("April 7 - December 10, 1903")
    assert_equal period, parse("April the 7th - December the 10th, 1903")

    assert_equal period, parse("from 04/07 to 12/10/1903")
    assert_equal period, parse("04/07 to 12/10/1903")
    assert_equal period, parse("04/07 - 12/10/1903")
    assert_equal period, parse("04/07-12/10/1903")
  end

  def test_holiday_year
    assert_equal [Date.new(1963, 5, 27)], parse("Memorial Day 1963")
    assert_equal [Date.new(2013, 3, 31)], parse("Easter 2013")
    assert_equal [Date.new(1976, 5, 27)], parse("Solemnity of the Ascension of the Lord 1976")
    assert_equal [Date.new(2001, 11, 22)], parse("Thanksgiving Day 2001")
    assert_equal [Date.new(1776, 1, 1)], parse("New Year's Day 1776")
    assert_equal [Date.new(2013, 5, 12)], parse("Mother's Day 2013")
  end

  def test_sequence
    sequence = [
      Date.new(2013, 7, 4),
      Date.new(1995, 3, 1)..Date.new(1995, 3, 31),
      Date.new(1945, 1, 1)..Date.new(1945, 12, 31),
      Date.new(1850, 2, 1)..Date.new(1850, 2, 10),
      Date.new(1969, 12, 21)..Date.new(1969, 12, 31),
      Date.new(1976, 12, 10)..Date.new(1979, 4, 7),
      Date.new(1976, 12, 1)..Date.new(1979, 4, 30),
      Date.new(2005, 3, 1)..Date.new(2005, 10, 31),
      Date.new(1963, 11, 20)..Date.new(1963, 11, 24),
      Date.new(2013, 3, 31),
      Date.new(1903, 4, 7)..Date.new(1903, 12, 10)
    ]

    assert_equal sequence, parse("4 July 2013, Mar 1995; 1945 / Beginning of February 1850 and End of '69; from December 10th, 1976 to April 7th, 1979 and from December 1976 to April 79, from March to October 2005; 11/20-24/1963 / Easter Sunday 13, from 7 April to 10 December 1903")
  end

  def test_certainty_and_comment
    assert_equal 100, @parser.parse("22 nov 63").eval.certainty
    assert_equal 75,  @parser.parse("22 nov 63 @75").eval.certainty
    assert_equal 75,  @parser.parse("22 nov 63 @75%").eval.certainty
    assert_equal 75,  @parser.parse("22 nov 63 @ 75%").eval.certainty
    assert_equal 50,  @parser.parse("22 nov 63 @0.5").eval.certainty
    assert_equal 100, @parser.parse("22 nov 63 @1").eval.certainty
    assert_equal 1,   @parser.parse("22 nov 63 @1%").eval.certainty
    assert_equal 100, @parser.parse("22 nov 63 # foo").eval.certainty

    assert_raises NoMethodError do
      @parser.parse("22 nov 63 @").eval
    end

    assert_raises NoMethodError do
      @parser.parse("22 nov 63 @foo").eval
    end

    assert_equal nil, @parser.parse("22 nov 63").eval.comment
    assert_equal nil, @parser.parse("22 nov 63 #").eval.comment
    assert_equal "foo", @parser.parse("22 nov 63 #foo").eval.comment
    assert_equal "foo bar", @parser.parse("22 nov 63 #  foo bar").eval.comment

    parsed = @parser.parse("22 nov 63 @ 50% # comment").eval

    assert_equal 50, parsed.certainty
    assert_equal "comment", parsed.comment

    assert_equal nil, @parser.parse("22 nov 63 []").eval.comment
    assert_equal "foo", @parser.parse("22 nov 63 [foo]").eval.comment
    assert_equal "foo bar", @parser.parse("22 nov 63 [  foo bar ]").eval.comment

    parsed = @parser.parse("22 nov 63 @ 50% [comment]").eval

    assert_equal 50, parsed.certainty
    assert_equal "comment", parsed.comment

    assert_equal "comment", @parser.parse("[4] July 2013, Mar [1995]; 1945 / beginning of February 1850 and End of '69; from December 10th, 1976 to April [7th], 1979 and from December [1976] to April 79, from [March] to October 2005; 11/20-24/1963 / Easter Sunday 13, from 7 April to 10 December 1903 [comment]".downcase).eval.comment
  end

  def test_environment
    assert_equal [Date.new(1963, 11, 22)], parse("11/22/63")
    assert_equal [Date.new(1963, 11, 22)], parse("November 22, '63")
    assert_equal [Date.new(1963, 11, 22)], parse("22 Nov `63")
    assert_equal [Date.new(1963, 11, 22)], parse("November the 22nd, ´63")
    assert_equal [Date.new(1963, 7, 4)], parse("Independence Day ´63")

    assert_equal [Date.new(2012, 11, 22)], parse("11/22/12")
    assert_equal [Date.new(2012, 11, 22)], parse("November 22, '12")
    assert_equal [Date.new(2012, 11, 22)], parse("22 Nov `12")
    assert_equal [Date.new(2012, 11, 22)], parse("November the 22nd, ´12")
    assert_equal [Date.new(2012, 7, 4)], parse("Independence Day ´12")

    env = { :base => 1825 }

    assert_equal [Date.new(1863, 11, 22)], parse("11/22/63", env)
    assert_equal [Date.new(1863, 11, 22)], parse("November 22, '63", env)
    assert_equal [Date.new(1863, 11, 22)], parse("22 Nov `63", env)
    assert_equal [Date.new(1863, 11, 22)], parse("November the 22nd, ´63", env)
    assert_equal [Date.new(1863, 7, 4)], parse("Independence Day ´63", env)

    env = { "base" => 1776 }

    assert_equal [Date.new(1863, 11, 22)], parse("11/22/63", env)
    assert_equal [Date.new(1863, 11, 22)], parse("November 22, '63", env)
    assert_equal [Date.new(1863, 11, 22)], parse("22 Nov `63", env)
    assert_equal [Date.new(1863, 11, 22)], parse("November the 22nd, ´63", env)
    assert_equal [Date.new(1863, 7, 4)], parse("Independence Day ´63", env)

    env = { :base => "2000" }

    assert_equal [Date.new(2063, 11, 22)], parse("11/22/63", env)
    assert_equal [Date.new(2063, 11, 22)], parse("November 22, '63", env)
    assert_equal [Date.new(2063, 11, 22)], parse("22 Nov `63", env)
    assert_equal [Date.new(2063, 11, 22)], parse("November the 22nd, ´63", env)
    assert_equal [Date.new(2063, 7, 4)], parse("Independence Day ´63", env)

    assert_equal [Date.new(1963, 11, 22)], parse("11/22/1963", env)
    assert_equal [Date.new(1963, 11, 22)], parse("November 22, 1963", env)
    assert_equal [Date.new(1963, 11, 22)], parse("22 Nov 1963", env)
    assert_equal [Date.new(1963, 11, 22)], parse("November the 22nd, 1963", env)
    assert_equal [Date.new(1963, 7, 4)], parse("Independence Day 1963", env)
  end
end
