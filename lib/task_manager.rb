# needs rufus-scheduler
require 'rufus/scheduler'
require 'pathname'

class TaskManager
  attr_accessor :jobs
  attr_reader :env, :path, :config

  # create the necessary scheduler/job-storages and store a basepath and a environment
  def initialize(env = 'staging', path = '.')
    @path = Pathname.new(path)
    @env = env.to_sym
    @jobs = {}
    @schedulers = {}
  end

  # return a named scheduler
  def scheduler(key)
    @schedulers[key] ||= Rufus::Scheduler.start_new
  end

  # create a new job with a separate scheduler
  def schedule(key)
    raise ArgumentError unless block_given?
    jobs[key] = yield scheduler(key)
  end

  # check wether a job is scheduled
  def scheduled?(key)
    !jobs[key].nil?
  end

  # prevent RubyVM from quitting
  def persist
    say "Scheduler will be persisted now, all definitions should be loaded now."
    scheduler(:internal).join
  end

  # unschedule/stop a job
  def unschedule(key)
    jobs[key].unschedule
    jobs[key] = nil
    say "Job #{key} stopped"
  end

  # system-call
  def execute_task(cmd_string)
    shortened_cmd = cmd_string.gsub(/--trace/, '').strip
    say   "starting #{shortened_cmd}"
    if system("cd #{path}; RAILS_ENV=#{env} #{cmd_string} >>#{path}/log/#{env}.scheduler.task_output.log 2>>#{path}/log/#{env}.scheduler.log")
      say "finished #{shortened_cmd}"
    else
      say "ERROR in #{shortened_cmd}"
    end
  end

  # output a message with Time
  def say(msg)
    puts "#{Time.now} - #{msg}"
  end

  # store configuration from a hash
  def config= hash
    @config = {}

    hash.keys.map do |key|
      @config[key.to_sym] = hash[key].map do |r|
        r.values.first
      end
    end

    config
  end

  # apply configuration
  def apply_configuration
    config.each do |method, args|
      send(method, *args)
    end
  end
end
