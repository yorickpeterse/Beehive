require 'redis'
require 'json'
require 'logger'

require_relative('beehive/version')
require_relative('beehive/client')
require_relative('beehive/worker')

##
# Beehive is a lightweight queue system that uses Redis to store all jobs. It's inspired
# by existing systems such as Minion and Stalker. Beehive does not offer a plugin system
# or any other fancy features, it merely allows you to queue a job and have it processed
# in the background.
#
# ## Features
#
# * Uses Redis as it's storage mechanism.
# * Lightweight: workers don't waste resources on loading large amounts of libraries.
# * Easy to use
#
# Fore more information see the README file.
#
# @author Yorick Peterse
# @since  0.1
#
module Beehive
  ##
  # Hash containing all the defined jobs.
  #
  # @author Yorick Peterse
  # @since  0.1
  #
  Jobs = {}

  ##
  # Adds a new job to the list.
  #
  # @example
  #  Beehive.job('video') do |params|
  #    puts "Hello!"
  #  end
  #
  # @author Yorick Peterse
  # @since  0.1
  # @param  [String] job The name of the job.
  # @param  [Proc] block The block to call whenever the job has to be processed.
  #
  def self.job(job, &block)
    Jobs[job.to_s] = block
  end
end
