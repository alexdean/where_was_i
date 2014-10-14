require 'spec_helper'

class String
  def to_time
    Time.parse(self)
  end
end

RSpec.describe WhereWasI::Track do

  before(:each) do
    subject.add_point(time:'2014-10-13T12:00:00Z', lat:10, lon:10, elevation:100)
    subject.add_point(time:'2014-10-13T12:00:05Z', lat:15, lon:20, elevation:200)
    subject.add_point(time:'2014-10-13T12:00:10Z', lat:20, lon:30, elevation:300)
  end

  describe "time_range" do
    it "should return a time range describing the time covered by the track" do
      expect(subject.time_range).to eq(
        '2014-10-13T12:00:00Z'.to_time..'2014-10-13T12:00:10Z'.to_time
      )
    end
  end

  describe "in_time_range?" do
    it "should be true if time is in time_range" do
      expect(subject.in_time_range?('2014-10-13T12:00:00Z')).to eq true
      expect(subject.in_time_range?('2014-10-13T12:00:01Z')).to eq true
      expect(subject.in_time_range?('2014-10-13T12:00:09Z')).to eq true
      expect(subject.in_time_range?('2014-10-13T12:00:10Z')).to eq true
    end

    it "should be false if time is outside of time_range" do
      expect(subject.in_time_range?('2014-10-12T11:59:59Z')).to eq false
      expect(subject.in_time_range?('2014-10-12T12:00:11Z')).to eq false
    end
  end

  describe "at" do
    it "should return nearest latitude" do
      expect(subject.at('2014-10-13T12:00:03Z')[:lat]).to eq 13
      expect(subject.at('2014-10-13T12:00:05Z')[:lat]).to eq 15
      expect(subject.at('2014-10-13T12:00:07Z')[:lat]).to eq 17
    end

    it "should interpolate nearest longitude" do
      expect(subject.at('2014-10-13T12:00:03Z')[:lon]).to eq 16
      expect(subject.at('2014-10-13T12:00:05Z')[:lon]).to eq 20
      expect(subject.at('2014-10-13T12:00:07Z')[:lon]).to eq 24
    end

    it "should interpolate nearest elevation" do
      expect(subject.at('2014-10-13T12:00:03Z')[:elevation]).to eq 160
      expect(subject.at('2014-10-13T12:00:05Z')[:elevation]).to eq 200
      expect(subject.at('2014-10-13T12:00:07Z')[:elevation]).to eq 240
    end

    it "should return nil if time is outside time_range" do
      expect(subject.at('2014-10-13T12:00:11Z')).to eq nil
    end
  end

  it "should have a start_time reader" do
    expect(subject.start_time).to eq '2014-10-13T12:00:00Z'.to_time
  end

  it "should have an end_time reader" do
    expect(subject.end_time).to eq '2014-10-13T12:00:10Z'.to_time
  end
end
