# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "bookchef"
  gem.homepage = "http://github.com/snitko/bookchef"
  gem.license = "MIT"
  gem.summary = %Q{Parser and compiler for BookChef.xml format}
  gem.email = "roman.snitko@gmail.com"
  gem.authors = ["Roman Snitko"]
  gem.executables << 'bookchef'
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "bookchef #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require 'sass'
task :compile_css do
  `sass --update --scss lib/bookchef/stylesheets/scss/:lib/bookchef/stylesheets/css`
end
