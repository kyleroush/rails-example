source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.3.7'

gem 'rails', '~> 5.2.3'
gem 'sqlite3'
gem 'puma', '~> 3.11'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'activemerchant'

group :development, :test do
  gem 'rspec-rails', '~> 3.5'
  gem 'rspec-mocks'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'terminal-notifier-guard', '~> 1.6.1', require: false
  gem 'guard-bundler', require: false
  gem 'guard-rspec', require: false
  gem 'guard-rubocop', require: false
  gem 'rubocop-airbnb', require: false
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'simplecov', require: false
  gem 'simplecov-console', require: false
  gem 'rspec-json_expectations'
  gem 'factory_bot_rails', '~> 4.0'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'faker'
  gem 'database_cleaner'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
