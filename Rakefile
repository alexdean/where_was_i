require "bundler/gem_tasks"
require "github/markup"
require "redcarpet"
require "yard"
require "yard/rake/yardoc_task"



YARD::Rake::YardocTask.new("doc") do |t|
  t.files = ['lib/**/*.rb']
  t.options = %w(--output-dir doc/where_was_i --main=README.md - doc/*.md)
end

task :remove_previous do
  `rm -Rf doc/where_was_i`
end
task doc: :remove_previous
