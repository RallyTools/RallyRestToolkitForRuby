require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

task :make_rally_api_gem do
  system("gem build rally_api.gemspec")
end

desc "run all api tests"
RSpec::Core::RakeTask.new('api_tests') do |t|
  t.pattern = ['test/*_spec.rb']
end

desc "run api create tests"
RSpec::Core::RakeTask.new('api_create_tests') do |t|
  t.pattern = ['test/*create_spec.rb']
end

