require 'spec_helper'

RSpec.describe WhereWasI::Gpx do

  let(:test_filename) {File.realpath(File.join(__FILE__, '/../../../data/test.gpx'))}

  describe "initialization" do

    it "should initialize with a gpx file path" do
      g = WhereWasI::Gpx.new(gpx_file: test_filename)
      g.add_tracks
      expect(g.tracks.size).to eq 2
    end

    it "should initialize with a gpx data string" do
      data = File.read(test_filename)
      g = WhereWasI::Gpx.new(gpx_data: data)
      g.add_tracks
      expect(g.tracks.size).to eq 2
    end

    it "should raise an error on invalid input" do
      expect {WhereWasI::Gpx.new}.to raise_error(ArgumentError, 'Must supply gpx_file or gpx_data.')
    end

  end

  describe "at" do

    let(:subject) {WhereWasI::Gpx.new(gpx_file: test_filename)}

    it "should find a time in any of multiple tracks" do
      expect(subject.at('2014-06-16T16:17:30Z')).to eq({
        lat: 48.83378860540688,
        lon: -87.5200978294015,
        elevation: 186.36333333333332
      })

      expect(subject.at('2014-06-17T14:40:20Z')).to eq({
        lat: 48.74732430891267,
        lon: -87.61892061547509,
        elevation: 188.08
      })
    end

    it "should return nil if time is not covered by any track" do
      expect(subject.at('2014-06-17T12:00:00Z')).to eq nil
    end

    it "should do inter-track interpolation" do
      subject = WhereWasI::Gpx.new(gpx_file: test_filename, intersegment_behavior: :interpolate)
      expect(subject.at('2014-06-17T12:00:00Z')).to eq({
        elevation: 187.56424463380702,
        lat: 48.75755751944594,
        lon: -87.60709448942973
      })
    end

    describe "nearest behavior" do
      let(:subject) {WhereWasI::Gpx.new(gpx_file: test_filename, intersegment_behavior: :nearest)}

      it "should return start of first segment for a time earlier than the first segment" do
        expect(subject.intersegment_behavior).to eq :nearest
        expect(subject.at('2014-06-16T16:00:00Z')).to eq({
          lat: 48.833804307505488,
          lon: -87.519973134621978,
          elevation: 186.150000000000006
        })
      end

      it "should return the end of the last segment for a time after the end of the last segment" do
        expect(subject.at('2014-06-17T15:00:00Z')).to eq({
          lat: 48.747312789782882,
          lon: -87.618932314217091,
          elevation: 188.080000000000013
        })
      end

      it "should return the closest segment beginning when between segments but nearer to a begin" do
        expect(subject.at('2014-06-16T17:00:00Z')).to eq({
          lat: 48.833690145984292,
          lon: -87.520155273377895,
          elevation: 183.75
        })
      end

      it "should return the closest segment ending when between segments but nearer to an end" do
        expect(subject.at('2014-06-17T13:00:00Z')).to eq({
          lat: 48.747263001278043,
          lon: -87.618850255385041,
          elevation: 188.080000000000013
        })
      end
    end

  end
end
