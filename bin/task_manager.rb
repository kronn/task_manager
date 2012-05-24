# vim:ft=ruby:fileencoding=utf8

require 'daemons'
require 'pathname'

base_path = Pathname.new('.').expand_path

Daemons.run(base_path.join('config/scheduler.rb'), {
  :app_name => "#{ENV['RAILS_ENV']}.scheduler",
  :dir_mode => :normal,
  :dir => base_path.join('tmp/pids'),
  :mutliple => false,
  :monitor => true,
  :log_dir => base_path.join('log'),
  :log_output => true,
  :keep_pid_files => false
})

