$:.unshift File.dirname(__FILE__)

require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.pattern = 'test/**/*Tests.rb'
end

task :default => :test