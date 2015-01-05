# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'concept2/data/parser/version'

Gem::Specification.new do |spec|
  spec.name          = "concept2-data-parser"
  spec.version       = Concept2::Data::Parser::VERSION
  spec.authors       = ["Henry Poydar"]
  spec.email         = ["hpoydar@gmail.com"]
  spec.summary       = %q{Compiles a 6K split spreadsheet from Concept2 stroke data files}
  spec.homepage      = "https://github.com/hpoydar/concept2-data-parser"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'chronic_duration', '~> 0.10.6'
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency  'minitest', '~> 5.5.0'
end
