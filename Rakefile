require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rbconfig'
include Config

CLEAN.include('**/*.gem', '**/*.rbc')

namespace :gem do
  desc "Create the solaris-file gem"
  task :create => [:clean] do
    spec = eval(IO.read('solaris-file.gemspec'))
    Gem::Builder.new(spec).build
  end

  desc "Install the solaris-file gem"
  task :install => [:create] do
    file = Dir["*.gem"].first
    sh "gem install #{file}"
  end
end

desc "Run the example program"
task :example do
  ruby "-Ilib examples/example_solaris_file.rb"
end

Rake::TestTask.new do |t|
  t.warning = true
  t.verbose = true
end

task :default => :test
