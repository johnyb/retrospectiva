source :rubygems

gem "handles_sortable_columns", "0.1.3"
gem "rails", "2.3.11", :require => false
gem "will_paginate", "~> 2.3.0"
gem "acts-as-taggable-on", "~> 2.0.0" 
gem "RedCloth", :require => "redcloth"
gem 'i18n', "~> 0.4.0"

database = begin
  File.read(File.dirname(__FILE__) + '/config/database.yml').scan(/production.+?adapter\W+(\w+)/im).join
rescue
  nil
end

case database
when /postgres/, /pg/
  gem 'pg', :require => false
when /sqlite/
  gem 'sqlite3', :require => false
else
  gem 'mysql', :require => false
end

group :test do
  gem 'cucumber-rails', "~> 0.3.2"
  gem 'database_cleaner', "~> 0.5.0"
  gem 'webrat',  "~> 0.7.0"
  gem "rspec", "~> 1.3.1", :require => "spec"
  gem "rspec-rails", "~> 1.3.3", :require => "spec"
  gem "shoulda"
  gem "test-unit", "~> 1.2.3"
end

group :development do
  gem "thin"
end
