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

  # we will be configuring the taskmanager with a hash, so lets define one
  # this configuration would expect the necessary methods on a subclass of the TaskManager
  def configuration
    {
      "restart_jobs"=>[
        {"cron"=>"* 6 * * *"},
        {"restart"=>["navision_import"]}
      ],
      "navision_import"=>[
        {"every"=>"3h"},
        {"stop_hour"=>18},
        {"stop_minute"=>0}
      ],
      "cnet_import"=>[
        {"cron"=>"30 0 * * *"},
        {"confirm"=>false}
      ]
    }
  end

  def test_taskmanager_can_be_configured_with_hash
    assert_respond_to tm, :'config='
    assert_respond_to tm, :config

    tm.config = configuration

    expected = {
      :restart_jobs=>["* 6 * * *", ["navision_import"]],
      :navision_import=>["3h", 18, 0],
      :cnet_import=>["30 0 * * *", false]
    }

    assert_equal expected, tm.config
  end

  def test_taskmanager_can_apply_the_configration
    tm.expects(:restart_jobs).with('* 6 * * *', ["navision_import"])
    tm.expects(:navision_import).with('3h', 18, 0)
    tm.expects(:cnet_import).with('30 0 * * *', false)

    tm.config = configuration

    assert_respond_to tm, :apply_configuration

    tm.apply_configuration
  end
end
