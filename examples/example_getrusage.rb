########################################################################
# example_getrusage.rb
#
# Simple demonstration of the Process.getrusage method. You can run
# this code via the 'rake example_getrusage' task.
#
# Modify as you see fit.
########################################################################
require 'proc/wait3'
require 'pp'

# Show resource stats for this process for 30 seconds
10.times do
   pp Process.getrusage
   puts "=" * 50
   sleep 3 
end
