# encoding: utf-8
require 'spec/inputs/ideascale_spec'
require 'logstash/inputs/base'
require 'logstash/namespace'
require 'stud/interval'
require 'net/http'
require 'socket' # for Socket.gethostname

# Collects ideas for a specific community from IdeaScale via RestAPI

class LogStash::Inputs::Ideascale < LogStash::Inputs::Base
  config_name 'ideascale'

  # If undefined, Logstash will complain, even if codec is unused.
  default :codec, 'plain'

  # The message string to use in the event.
  config :message, :validate => :string, :default => 'Hello World!'

  # the url of the API endpoint
  config :url, :validate => :url, :required => 'true'

  # the community id to get the data from
  config :communityId, :validate => :string, :required => 'true'

  # api token which is used for authentication
  config :apitoken, :validate => :string, :required => 'true'

  # max number of items fetched per request
  config :requestsize, :validate => :integer, :default => 0

  # Set how frequently messages should be sent. The default, `3600`, means new items are get every hour.
  config :interval, :validate => :number, :default => 3600

  public
  def register
    @host = Socket.gethostname
  end # def register

  def run(queue)
    Stud.interval(@interval) do
      event = LogStash::Event.new('message' => @message, 'host' => @host)
      decorate(event)
      queue << event
    end # loop
  end # def run

end # class LogStash::Inputs::Ideascale