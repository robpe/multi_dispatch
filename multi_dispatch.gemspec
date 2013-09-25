# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'multi_dispatch/version'

Gem::Specification.new do |spec|
  spec.name          = "multi_dispatch"
  spec.version       = MultiDispatch::VERSION
  spec.authors       = ["Robert Pozoga"]
  spec.email         = ["robert.pozoga@gmail.com"]
  spec.description   = %q{This gem provides light-weight and easy-to-use multiple dispatch generic methods.}
  spec.summary       = %q{Multiple dispatch for Ruby.}
  spec.homepage      = "http://github.com/robpe/multi-dispatch"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
