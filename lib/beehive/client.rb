module Beehive
  ##
  # The client class that can be used to add and manage jobs in the queue.
  #
  # @author Yorick Peterse
  # @since  0.1
  #
  class Client
    # Instance of the class "Redis"
    attr_reader :connection

    ##
    # Creates a new instance of the client and sends the specified options to Redis.
    #
    # @author Yorick Peterse
    # @since  0.1
    # @param  [Hash] options A hash containing options to use for Redis. See 
    # Redis#initialize for more information.
    #
    def initialize(options = {})
      @connection = ::Redis.new(options)
    end

    ##
    # Queues a given job in the storage.
    #
    # @example
    #  client = Beehive::Client.new
    #  client.queue('video', :title => 'Hello world')
    #
    # @author Yorick Peterse
    # @since  0.1
    # @param  [String] job The name of the job to queue.
    # @param  [Hash] params The parameters to send to the job.
    #
    def queue(job, params = {})
      job    = "beehive.jobs.#{job}"
      params = JSON.dump(params)

      @connection.rpush(job, params)
    end

    ##
    # Retrieves the last job and removes it from the storage.
    #
    # @author Yorick Peterse
    # @since  0.1
    # @param  [String] job The name of the type of job to retrieve.
    # @return [Array]
    #
    def get(job)
      job = "beehive.jobs.#{job}"
      job = @connection.lpop(job)
      
      if !job.nil?
        return JSON.load(job)
      end
    end

    ##
    # Closes the Redis connection.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    def disconnect
      @connection.quit
    end
  end # Client
end # Beehive
