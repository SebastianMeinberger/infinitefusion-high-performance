#!/usr/bin/env ruby

# A metric provider, e.g. the mesa gallium HUD, can dump an abatrary amount of measurments into a fifo specified with --metric METRIC.
# If not already existing, the fifo will be created.
# You can specify as many metrics/fifos as you like, by simply appending more --metric METRIC2 parameters.
# This wrapper script then redirects the fifos to a ts (timestamp) instances, in order to make analysing them later easier.

require 'optparse'

spawned_processes = []
options = {}

options[:metrics] = []

OptionParser.new do |opt|
  opt.on("-m", "--metric METRIC") { |o| options[:metrics].append o }
end.parse!

# Creat the directorion for the fifos and timestamped measurments
if !Dir.exist?('Raw_Measurments')
  Dir.mkdir 'Raw_Measurments'
end
if !Dir.exist?('Timestamped_Measurments')
  Dir.mkdir 'Timestamped_Measurments'
end



options[:metrics].each do |m|
  spawned_processes.append spawn(
      # First, create a fifo, to which the metric provider can dump all measurments during runtime. Then, attach a cat to the fifo, in order to catch the first EOF that will be written to the fifo when wriing starts (for some reason). Finally, redirect fifo into timestamper
      "mkfifo 'Raw_Measurments/#{m}';
      cat < 'Raw_Measurments/#{m}';
      ts < 'Raw_Measurments/#{m}' >> 'Timestamped_Measurments/#{m}_timestamped'")
end

benchmark = spawn(ARGV[0])
spawned_processes.append benchmark
Process.waitall
