require 'bundler/gem_tasks'

#Test::Unit
require 'rake/testtask'

Rake::TestTask.new do |t|
 t.libs << 'test'
 t.libs << '/usr/lib/ruby/1.9.1/x86_64-linux'
end

desc "Run tests"
task :default => :test
