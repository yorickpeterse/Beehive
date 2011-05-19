require File.expand_path('../../lib/beehive', __FILE__)

# Define the job. Due to the forking behavior the output won't be actually visible.
Beehive.job('example') do |params|
  puts "Hello, world!"
end

# Create a new instance of a worker and customize the settings a bit.
worker = Beehive::Worker.new({}, {:jobs => ['example'], :log_level => Logger::INFO})

# And start the worker
worker.work
