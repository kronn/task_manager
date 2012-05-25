# vim:ft=ruby:fileencoding=utf-8

class TaskManager
  VERSION = "0.1.0"
  DATE = File.mtime(__FILE__)
  SUMMARY = 'A simple wrapper around the Rufus::Scheduler to have a more configurable setup.'
  DESCRIPTION = <<-EOT
    A simple wrapper around the Rufus::Scheduler to have a more configurable setup.

    The Task to be scheduled should be defined in a subclass.
  EOT
end
