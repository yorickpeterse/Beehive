module Beehive
  ##
  # The Worker class is used to retrieve and process jobs (in the background). Whenever a
  # job is received the worker will fork itself and execute the job in that process. This
  # is useful because any errors won't crash the worker itself plus it will reduce the
  # memory usage as once Ruby allocates memory to a process it's never released unless
  # that process exits.
  #
  # @author Yorick Peterse
  # @since  0.1
  #
  class Worker
    ##
    # Hash containing the default worker options.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    Options = {
      :logger    => ::Logger.new(STDOUT),
      :daemonize => false,
      :jobs      => [],
      :wait      => 5,
      :log_level => Logger::WARN,
      :pid       => File.join(Dir.pwd, 'worker.pid')
    }

    # Instance of Beehive::Client, used for communicating with the Redis server
    attr_reader :connection

    # Hash containing all the custom configuration options
    attr_accessor :options

    ##
    # Creates a new instance of the class, sets all the options and connects to the Redis
    # database.
    #
    # @example
    #  worker = Beehive::Worker.new({}, {:jobs => ['video'], :wait => 2})
    #
    # @author Yorick Peterse
    # @since  0.1
    # @param  [Hash] redis_options Hash containing all the options to use for Redis. See
    # Redis#new for more information.
    # @param  [Hash] worker_options Hash containing worker specific options.
    # @option worker_options :logger The logger that should be used, has to be compatible
    # with Logger of the standard library.
    # @option worker_options :daemonize Tells the worker to run in the background.
    # @option worker_options :jobs An array of jobs the current worker has to process.
    # @option worker_options :wait The amount of seconds to wait after each iteration,
    # reduces CPU and network usage.
    # @option worker_options :log_level The log even to use for the :logger option, set to
    # Logger::WARN by default.
    # @option worker_options :pid Path to the location of the PID file for the worker.
    #
    def initialize(redis_options = {}, worker_options = {})
      @connection             = ::Beehive::Client.new(redis_options)
      @options                = Options.merge(worker_options)
      @options[:logger].level = @options[:log_level]
      @shutdown               = false

      # Check if the given jobs are valid
      @options[:jobs].each do |job|
        if !::Beehive::Jobs.key?(job)
          raise("The job \"#{job}\" is invalid as it could not be found in Beehive::Jobs")
        end
      end

      trap_signals
    end

    ##
    # Waits for available jobs and execute a job whenever one is available.
    #
    # @example
    #  worker = Beehive::Worker.new
    #  worker.work
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    def work
      # Daemonize the process?
      if @options[:daemonize] === true
        Process.daemon(true)
      end

      @worker_pid = Process.pid

      @options[:logger].info("Starting main worker, PID: #{@worker_pid}")
      write_pid

      loop do
        if @shutdown === true
          @options[:logger].info('The party has ended, time to shut down')
          @connection.disconnect
          File.unlink(@options[:pid])
          exit
        end

        # Reset the child PID
        @child_pid = nil

        # Check if there are any jobs available
        @options[:jobs].each do |job|
          params = @connection.get(job)

          if params
            @options[:logger].info(
              "Received the job \"#{job}\" with the following data: #{params.inspect}"
            )

            # Fork the process and run the job
            @child_pid = Process.fork do
              @options[:logger].info('Process forked, executing job')

              begin
                ::Beehive::Jobs[job].call(params, @options[:logger])

                @options[:logger].info('Job successfully processed')
                exit
              rescue => e
                @options[:logger].error("Failed to execute the job: #{e.inspect}")
              end
            end

            # Wait for the job to finish. This prevents this worker from spawning a worker
            # for each job it has to process (which could result in hundreds of processes
            # being spawned.
            Process.waitpid(@child_pid)
          end
        end

        # Did the PID change for some reason?
        if Process.pid != @worker_pid
          @worker_pid = Process.pid
          write_pid
        end

        # Reduces CPU load and network traffic
        sleep(@options[:wait])
      end
    end

    private

    ##
    # Registers all the signals that trigger a shutdown.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    def trap_signals
      # Shut down gracefully
      ['TERM', 'INT'].each do |signal|
        Signal.trap(signal) { @shutdown = true }
      end

      # QUIT will trigger the setup to quit immediately
      Signal.trap('QUIT') do
        @shutdown = true

        # No point in killing a child process if it isn't there in the first place
        if !@child_pid.nil?
          @options[:logger].info("Shutting down the worker with PID #{@child_pid}")
          Process.kill('INT', @child_pid)
        end
      end
    end

    ##
    # Writes the given PID to the PID file.
    #
    # @author Yorick Peterse
    # @since  0.1.2
    #
    def write_pid
      File.open(@options[:pid], 'w') do |handle|
        handle.write(@worker_pid)
      end
    end
  end # Worker
end # Beehive
