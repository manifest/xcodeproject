# -*- encoding: utf-8 -*-
require File.expand_path('../lib/xcodeproject/version', __FILE__)

Gem::Specification.new do |gem|
	gem.name              = 'xcodeproject'
	gem.version           = XcodeProject::VERSION
	gem.summary           = 'Read, write and build xcode projects'
	gem.description       = 'XcodeProject is Ruby API for working with Xcode project files'
	gem.author            = 'Andrey Nesterov'
	gem.email             = 'ae.nesterov@gmail.com'
	gem.homepage          = 'https://github.com/manifest/xcodeproject'
	gem.rubyforge_project = 'xcodeproject'
	gem.license           = 'MIT'

	gem.files             = `git ls-files`.split($\)
	gem.executables       = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
	gem.test_files        = gem.files.grep(%r{^(test|spec|features)/})
	gem.require_paths     = ["lib"]

	gem.required_ruby_version = '>= 1.8.7'
	gem.add_runtime_dependency 'json', '~> 1.7'
	gem.add_runtime_dependency 'uuid', '~> 2.3'
	gem.add_development_dependency 'rspec', '~> 2.10'
	gem.add_development_dependency 'rr', '~> 1.0'
	gem.add_development_dependency 'redcarpet', '~> 1.17'
	gem.add_development_dependency 'yard', '~> 0.7'
end

