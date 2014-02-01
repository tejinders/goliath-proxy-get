require 'goliath'
require 'em-synchrony/em-http'
require 'json'
require_relative 'plugins/dnssd.rb'

class Proxy < Goliath::API
  use Goliath::Rack::DefaultMimeType
  use Goliath::Rack::Params
  use Goliath::Rack::Validation::RequestMethod, %w(GET) 
  use Goliath::Rack::Heartbeat
  use Goliath::Rack::BarrierAroundwareFactory, Goliath::Rack::Dnssd
  plugin Goliath::Plugin::RegisterDnssd

  def options_parser(opts, options)
    options[:discovery] = false
    opts.on('-y', '--discovery', 'dnssd based discovery') { options[:discovery] = true}
    opts.on('--proxy-user USER', 'proxy user') { |user| options[:proxy_user] = user}
    opts.on('--proxy-pass PASSWORD', 'proxy password') { |pass| options[:proxy_pass] = pass}
    opts.on('--base-url BASE_URL', 'proxy base url (e.g. http://www.google.com)') { |pass| options[:base_url] = pass}
  end

  def response(env)
    url = "#{env.base_url}#{env['REQUEST_PATH']}?#{env['QUERY_STRING']}"
    logger.debug "Proxying #{url}"
    http = EM::HttpRequest.new(url).get head: headers(env)
    [http.response_header.status, http.response_header, http.response]
  end

  private
  def headers(env)
    if env.proxy_user
      return { authorization: [env.proxy_user, env.proxy_pass] }
    end
    {}
  end
end

