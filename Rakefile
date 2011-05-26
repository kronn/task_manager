# require 'bundler'
# Bundler::GemHelper.install_tasks

task :test do
  $:.push(File.expand_path('../lib/', __FILE__))
  $:.push(File.expand_path('../test/', __FILE__))

  require 'test/all'
end

task :default => :test
