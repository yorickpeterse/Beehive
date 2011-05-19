require File.expand_path('../lib/beehive/version', __FILE__)

# Get all the files from the manifest
manifest = File.open './MANIFEST', 'r'
manifest = manifest.read.strip
manifest = manifest.split "\n"

Gem::Specification.new do |s|
  s.name        = 'beehive'
  s.version     = Beehive::Version
  s.date        = '20-05-2011'
  s.authors     = ['Yorick Peterse']
  s.email       = 'info@yorickpeterse.com'
  s.summary     = 'Beehive is a lightweight queue system that uses Redis.'
  s.homepage    = 'https://github.com/yorickpeterse/beehive/'
  s.description = 'Beehive is a lightweight queue system that uses Redis.'
  s.files       = manifest
  s.has_rdoc    = 'yard'
  #s.executables = ['']
  
  # The following gems are always required  
  s.add_dependency('redis', ['>= 2.2.0'])

  # The following gems are only required when developing beehive itself
  s.add_development_dependency('rake' , ['>= 0.8.7'])
  s.add_development_dependency('rspec', ['>= 2.6.0'])
end