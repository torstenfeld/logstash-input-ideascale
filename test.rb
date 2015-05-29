require 'net/http'
require 'yaml'


class IdeaScale
  def initialize
    get_config
  end

  private
  def get_config
    config = YAML.load_file('config.yml')
    @config = config
    puts config.inspect
    @url = config['url']
    # @url = 'https://www.feldstudie.net'
    @token = config['token']
    # puts "#{@url}"
  end

  public
  def get_ideas
    header = {
        'api_token' => @token
    }
    uri = URI(@url)
    http = Net::HTTP.new(uri.host, 443)
    http.use_ssl = true
    path = uri.path.empty? ? "/" : uri.path

    body = http.get(path, header).body
    puts body
  end
end

is = IdeaScale.new
is.get_ideas


