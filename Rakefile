require 'rake'
require 'rake/clean'
require 'rake/testtask'

CLEAN.include('**/*.gem', '**/*.rbc')

namespace :gem do
  desc "Create the solaris-file gem"
  task :create => [:clean] do
    require 'rubygems/package'
    spec = eval(IO.read('solaris-file.gemspec'))
    spec.signing_key = File.join(Dir.home, '.ssh', 'gem-private_key.pem')
    Gem::Package.build(spec, true)
  end

  desc "Install the solaris-file gem"
  task :install => [:create] do
    file = Dir["*.gem"].first
    sh "gem install -l #{file}"
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
