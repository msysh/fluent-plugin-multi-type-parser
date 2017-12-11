require "helper"
require "fluent/plugin/filter_multi_type_parser.rb"

class MultiTypeParserFilterTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  test "failure" do
    flunk
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Filter.new(Fluent::Plugin::MultiTypeParserFilter).configure(conf)
  end
end
