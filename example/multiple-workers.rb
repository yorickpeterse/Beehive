require File.expand_path('../../lib/beehive', __FILE__)

# A more "complex" job
Beehive.job('example') do |params|
  if params.key?('amount')
    amount = params['amount'].to_i
  else
    amount = 2
  end

  amount.times do |num|
    puts "Iteration: #{num}"
  end
end

# The amount of workers to start
if ARGV.empty?
  worker_amount = 5
else
  worker_amount = ARGV[0].to_i
end

# Start 5 workers
worker_amount.times do
  Process.fork do
    # Start the worker and wait for a job to do
    worker = Beehive::Worker.new({}, {:jobs => ['example'], :log_level => Logger::INFO, :daemonize => true})
    worker.work
  end
end
