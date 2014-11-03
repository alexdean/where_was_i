require 'time'
require 'interpolate'

module WhereWasI

  # a series of sequential [lat, lon, elevation] points
  class Track
    attr_reader :start_time, :end_time, :start_location, :end_location

    def self.array_to_hash(a)
      {
        lat: a[0],
        lon: a[1],
        elevation: a[2]
      }
    end

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

      current = [lat, lon, elevation]

      if @start_time.nil? || time < @start_time
        @start_time     = time
        @start_location = current
      end

      if @end_time.nil?   || time > @end_time
        @end_time     = time
        @end_location = current
      end

      @points[time.to_i] = current

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
    # @param time [String,Time,Fixnum]
    # @return [Hash,nil]
    def at(time)
      if time.is_a?(String)
        time = Time.parse(time)
      end
      if time.is_a?(Fixnum)
        time = Time.at(time)
      end
      raise ArgumentError, "time must be a Time,String, or Fixnum" if ! time.is_a?(Time)

      return nil if ! in_time_range?(time)

      @interp ||= Interpolate::Points.new(@points)
      data = @interp.at(time.to_i)

      self.class.array_to_hash(data)
    end
  end

end
