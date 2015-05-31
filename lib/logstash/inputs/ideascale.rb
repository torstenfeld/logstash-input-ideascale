# encoding: utf-8
# require File.absolute_path(File.join(File.dirname(__FILE__), '../../../spec/inputs/ideascale_spec'))
require 'logstash/inputs/base'
require 'logstash/namespace'


# Collects ideas for a specific community from IdeaScale via RestAPI

class LogStash::Inputs::Ideascale < LogStash::Inputs::Base
  config_name 'ideascale'

  # If undefined, Logstash will complain, even if codec is unused.
  default :codec, 'plain'

  # the url of the API endpoint
  config :baseurl, :validate => :string, :required => true

  # types of feedbacks to be fetched ['ideas', 'comments', 'votes']
  config :fbtypes, :validate => ['ideas', 'comments', 'votes'], :default => ['ideas']

  # api token which is used for authentication
  config :apitoken, :validate => :string, :required => true

  # max number of items fetched per request
  config :requestsize, :validate => :number, :default => 0

  # Set how frequently messages should be sent. The default, `3600`, means new items are get every hour.
  config :interval, :validate => :number, :default => 3600

  public
  def register
    require File.absolute_path(File.join(File.dirname(__FILE__), '../../ideascale/ideascalegetter'))
    require 'stud/interval'
    # noinspection RubyResolve
    require 'net/http'
    require 'socket' # for Socket.gethostname
    @host = Socket.gethostname
  end # def register

  public
  def run(queue)
    is = IdeaScaleGetter.new(@baseurl, @apitoken)
    Stud.interval(@interval) do
      is.run
      is.ideas.each { |idea|
        event = LogStash::Event.new(idea)
        decorate(event)
        queue << event
      }
      is.comments.each { |comment|
        event = LogStash::Event.new(comment)
        decorate(event)
        queue << event
      }
      # event = LogStash::Event.new('message' => @message, 'host' => @host)
      # decorate(event)
      # queue << event
    end # loop
  end # def run

end # class LogStash::Inputs::Ideascale