require 'dnssd'
require_relative 'dns_discovery'

module Goliath
  module Plugin
    class RegisterDnssd
      def initialize(address, port, config, status, logger)
        @@dnssd = DnsDiscovery.new.register(port) unless config["discovery"]
      end

      def run
      end
    end
  end
  module Rack
    class Dnssd
      include Goliath::Rack::BarrierAroundware

      def pre_process
        if env.discovery
          new_base_url = DnsDiscovery.new.base_url
          p "Remapping to #{new_base_url}"
          env['base_url'] = new_base_url unless new_base_url.nil?
        end
        Goliath::Connection::AsyncResponse
      end
    end
  end
end
