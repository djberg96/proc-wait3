#######################################################################
# example_pause.rb
#
# Simple demonstration of the Process.pause method. You can use
# the 'rake example_pause' task to run this program.
#
# Modify as you see fit.
#######################################################################
require 'rbconfig'
require 'proc/wait3'

puts "Pausing.  Hit Ctrl-C to continue."

if Config::CONFIG['host_os'] =~ /linux/i
   Process.pause(2)
else
   Process.pause("INT")
end

puts "Hey, thanks for hitting Ctrl-C.  Continuing..."
puts "Done"
