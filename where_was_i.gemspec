# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'where_was_i/version'

Gem::Specification.new do |spec|
  spec.name          = "where_was_i"
  spec.version       = WhereWasI::VERSION
  spec.authors       = ["Alex Dean"]
  spec.email         = ["github@mostlyalex.com"]
  spec.summary       = %q{Infer where you were using a GPX data file.}
  spec.description   = %q{Given a GPX file and a time reference, return a location.}
  spec.homepage      = "https://github.com/alexdean/where_was_i"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'nokogiri',    '~> 1.0'
  spec.add_dependency 'interpolate', '~> 0.3'

  spec.add_development_dependency "bundler",        "~> 1.6"
  spec.add_development_dependency "rake",           "~> 10.1.0"
  spec.add_development_dependency "rspec",          "~> 3"
  spec.add_development_dependency "guard",          "~> 2.6"
  spec.add_development_dependency "guard-rspec",    "~> 4.3.1"
  spec.add_development_dependency "yard",           "~> 0.9.0"
  spec.add_development_dependency "github-markup",  "~> 1.3.0"
  spec.add_development_dependency "redcarpet",      "~> 3.2.0"
  spec.add_development_dependency "ruby_gntp",      "~> 0.3.0"
  spec.add_development_dependency "bundler-audit"
end
