require 'goliath'
require 'em-synchrony/em-http'
require 'json'

class Proxy < Goliath::API
  use Goliath::Rack::DefaultMimeType
  use Goliath::Rack::Params
  use Goliath::Rack::Validation::RequestMethod, %w(GET) 
  use Goliath::Rack::Heartbeat

  HEADERS = { authorization: [ENV["RELAY_USER"], ENV["RELAY_PASS"]] }

  BASE_URL = ENV["RELAY_SERVER"] || "localhost"

  def response(env)
    url = "#{BASE_URL}#{env['REQUEST_PATH']}?#{env['QUERY_STRING']}"
    logger.debug "Proxying #{url}"
    http = EM::HttpRequest.new(url).get head: HEADERS
    [http.response_header.status, http.response_header, http.response]
  end
end
