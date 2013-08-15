# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ruby-atdd/version'

Gem::Specification.new do |gem|
  gem.name          = "ruby-atdd"
  gem.version       = Ruby::Atdd::VERSION
  gem.authors       = ["Greg Edwards"]
  gem.email         = ["greg@greglearns.com"]
  gem.description   = %q{A lightweight, easy to use, ATDD alternative to Cucumber for acceptance testing, that can also be used for stress testing.}
  gem.summary       = %q{Acceptance Tests treat your service (a website, an API, a CLI, etc.) as a blackbox, and encapsolute how a real user would use your service.

Acceptance Tests can be used for regression testing your service, but can also be used for Load/Stress Testing.

Ruby-ATDD's goal is to make it easy to test your service as well as stress test it.}
  gem.homepage      = "https://github.com/greglearns/ruby-atdd"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_dependency "minitest", "~> 5.0"
  gem.add_dependency "dotenv"
  gem.add_dependency "rerun"
  gem.add_dependency "pry"
  gem.add_dependency "pry-debugger"
end
