require File.expand_path('../../helper', __FILE__)

describe('Beehive::Client') do

  before(:all) do
    if ENV.key?('REDIS')
      @client = Beehive::Client.new([ENV['REDIS']])
    else
      @client = Beehive::Client.new
    end
  end

  it('Queue a new job') do
    @client.queue('video', :title => 'hello')

    job = @client.get('video')

    job['title'].should === 'hello'
  end

  after(:all) do
    @client = nil
  end

end
