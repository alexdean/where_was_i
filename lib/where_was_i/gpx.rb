require 'nokogiri'

module WhereWasI

  # Use a GPX file as a data source for location inferences.
  class Gpx
    attr_reader :tracks

    # @param [String] gpx_file Path to a GPX file.
    # @param [String] gpx_data GPX XML data string.
    #
    # @example with a gpx file
    #   g = WhereWasI::Gpx.new(gpx_file: '/path/to/data.gpx')
    # @example with gpx data
    #   g = WhereWasI::Gpx.new(gpx_data: '<?xml version="1.0"><gpx ...')
    def initialize(gpx_file:nil, gpx_data:nil)
      if gpx_file
        @gpx_data = open(gpx_file)
      elsif gpx_data
        @gpx_data = gpx_data
      else
        raise ArgumentError, "Must supply gpx_file or gpx_data."
      end

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
      @tracks_added = true
    end

    # infer a location from track data and a time
    #
    # @param [Time,String] time
    # @return [Hash]
    # @see Track#at
    def at(time)
      add_tracks if ! @tracks_added
      location = nil
      @tracks.each do |track|
        location = track.at(time)
        break if location
      end
      location
    end
  end

end
