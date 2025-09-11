require 'bundler/gem_tasks'
require 'rake/testtask'
require_relative 'summernote_updater.rb'

Rake::TestTask.new do |t|
  t.libs << 'test'
end

desc "Run tests"
task default: :test

desc "Update assets"
task 'update' do
  SummernoteUpdater.new.execute
end
