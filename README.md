# Beehive

Beehive is a super lightweight queue system that uses Redis as it's storage engine.
Beehive was created because I got fed up with Resque's large memory footprint and not
being able to find a decent alternative that wasn't broken. 

## Requirements

* Redis and the redis Gem - install with `gem install redis`
* The JSON gem - install with `gem install json`
* Ruby >= 1.9.2

## Installation & Usage

Installing Beehive is done as following:

    $ gem install beehive

Once it's installed you can use it as following:

    require 'beehive'

    client = Beehive::Client.new
    client.queue('email.send', :to => 'info@yorickpeterse.com', :subject => 'Hello, world!')

Your worker would look like the following:

    require 'beehive'

    Beehive.job('email.send') do |params|
      # Do something with Net::IMAP, Net::POP, etc
    end

    worker = Beehive::Worker.new({}, {:jobs => ['email.send']})
    worker.work

For more examples see the "example" directory.

## License

Beehive is licensed under the MIT license, a copy of this license can be found in the file
"license.txt".
