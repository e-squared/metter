require "minitest/autorun"

require "rubygems"
require "treetop"

module ParserTestHelper
  def assert_evals_to_self(input)
    assert_evals_to(input, input)
  end

  def parse(input, env = {}, options = {})
    downcased_input  = input.downcase
    result = @parser.parse(downcased_input, options)
    downcased_input.replace input

    unless result
      puts
      puts input.inspect
      puts @parser.failure_reason
      puts
    end

    assert !result.nil?

    result.eval(env).dates
  end
end
