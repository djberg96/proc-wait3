#######################################################################
# example_waitid.rb
#
# Simple demonstration of the Process.waitid method. You can run this
# code via the 'rake example_waitid' task.
#
# Modify as you see fit.
#######################################################################
require 'proc/wait3'

pid = fork{ sleep 2 }
p Time.now
Process.waitid(Process::P_PID, pid, Process::WEXITED)
p $?
