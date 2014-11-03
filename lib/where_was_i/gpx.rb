require 'nokogiri'

module WhereWasI

  # Use a GPX file as a data source for location inferences.
  class Gpx
    attr_reader :tracks, :intersegment_behavior

    Infinity = 1.0/0

    # @param [String] gpx_file Path to a GPX file.
    # @param [String] gpx_data GPX XML data string.
    # @param [nil,Symbol] intersegment_behavior How to handle times that fall between track segments.
    #   nil: return nil
    #   :interpolate: Interpolate a location from the ends of the nearest segments
    #
    # @example with a gpx file
    #   g = WhereWasI::Gpx.new(gpx_file: '/path/to/data.gpx')
    # @example with gpx data
    #   g = WhereWasI::Gpx.new(gpx_data: '<?xml version="1.0"><gpx ...')
    def initialize(gpx_file:nil, gpx_data:nil, intersegment_behavior:nil)
      if gpx_file
        @gpx_data = open(gpx_file)
      elsif gpx_data
        @gpx_data = gpx_data
      else
        raise ArgumentError, "Must supply gpx_file or gpx_data."
      end

      valid_values = [nil, :interpolate, :nearest]
      if !valid_values.include?(intersegment_behavior)
        raise ArgumentError, "intersegment_behavior must be one of: #{valid_values.inspect}"
      end
      @intersegment_behavior = intersegment_behavior

      @tracks_added = false
    end

    # extract track data from gpx data
    #
    # it's not necessary to call this directly
    def add_tracks
      @tracks = []
      doc = Nokogiri::XML(@gpx_data)

      doc.css('xmlns|trk').each do |trk|
        track = Track.new
        trk.css('xmlns|trkpt').each do |trkpt|
          # https://en.wikipedia.org/wiki/GPS_Exchange_Format#Units
          # decimal degrees, wgs84.
          # elevation in meters.
          track.add_point(
            lat: trkpt.attributes['lat'].text.to_f,
            lon: trkpt.attributes['lon'].text.to_f,
            elevation: trkpt.at_css('xmlns|ele').text.to_f,
            time: Time.parse(trkpt.at_css('xmlns|time').text)
          )
        end
        @tracks << track
      end

      @intersegments = []
      @tracks.each_with_index do |track,i|
        next if i == 0

        this_track = track
        prev_track = @tracks[i-1]

        inter_track = Track.new
        inter_track.add_point(
          lat: prev_track.end_location[0],
          lon: prev_track.end_location[1],
          elevation: prev_track.end_location[2],
          time: prev_track.end_time
        )
        inter_track.add_point(
          lat: this_track.start_location[0],
          lon: this_track.start_location[1],
          elevation: this_track.start_location[2],
          time: this_track.start_time
        )
        @intersegments << inter_track
      end

      @tracks_added = true
    end

    # infer a location from track data and a time
    #
    # @param [Time,String,Fixnum] time
    # @return [Hash]
    # @see Track#at
    def at(time)
      add_tracks if ! @tracks_added

      if time.is_a?(String)
        time = Time.parse(time)
      end
      time = time.to_i

      location = nil

      @tracks.each do |track|
        location = track.at(time)
        break if location
      end

      if ! location
        case @intersegment_behavior
        when :interpolate then
          @intersegments.each do |track|
            location = track.at(time)
            break if location
          end
        when :nearest then
          # hash is sorted in ascending time order.
          # all start/end points for all segments
          points = {}
          @tracks.each do |t|
            points[t.start_time.to_i] = t.start_location
            points[t.end_time.to_i] = t.end_location
          end

          last_diff = Infinity
          last_time = -1
          points.each do |p_time,p_location|
            this_diff = (p_time.to_i - time).abs

            # as long as the differences keep getting smaller, we keep going
            # as soon as we see a larger one, we step back one and use that value.
            if this_diff > last_diff
              l = points[last_time]
              location = Track.array_to_hash(points[last_time])
              break
            else
              last_diff = this_diff
              last_time = p_time
            end
          end

          # if we got here, time is > the end of the last segment
          location = Track.array_to_hash(points[last_time])
        end
      end

      # each segment has a begin and end time.
      # which one is this time closest to?
      # array of times in order. compute abs diff between time and each point.
      # put times in order. abs diff to each, until we get a larger value or we run out of points. then back up one and use that.
      # {time => [lat, lon, elev], time => [lat, lon, elev]}

      location
    end
  end

end
