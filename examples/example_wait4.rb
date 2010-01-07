#######################################################################
# example_wait4.rb
#
# Simple demonstration of the Process.wait4 method. You can use the
# 'rake example_wait4' task to run this code.
#
# Modify as you see fit.
#######################################################################
require 'proc/wait3'

pid = fork{ sleep 2 }
p Time.now
Process.wait4(pid, Process::WUNTRACED)
p $?
