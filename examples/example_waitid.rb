# frozen_string_literal: true

#######################################################################
# example_waitid.rb
#
# Simple demonstration of the Process.waitid method. You can run this
# code via the 'rake example_waitid' task.
#
# Modify as you see fit.
#######################################################################
require 'proc/wait3'

pid1 = fork { puts "PID1 GRP: #{Process.getpgrp}"; sleep 2 }
pid2 = fork { puts "PID2 GRP: #{Process.getpgrp}"; sleep 3 }
pid3 = fork { puts "PID2 GRP: #{Process.getpgrp}"; sleep 4 }

puts "PID1: #{pid1}"
puts "PID2: #{pid2}"
puts "PID3: #{pid3}"

puts "MAIN GRP: #{Process.getpgrp}"
p Time.now

status = Process.waitid(Process::P_PGID, Process.getpgrp, Process::WEXITED)

# status.pid should equal pid1 since it exits first
p status
