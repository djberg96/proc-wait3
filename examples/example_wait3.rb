#######################################################################
# example_wait3.rb
#
# Simple demo of the Process.wait3 method. You can use the
# 'rake example_wait3' rake task to run this program.
#
# Modify as you see fit.
#######################################################################
require 'proc/wait3'

pid = fork{ sleep 1; exit 2 }

p Time.now
Process.wait3
p $?
