# -*- encoding: utf-8 -*-
require File.expand_path('../lib/reflectiverecord/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["David Link"]
  gem.email         = ["developers@workhub.com"]
  gem.description   = %q{Smarter ActiveRecord models}
  gem.summary       = %q{ReflectiveRecord makes ActiveRecord objects expose their attributes explicitly, rendering the database schema irrelevant and adding a number of powerful Rake tasks to automate database migrations.}
  gem.homepage      = "https://github.com/workhub"

  gem.add_runtime_dependency 'activerecord', '>= 3.0.0'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'bcrypt-ruby'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "reflectiverecord"
  gem.require_paths = ["lib"]
  gem.version       = ReflectiveRecord::VERSION
end
