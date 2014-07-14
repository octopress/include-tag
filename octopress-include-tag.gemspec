# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'octopress-include-tag/version'

Gem::Specification.new do |spec|
  spec.name          = "octopress-include-tag"
  spec.version       = Octopress::Tags::IncludeTag::VERSION
  spec.authors       = ["Brandon Mathis"]
  spec.email         = ["brandon@imathis.com"]
  spec.summary       = %q{A powerful include tag with conditions, filters and more}
  spec.description   = %q{A powerful include tag with conditions, filters and more}
  spec.homepage      = "https://github.com/octopress/include-tag"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "octopress-tag-helpers", "~> 1.0"
  spec.add_runtime_dependency "jekyll", "~> 2.0"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "clash"
  spec.add_development_dependency "octopress-ink"
end
