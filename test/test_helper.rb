# frozen_string_literal: true

if ENV["COVERAGE"] == "on"
  require "simplecov"
  require "simplecov-console"
  require "codecov"

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
    [
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCov::Formatter::Console
    ]
  )

  SimpleCov.start do
    # TODO: fix test coverage
    # minimum_coverage 100

    add_filter "test"
  end
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "sharing"

require "minitest/autorun"
require "minitest/reporters"
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(color: true)]
