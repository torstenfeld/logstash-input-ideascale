require 'net/http'
require 'yaml'
require 'json'


class IdeaScale
  def initialize
    get_config
  end

  private
  def get_config
    config = YAML.load_file('config.yml')
    @config = config
    @url = config['url']
    @token = config['token']
  end

  public
  def get_ideas
    header = {
        'api_token' => @token
    }
    uri = URI(@url)
    http = Net::HTTP.new(uri.host, 443)
    http.use_ssl = true
    puts uri.path
    path = uri.path

    # exit 123

    response = http.request_get(path + '/0/1', header)
    # TODO: add check for 'pager_total_count' exists
    max_items = response['pager_total_count']
    puts max_items

    # TODO: add logic for max items per request
    # TODO: add multi-threading for faster requests
    response = http.request_get(path + '/0/' + max_items.to_s, header)

    body = response.body
    JSON.parse(body)
  end
end

is = IdeaScale.new
ideas = is.get_ideas

# ideas.each { |idea| puts idea['id'] }
puts ideas.size


