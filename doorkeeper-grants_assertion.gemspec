# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "doorkeeper/grants_assertion/version"

Gem::Specification.new do |s|
  s.name        = 'doorkeeper-grants_assertion'
  s.version     = Doorkeeper::GrantsAssertion::VERSION
  s.authors     = ['Tute Costa']
  s.email       = ['tutecosta@gmail.com']
  s.homepage    = "https://github.com/doorkeeper-gem/doorkeeper-grants-assertion"
  s.summary     = "Assertion grant extension for Doorkeeper."
  s.description = "Assertion grant extension for Doorkeeper."
  s.license     = 'MIT'

  s.files         = `git ls-files -z`.split("\x0").reject { |f|
    f.match(%r{^(test|spec|features)/})
  }
  s.test_files    = ` /*`.split("\n")
  s.require_paths = ["lib"]

  s.add_dependency "railties", ">= 5.0"
  s.add_dependency "doorkeeper", ">= 4.0"

  s.add_development_dependency "rspec-rails", ">= 2.11.4"
  s.add_development_dependency "capybara", "~> 2.18.0"
  s.add_development_dependency "factory_bot", "~> 4.8.2"
  s.add_development_dependency "generator_spec", "~> 0.9.4"
  s.add_development_dependency "database_cleaner", "~> 1.6.2"
  s.add_development_dependency "pry", ">= 0.11.3"
  s.add_development_dependency "appraisal", "~> 2.2.0"
  s.add_development_dependency "omniauth-oauth2", "~> 1.5.0"
  s.add_development_dependency "omniauth-facebook", "~> 4.0.0"
  s.add_development_dependency "omniauth-google-oauth2", "~> 0.5.3"
  s.add_development_dependency "webmock", "~> 3.3.0"
  s.add_development_dependency "devise", ">= 4.4.3"
end
