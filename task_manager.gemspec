# vim:ft=ruby:fileencoding=utf-8
$:.push File.expand_path("../lib", __FILE__)
require "task_manager/version"

Gem::Specification.new do |s|
  s.name        = "task_manager"
  s.version     = TaskManager::VERSION
  s.date        = TaskManager::DATE
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Mattthias Viehweger"]
  s.email       = ["kronn@kronn.de"]
  s.homepage    = "http://github.com/kronn/task_manager"
  s.summary     = TaskManager::SUMMARY
  s.description = TaskManager::DESCRIPTION

  s.rubyforge_project = "task_manager"

  s.files         = `git ls-files`.split("\n") - ['.gitignore']
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # s.rdoc_options = ['--charset=utf-8', '--fmt=shtml', '--all']
  # s.extra_rdoc_files     = TaskManager::EXTRA_RDOC_FILES
  # s.post_install_message = TaskManager::RELEASE_NOTES

  s.add_dependency 'rufus-scheduler', '~> 2.0.6'
  s.add_dependency 'daemons', '~> 1.1.3'

  # for tests, needed
  s.add_development_dependency 'rake'
  s.add_development_dependency 'more_unit_test'
  s.add_development_dependency 'mocha'
end
