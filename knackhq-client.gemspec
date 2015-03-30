# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'knackhq/client/version'

Gem::Specification.new do |spec|
  spec.name = 'knackhq-client'
  spec.version = Knackhq::Client::VERSION
  spec.authors = ['MichaelAChrisco']
  spec.email = ['michaelachrisco@gmail.com']

  spec.summary = 'Knackhq.com API client'
  spec.description = 'Knackhq.com API client'
  spec.homepage = 'https://github.com/westernmilling/knackhq-client'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0")
    .reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'blanket_wrapper', '~> 1.1.0'
  spec.add_dependency 'rest-client'
  spec.add_dependency 'hashie'
  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'codeclimate-test-reporter'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.2.0'
  spec.add_development_dependency 'rspec-its', '~> 1.2.0'
  spec.add_development_dependency 'vcr', '~> 2.9.0'
  spec.add_development_dependency 'webmock', '~> 1.20.0'
end
