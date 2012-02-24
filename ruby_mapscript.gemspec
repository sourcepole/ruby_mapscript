# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ruby_mapscript/version"

Gem::Specification.new do |s|
  s.name        = "ruby_mapscript"
  s.version     = RubyMapscript::VERSION
  s.authors     = ["Pirmin Kalberer"]
  s.email       = ["pka@sourcepole.ch"]
  s.homepage    = "https://github.com/sourcepole/ruby_mapscript"
  s.summary     = %q{Ruby Mapscript API extensions}
  s.description = %q{Ruby Mapscript API extensions}

  s.rubyforge_project = "ruby_mapscript"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
