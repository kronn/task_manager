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

  # lets create a TaskManager so we can test a little more
  class CustomTaskManager < TaskManager
    def navision_import(frequency, end_hr, end_min = 0)
      schedule(:navision_import) do |scheduler|
        scheduler.every(frequency, :blocking => true) do
          (Time.now.hour >= end_hr && Time.now.min >= end_min) ?
            unschedule(:navision_import) :
            execute_task('echo "importing from navision"')
        end
      end
    end

    def cnet_import(cron_def, param)
      schedule(:cnet_import) do |scheduler|
        scheduler.cron(cron_def) do
          arg = param ? "production" : "test"
          execute_task(%(echo "importing from cnet server #{arg}" ))
        end
      end
    end

    def restart_jobs(cron_def, tasks)
      schedule(:restart_jobs) do |scheduler|
        scheduler.cron(cron_def) do
          tasks.each do |task|
            send(task, *config[task]) unless scheduled?(task)
          end
        end
      end
    end
  end

  # verify that the building blocks are there

  def test_taskmanager_has_a_schedule_method
    assert_respond_to tm, :schedule
    assert_equal 1, tm.method(:schedule).arity

    assert_raise ArgumentError do
      tm.schedule(:blah)
    end

    assert_nothing_raised do
      tm.schedule(:blah) do |scheduler|
        # the scheduler should be returned again
        scheduler
      end
    end
  end

  def test_schedule_method_stores_the_job
    prev_size = tm.jobs.size

    tm.schedule(:blah) do |scheduler|
      # the scheduler should be returned again
      scheduler
    end

    assert_equal (prev_size + 1), tm.jobs.size
    assert_not_nil tm.jobs[:blah], tm.jobs.inspect
  end

  def test_taskmanager_knows_what_is_scheduled
    assert_respond_to tm, :'scheduled?'
    assert !tm.scheduled?(:undefined)

    tm.schedule(:defined) do |s|
      s
    end

    assert tm.scheduled?(:defined)
  end
end
