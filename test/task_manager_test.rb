require 'test_helper'

class TaskManagerTest < Test::Unit::TestCase
  # remember to clean up after each test-run
  def teardown
    # @sut.unschedule(:internal)
    @sut = nil
  end

  # lets start by trying to create a taskmanager
  def test_creating_a_blank_taskmanager
    assert_nothing_raised do
      TaskManager.new
      TaskManager.new('staging', '/path/to/project')
    end
  end

  # now that thats out of the way, define some helper methods
  def tm
    @sut ||= TaskManager.new
  end

  # assert_stdout_block does Expected==Actual internally, therefore I give a more flexbile expectation
  class MatchableString < String
    def initialize(string)
      @data = string
    end

    def ==(other)
      /#{Regexp.escape(@data)}/.match(other)
    end
  end

  # on to the show

  def test_taskmanager_can_output_messages
    assert_stdout_block MatchableString.new('testing') do
      tm.say('testing')
    end
  end
end
