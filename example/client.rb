require File.expand_path('../../lib/beehive', __FILE__)

# Initialize the client
client = Beehive::Client.new

# Send the job to the queue
client.queue('example', :amount => 2)
