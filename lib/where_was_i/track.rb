require 'time'
require 'interpolate'

module WhereWasI

  # a series of sequential [lat, lon, elevation] points
  class Track
    attr_reader :start_time, :end_time, :start_location, :end_location

    def initialize
      @points = {}
    end

    # add a point to the track
    #
    # @param [Float] lat latitude
    # @param [Float] lon longitude
    # @param [Float] elevation elevation
    # @param [Time] time time at the given location
    def add_point(lat:, lon:, elevation:, time:)
      time = Time.parse(time) if ! time.is_a?(Time)

      if @start_time.nil? || time < @start_time
        @start_time     = time
        @start_location = [lat, lon, elevation]
      end

      if @end_time.nil?   || time > @end_time
        @end_time     = time
        @end_location = [lat, lon, elevation]
      end

      @points[time.to_i] = [lat, lon, elevation]

      true
    end

    # the time range covered by this track
    #
    # @return Range
    def time_range
      start_time..end_time
    end

    # is the supplied time covered by this track?
    #
    # @param time [Time]
    # @return Boolean
    def in_time_range?(time)
      time = Time.parse(time) if ! time.is_a?(Time)
      time_range.cover?(time)
    end

    # return the interpolated location for the given time
    # or nil if time is outside the track's start..end
    #
    # @example
    #  track.at(time) => {lat:48, lon:98, elevation: 2100}
    # @param time [String,Time]
    # @return [Hash,nil]
    def at(time)
      return nil if ! in_time_range?(time)
      if ! time.is_a?(Time)
        time = Time.parse(time).to_i
      end
      time = time.to_i

      @interp ||= Interpolate::Points.new(@points)
      data = @interp.at(time)

      {
        lat: data[0],
        lon: data[1],
        elevation: data[2]
      }
    end
  end

end
