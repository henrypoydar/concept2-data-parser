require "concept2/data/parser/version"
require "csv"
require 'chronic_duration'

module Concept2
  module Data
    class Parser

      attr_accessor :rowers

      def initialize(file, distance=6000)
        @file = file
        @distance = distance
        @raw = nil
        @rowers = [] # Array of arrays where we'll store everything

        read_file
        compile_totals!
        toss_empties!
        compile_splits!
      end

      def write_file!(file="#{File.basename(@file)}-formatted.csv")
        headers = ["Name", "Time", "Avg. Split", "Avg. SPM"]
        (@distance/500).times do |i|
          headers << "#{(i+1)*500}m Split"
          headers << "#{(i+1)*500}m SPM"
        end
        CSV.open(file, "wb") do |csv|
          csv << headers
          rowers.each do |rower|
            res = []
            res << rower[:name]
            res << rower[:overall_time]
            res << rower[:overall_split]
            res << rower[:overall_stroke_rate]
            (@distance/500).times do |i|
              res << rower[:splits][i]
              res << rower[:stroke_rates][i]
            end
            csv << res
          end
        end
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
          rower[:overall_time] = normalize_duration(ChronicDuration.output(
            rower[:data].last[0].round(1), format: :chrono))
          rower[:overall_stroke_rate] = average_stroke_rate(
            rower[:data].map {|n| n[2] })
          rower[:overall_split] = split_time(rower[:data].last[0], @distance.to_f)
        end
      end

      def compile_splits!
        @rowers.each do |rower|
          idxs = []
          (@distance/500).times do |i|
            idx_val = rower[:data].map {|r| r[1] }.
              min_by { |v| (v-(500*(i+1))).abs }
            idxs << rower[:data].index {|r| r[1] == idx_val }
          end
          rower[:stroke_rates] = []
          rower[:splits] = []
          prev_idx = 0
          idxs.each do |idx|
            rower[:stroke_rates] << average_stroke_rate(
              rower[:data][prev_idx..idx].map {|n| n[2] })
            rower[:splits] << split_time(
              rower[:data][idx][0] - rower[:data][prev_idx][0])
            prev_idx = idx
          end
        end
      end

      def toss_empties!
        @rowers = @rowers.select {|r| r[:overall_stroke_rate] != 0 }
      end

      def average_stroke_rate(stroke_array)
        stroke_array.inject(:+) / stroke_array.size
      end

      def split_time(secs, distance=500.0)
        normalize_duration(ChronicDuration.output(
          ((secs * 500.0) / distance).round(1), format: :chrono))
      end

      # Adds a decimal place so that spreadsheets distinguish hours/minutes
      def normalize_duration(duration)
        duration = "#{duration}.0" unless duration =~ /\..+$/
        duration
      end

    end
  end
end
