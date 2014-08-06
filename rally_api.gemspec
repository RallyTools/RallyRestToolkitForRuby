# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rally_api/version"

Gem::Specification.new do |s|
  s.name        = "rally_api"
  s.version     = RallyAPI::VERSION
  s.authors     = ["Dave Smith"]
  s.email       = ["dsmith@rallydev.com"]
  s.homepage    = "https://github.com/RallyTools/RallyRestToolkitForRuby"
  s.summary     = "A wrapper for the Rally Web Services API using json"
  s.description = "API wrapper for Rally's JSON REST web services api"

  s.rubyforge_project = "rally_api"

  s.license = 'MIT'

  s.has_rdoc         = false

  s.add_dependency('httpclient', '~> 2.3.0')
  s.add_development_dependency('simplecov')
  s.add_development_dependency('rspec', '~> 2.9')
  s.add_development_dependency('rake')
  s.add_development_dependency('cucumber')
  s.add_development_dependency('aruba')

  #s.files         = `git ls-files`.split("\n")
  s.files = %w(README.md Rakefile) + Dir.glob("{lib}/**/*.rb").delete_if { |item| item.include?(".svn") }
  #s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  #s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
