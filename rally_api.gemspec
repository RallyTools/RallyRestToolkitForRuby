# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rally_api/version"

Gem::Specification.new do |s|
  s.name        = "rally_api"
  s.version     = RallyAPI::VERSION
  s.authors     = ["Dave Smith", "Rylee Keys", "Kip Lehman"]
  s.email       = ["dsmith@rallydev.com", "rylee@rallydev.com", "klehman@rallydev.com"]
  s.homepage    = "https://github.com/RallyTools/RallyRestToolkitForRuby"
  s.summary     = "A wrapper for the Rally Web Services API using json"
  s.description = "API wrapper for Rally's JSON REST web services api"
  s.rubyforge_project = "rally_api"
  s.license = 'MIT'
  s.has_rdoc = false

  s.add_dependency('httpclient', '>=2.8.3')

  s.add_development_dependency('bundler',     '1.5.1')
  s.add_development_dependency('rake',        '10.3.2')
  s.add_development_dependency('rspec',       '3.1.0')
  s.add_development_dependency('simplecov',   '0.9.1')
  s.add_development_dependency('pry',         '0.10.1')

  #s.files         = `git ls-files`.split("\n")
  s.files = %w(README.md LICENSE Gemfile rally_api.gemspec Rakefile) + Dir.glob("{lib}/**/*.rb")
  #s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  #s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
