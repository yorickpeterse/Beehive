require File.expand_path('../lib/beehive', __FILE__)
require 'rake/testtask'

# Load all the tasks
Dir.glob(File.expand_path("../task/*.rake", __FILE__)).each do |f|
  import(f)
end

# Set the tests so they can be run with $ rake test
Rake::TestTask.new do |t|
  t.test_files = Dir.glob(File.expand_path('../spec/beehive/**/*.rb', __FILE__))
  t.verbose    = true
end
