require "test_helper"

class Concept2DataParserTest < Minitest::Test

  describe "parsing data" do
    def setup
      @fixture = File.join(File.dirname(__FILE__),
        'fixtures/6k-stroke-data.txt')
      @parser = Concept2::Data::Parser.new(@fixture)
    end

    it "creates raw data for each rower" do
      assert_equal 4, @parser.rowers.size
    end

    it "records the name of each rower" do
      assert_equal %w(Snell Cheuse McCormick Keefe),
        @parser.rowers.map {|r| r[:name] }
    end
  end

  describe "compiling data" do
    def setup
      @fixture = File.join(File.dirname(__FILE__),
        'fixtures/6k-stroke-data.txt')
      @parser = Concept2::Data::Parser.new(@fixture)
    end

    it "compiles the overall time" do
      assert_equal ["26:17.5", "26:15", "27:00.9", "25:52"],
        @parser.rowers.map {|r| r[:overall_time] }
    end

    it "compiles the overall stroke rate" do
      assert_equal [26, 24, 26, 23],
        @parser.rowers.map {|r| r[:overall_stroke_rate] }
    end

    it "compiles the overall 500m split" do
      assert_equal ["2:11.5", "2:11.3", "2:15.1", "2:09.3"],
        @parser.rowers.map {|r| r[:overall_split] }
    end

    it "compiles 500m split average stroke rate" do
      assert_equal [28, 25, 25, 24, 25, 25, 26, 25, 26, 26, 27, 29],
        @parser.rowers[0][:stroke_rates]
    end

    it "compiles 500m splits" do
      assert_equal ["2:03.5", "2:12.5", "2:14", "2:15", "2:15", "2:14.5", "2:13", "2:14", "2:10", "2:10.4", "2:10.5", "2:04.6"],
        @parser.rowers[0][:splits]
    end
  end

end