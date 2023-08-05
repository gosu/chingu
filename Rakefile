require "rspec/core/rake_task"

require_relative "lib/chingu"

task :default => :spec

desc "Run the specs under spec"
RSpec::Core::RakeTask.new { |t| }

desc "Build the gem"
task :build do
  Dir.mkdir("dist") unless Dir.exist?("dist")

  sh "gem build chingu.gemspec"

  puts "Moving gem into directory pkg/"
  sh "mv chingu-#{Chingu::VERSION}.gem dist/"
end

desc "Release new gem"
task :release => :build do
  sh "gem push pkg/chingu-#{Chingu::VERSION}.gem"
end
