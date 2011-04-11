# vim:ft=ruby:fileencoding=utf-8

unless defined?(TaskManager::VERSION)
  module TaskManager
    VERSION = "0.0.1"
    DATE = File.mtime(__FILE__)
    SUMMARY = ''
    DESCRIPTION = ''
  end
end
