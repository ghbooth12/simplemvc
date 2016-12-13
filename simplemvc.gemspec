# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simplemvc/version'

Gem::Specification.new do |spec|
  spec.name          = "simplemvc"
  spec.version       = Simplemvc::VERSION
  spec.authors       = ["Gahee Heo"]
  spec.email         = ["ghbooth12@gmail.com"]

  spec.summary       = %q{Simple MVC}
  spec.description   = %q{Simple MVC}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_runtime_dependency "rack"
end
