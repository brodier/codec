# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'codec/version'

Gem::Specification.new do |spec|
  spec.authors       = ["Bernard Rodier"]
  spec.email         = ["bernard.rodier@gmail.com"]
  spec.description   = %q{Generic Coder Decoder Tool}
  spec.summary       = %q{This Gem provide class that permit to instantiate Codec to parse or build any protocol}
  spec.homepage      = "https://github.com/brodier/codec"
  spec.license       = "MIT"

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.name          = "codec"
  spec.require_paths = ["lib"]
  spec.version       = Codec::VERSION
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
