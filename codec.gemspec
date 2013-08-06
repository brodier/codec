# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'codec/version'

Gem::Specification.new do |spec|
  spec.name          = "codec"
  spec.version       = Codec::VERSION
  spec.authors       = ["Bernard Rodier"]
  spec.email         = ["bernard.rodier@gmail.com"]
  spec.description   = %q{Generic Coder Decoder Tool}
  spec.summary       = %q{This Gem provide class that permit to instantiate Codec to parse or build any protocol}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
