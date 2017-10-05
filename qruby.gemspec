# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'qruby/version'

Gem::Specification.new do |s|
  s.name          = 'qruby'
  s.version       = QRuby::VERSION
  s.date          = '2017-10-05'
  s.summary       = 'simple sql query builder library for Ruby.'
  s.description   = 'simple sql query builder library for Ruby.'
  s.authors       = ['İzni Burak Demirtaş']
  s.email         = ['info@burakdemirtas.org']
  s.homepage      = 'https://github.com/izniburak/qruby'
  s.license       = 'MIT'

  s.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec)/}) }
  s.require_paths = ['lib']

  s.add_development_dependency 'rspec'
end
