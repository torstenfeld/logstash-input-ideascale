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
    path = uri.path.empty? ? '/' : uri.path

    body = http.get(path, header).body
    JSON.parse(body)
  end
end

is = IdeaScale.new
ideas = is.get_ideas

ideas.each { |idea| puts idea['id'] }


