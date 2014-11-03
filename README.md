# WhereWasI

Given a GPX data file and a time reference, infer a location.

[API documentation](http://rubydoc.info/github/alexdean/where_was_i/master/frames) is available on rubydoc.org.

## Examples

```ruby
w = WhereWasI::Gpx.new(gpx_file: '/home/alex/track.gpx')
w.at('2014-01-01T00:00:00Z')
#=> {lat: 48.0, lon: 98.0, elevation: 1000}
```

By default, `at` will return `nil` if the supplied time is not covered by the GPX data.
This includes times before the earliest data or after the last data, or times that
fall in-between GPX segments. (Like if your GPS receiver was turned off for a few
minutes.)

```ruby
w = WhereWasI::Gpx.new(gpx_file: '/home/alex/track.gpx')
w.at('2014-01-02T00:00:00Z')
#=> nil
```

## Inter-segment Behavior

For times that fall outside any segments, you can opt to guess about a location
in a few different ways, instead of returning `nil`.

### Interpolation

If you would like to interpolate a location using the ending and beginning
locations of the nearest segments, do the following:

```ruby
w = WhereWasI::Gpx.new(
  gpx_file: '/home/alex/track.gpx',
  intersegment_behavior: :interpolate
)
w.at('2014-01-02T00:00:00Z')
```

### Nearest

Interpolating will give impossible results if a large distance exists between
two segments. In those cases, simply selecting the location of segment begin/end
which is nearest in time may be preferable.

```ruby
w = WhereWasI::Gpx.new(
  gpx_file: '/home/alex/track.gpx',
  intersegment_behavior: :nearest
)
w.at('2014-01-02T00:00:00Z')
```
