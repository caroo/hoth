# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "hoth/version"

Gem::Specification.new do |s|
  s.name        = "hoth"
  s.version     = Hoth::VERSION
  s.authors     = ["pkwde dev team"]
  s.email       = ["dev@pkw.de"]
  s.homepage    = "http://github.com/caroo/hoth"
  s.summary     = %q{Registry and deployment description abstraction for SOA-Services}
  s.description = %q{Creating a SOA requires a centralized location to define all services within the
  SOA. Furthermore you want to know where to deploy those services.}


  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_runtime_dependency "activesupport"
  s.add_runtime_dependency "json"
  s.add_runtime_dependency "rack"
  
  s.add_development_dependency "rspec"
  s.add_development_dependency "rake"
  s.add_development_dependency "i18n"
end
