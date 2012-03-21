require 'rubygems'

require 'more_unit_test/assert_stdout'
require 'test/unit'
require 'mocha'

class Test::Unit::Catch_IO
  def sync=(value)
    value
  end

  def puts(string)
    write("#{string}\n")
  end

  def print(string)
    write(string)
  end
end

require 'task_manager'
