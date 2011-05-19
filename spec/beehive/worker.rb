require File.expand_path('../../helper', __FILE__)

describe('Beehive::Worker') do
  it('Create a new instance of Beehive::Worker') do
    worker = Beehive::Worker.new

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
    client = Beehive::Client.new
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

end
