#!/bin/bash

# read environment variables or use default values
RAILS_ENV=${RAILS_ENV:-"staging"}
RUBY_BIN=${RUBY_BIN:-"ruby"}
BASEPATH=${BASEPATH:-"/home/application/projects/rails/$RAILS_ENV/current"}

# variables that should only be changed if you REALLY know what you're doing
# e.g. the log-filename is hardcoded in the scheduling-script
LOG="$BASEPATH/log/$RAILS_ENV.scheduler.log"
SCHEDULER_FILENAME='tasks.rb'
SCHEDULER="$BASEPATH/config/$SCHEDULER_FILENAME"
PID=`ps aux | grep -v 'grep' | egrep "$RAILS_ENV.*$SCHEDULER_FILENAME" | head -n1 | sed 's/^\w*\W\+\(\w\+\).*$/\1/'`

# start scheduler in the background
function start_scheduler() {
  if [ -z "$PID" ]; then
    $RUBY_BIN $SCHEDULER >>$LOG 2>&1 &
    disown -a -h
  fi
}

# kill the scheduler if it's running
function kill_scheduler() {
  if [ -n "$PID" ]; then
    kill $PID
  fi;
}

# actual "init.d"-like interface
case "$1" in
  start)
    start_scheduler
    ;;
  stop)
    kill_scheduler
    ;;
  restart)
    kill_scheduler
    start_scheduler
    ;;
  status)
    if [ -n "$PID" ]; then
      echo "Scheduling is active ($PID)"
    else
      echo "Scheduling is inactive"
    fi
    ;;
  pid)
    echo $PID
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|status|pid}"
    echo ""
    echo "recognized environment variables with default in parentheses:"
    echo ""
    echo "  variables which should be given"
    echo "    BASEPATH  ($BASEPATH)"
    echo "    RAILS_ENV ($RAILS_ENV)"
    echo ""
    echo "  variables which can be given for optimization reasons"
    echo "    RUBY_BIN  ($RUBY_BIN)"
    ;;
esac

# for the lack of a better return value, exit successfully
exit 0
