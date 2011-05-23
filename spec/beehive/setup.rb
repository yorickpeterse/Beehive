require File.expand_path('../../helper', __FILE__)
require 'rake'

describe('Check if the environment is capable of running the tests') do

  it('Ruby version is 1.9 or newer') do
    if RUBY_VERSION.to_f < 1.9
      fail("You need at least Ruby 1.9 to run these tests")
    end
  end

  it('Check if Redis is running') do
    # Dirty way of checking to see if Redis is running
    output  = `ps a | grep redis-server`
    matches = output.match(/[0-9]+\s+redis-server/)

    if matches.nil?
      fail("You need to start Redis in order to run these tests")
    end
  end

  it('Check the default Redis settings in case the previous test missed them') do
    client = Redis.new

    begin
      client.client.connect
    # Default settings didn't work, check if the ENV variable REDIS is set
    rescue
      if !ENV.key?('REDIS')
        message = "Failed to connect to the default Redis host and the REDIS " +
        "environment variable wasn't set."

        fail(message)
      end
    end
  end

end
