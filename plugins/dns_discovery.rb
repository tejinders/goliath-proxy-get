class DnsDiscovery
  DISCOVERY_NAME = ENV['SERVICE_TYPE'] || '_http._tcp'
  HOST_FILTER_PATTERN = ENV['HOST_FILTER_PATTERN'] || '.*'

  def initialize
    @device_host = nil
  end

  def base_url
    p "Searching #{DISCOVERY_NAME} services"
    DNSSD.browse!(DISCOVERY_NAME, 'local') { |r|
      next unless r.name.match /^#{HOST_FILTER_PATTERN}/
      resolve(r)
      break
    }
    "http://#{@device_host}" unless @device_host.nil?
  end

  def register(port)
    p "Registering #{DISCOVERY_NAME} on #{port}"
    DNSSD.register! 'dnssd', DISCOVERY_NAME, 'local', port
  end

  private
  def resolve(r)
    p "Resolving #{r.name}"
    DNSSD.resolve!(r) { |a|
      @device_host = get_device_addr(a.target, a.port)
      break
    }
  end

  def get_device_addr(target, port)
    get_device_host(target) + ":" + port.to_s
  end

  def get_device_host(target)
    info = Socket.getaddrinfo(target, nil, Socket::AF_INET)
    info[0][2]
  rescue SocketError
    target
  end
end

