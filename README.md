# WhereWasI

Given a GPX data file and a time reference, infer a location.

[API documentation](http://rubydoc.info/github/alexdean/where_was_i/master/frames) is available on rubydoc.org.

## Examples

```ruby
w = WhereWasI::Gpx.new(gpx_file: '/home/alex/track.gpx')
w.at('2014-01-01T00:00:00Z')
#=> {lat: 48.0, lon: 98.0, elevation: 1000}
```

`at` will return `nil` if the supplied time is not covered by the GPX data.

```ruby
w = WhereWasI::Gpx.new(gpx_file: '/home/alex/track.gpx')
w.at('2014-01-02T00:00:00Z')
#=> nil
```
