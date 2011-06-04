require File.expand_path('../../helper', __FILE__)

describe('Beehive::Worker') do
  it('Create a new instance of Beehive::Worker') do
    if ENV.key?('REDIS')
      worker = Beehive::Worker.new([ENV['REDIS']])
    else
      worker = Beehive::Worker.new
    end

    worker.options[:logger].level.should === Logger::WARN
    worker.options[:jobs].size.should    === 0
  end

  it('Start a worker and queue a job') do
    path = File.expand_path('../../tmp/output', __FILE__)
    
    if File.exist?(path)
      File.unlink(path)
    end

    Beehive.job('spec') do |params|
      File.open(path, 'w') do |handle|
        handle.write('Hello, world!')
        handle.close
      end
    end

    # Queue the job
    if ENV.key?('REDIS')
      client = Beehive::Client.new([ENV['REDIS']])
    else
      client = Beehive::Client.new
    end

    client.queue('spec')

    pid = Process.fork do
      worker = Beehive::Worker.new({}, {:jobs => ['spec']})
      worker.work
    end

    # Wait for the process to end
    Process.kill('INT', pid)
    Process.waitpid(pid)

    path = File.read(path, File.size(path)).strip

    path.should === 'Hello, world!'
  end

  it('Write the PID') do
    pid_path = File.expand_path('../../tmp/worker.pid', __FILE__)

    pid = Process.fork do
      worker = Beehive::Worker.new({}, {:pid => pid_path})
      worker.work
    end

    # Give the worker some time to boot up
    sleep(1)

    # Check if the PID is correct
    pid_file        = File.read(pid_path, File.size(pid_path)).strip
    pid_file.should === pid.to_s

    # Close the connection
    Process.kill('INT', pid_file.to_i)
  end

end
