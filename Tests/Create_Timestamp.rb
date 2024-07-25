#!/usr/bin/env ruby

# A metric provider, e.g. the mesa gallium HUD, can dump an abitrary amount of measurments into a fifo specified with --metric METRIC, which is created automatically.
# You can specify as many metrics/fifos as you like by simply appending more --metric METRIC parameters.
# This wrapper script then redirects the fifos to a ts (timestamp) instance, in order to make analysing them later easier.

require 'optparse'

spawned_processes = []
options = {}
options[:metrics] = []
options[:name] = "Noname"

OptionParser.new do |opt|
  opt.on("-m", "--metric METRIC") { |o| options[:metrics].append o }
  opt.on("-n", "--name NAME") {|o| options[:name] = o}
end.parse!

# Create the directorion for the fifos and timestamped measurments
dir_raw = 'Raw_Measurments'.freeze
if !Dir.exist?(dir_raw)
  Dir.mkdir dir_raw
end
dir_timestamped = ('Timestamped_Measurments_' + options[:name]).freeze
if !Dir.exist?(dir_timestamped)
  Dir.mkdir (dir_timestamped)
end


# First, create a fifo, to which the metric provider can dump all measurments during runtime.
options[:metrics].each do |m|
  fifo = dir_raw + "/" + m
  # Delete the old fifo, in case it still contains old data
  if File.exist? fifo
    File.delete fifo
  end
  File.mkfifo(fifo)
end

# For every metric, spawn a process that redirects everything from its fifo to a timestamper
options[:metrics].each do |m|
  timestamper = 
    # First, send the fifo through tail, otherwise ts will close in case the fifo is still empty
    "tail -n +1 -f '" + dir_raw + "/#{m}'"  +
    # Then pipe to ts, to create the actual timestamps
    "| ts -s %.S,>> '" + dir_timestamped + "/#{m}'" 
  spawned_processes.append spawn(timestamper)
end

# Concatinate rest to get the path to the test executable, together with its arguments
test_executable = ARGV * " "
benchmark = spawn(test_executable)
spawned_processes.append benchmark
Process.waitall
