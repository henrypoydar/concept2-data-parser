require "concept2/data/parser/version"
require "csv"
require 'chronic_duration'

module Concept2
  module Data
    class Parser

      attr_accessor :rowers

      def initialize(file)
        @file = file
        @raw = nil
        @rowers = [] # Array of arrays where we'll store everything

        read_file
        compile_totals!
        toss_empties!
      end

    protected

      def read_file
        CSV.foreach(@file, headers: true) do |csv|
          if !csv['PM3'].nil?
            @rowers << {name: csv['PM3'], data: []}
          end
          @rowers[@rowers.size-1][:data] << [
            csv['Time'].to_f,
            csv['Meters'].to_f,
            csv['Stroke_Rate'].to_i]
        end
      end

      def compile_totals!
        @rowers.each do |rower|
          rower[:overall_time] = ChronicDuration.output(
            rower[:data].last[0].round(1), format: :chrono)
          rower[:overall_stroke_rate] = rower[:data].
            map {|n| n[2] }.
            inject(0) {|sum, sample| sum += sample} / rower[:data].size
          rower[:overall_500m_split] = ChronicDuration.output((
              (rower[:data].last[0] * 500.0) / 6000.0).round(1),
              format: :chrono)
        end
      end

      def toss_empties!
        @rowers = @rowers.select {|r| r[:overall_stroke_rate] != 0 }
      end

    end
  end
end
