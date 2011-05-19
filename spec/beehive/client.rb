require File.expand_path('../../helper', __FILE__)

describe('Beehive::Client') do

  it('Queue a new job') do
    client = Beehive::Client.new
    client.queue('video', :title => 'hello')
  end

  it('Get the latest job') do
    client = Beehive::Client.new
    job    = client.get('video')

    job['title'].should === 'hello'
  end

end
