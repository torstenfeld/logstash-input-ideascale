# noinspection RubyResolve
require 'net/http'
# noinspection RubyResolve
require 'yaml'
# noinspection RubyResolve
require 'json'
require 'pp'


class IdeaScaleGetter
  def initialize(baseurl, token)
    @baseurl = baseurl
    @token = token
    # get_config
  end

  private
  def get_config
    config = YAML.load_file('config.yml')
    @config = config
    @baseurl = config['baseurl']
    @token = config['token']
  end

  public
  def run
    get_campaigns
    # puts @campaigns.inspect
    get_ideas
    puts JSON.pretty_generate(@ideas)
    nil
  end # def run

  private
  def get_campaigns
    header = {
        'api_token' => @token
    }
    uri = URI(@baseurl + '/campaigns')
    http = Net::HTTP.new(uri.host, 443)
    http.use_ssl = true
    puts uri

    response = http.request_get(uri.path, header)

    body = response.body
    result = JSON.parse(body)

    # create a new array with hashes of renamed keys
    campaigns_new = []
    result.each { |campaign|
      campaign_new = Hash.new
      campaign.each { |key, value|
        campaign_new['cam_' + key.to_s] = value
      }
      campaigns_new << campaign_new
    }

    @campaigns = campaigns_new
  end # get_campaigns

  private
  def get_ideas
    header = {
        'api_token' => @token
    }
    uri = URI(@baseurl + '/ideas')
    # TODO: make ssl optional (create config param in ideascale.rb as well)
    http = Net::HTTP.new(uri.host, 443)
    http.use_ssl = true
    puts uri.path

    # exit 123

    response = http.request_get(uri.path + '/0/1', header)
    # TODO: add check for 'pager_total_count' exists
    max_items = response['pager_total_count']
    puts max_items

    # TODO: add logic for max items per request
    # TODO: add multi-threading for faster requests
    response = http.request_get(uri.path + '/0/' + 2.to_s, header)
    # response = http.request_get(uri.path + '/0/' + max_items.to_s, header)

    body = response.body
    result = JSON.parse(body)

    # create a new array with hashes of renamed keys
    ideas_new = []
    result.each { |idea|
      idea_new = Hash.new
      idea.each { |key, value|
        if key == 'authorInfo'
          # flatten the author info
          value.each { |a_k, a_v|
            idea_new['author_' + a_k.to_s] = a_v
          }
        elsif key == 'locationInfo'
          # extract just the ip from the location info to use geolocation detection of logstash
          idea_new['ip'] = value['ip']
        else
          idea_new['idea_' + key.to_s] = value
        end
      }

      # add all information of matching campaign to idea
      campaign = @campaigns.find { |h| h['cam_id'] == idea_new['idea_campaignId'] }
      idea_new = idea_new.merge(campaign)
      ideas_new << idea_new
    }

    @ideas = ideas_new
  end # def get_ideas
end # class IdeaScale

