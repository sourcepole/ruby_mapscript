# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ruby_mapscript/version"

Gem::Specification.new do |s|
  s.name        = "ruby_mapscript"
  s.version     = RubyMapscript::VERSION
  s.authors     = ["Pirmin Kalberer"]
  s.email       = ["pka@sourcepole.ch"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "ruby_mapscript"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
