require 'dnssd'
require 'net/http'
require_relative 'dns_discovery'

module Goliath
  module Plugin
    class RegisterDnssd
      def initialize(address, port, config, status, logger)
        @config = config
        @logger = logger
        @port = port

        @@dnssd = nil
      end

      def run
        return if @config["discovery"]

        @polling_thread = Thread.new do
          begin
            loop do
              if can_really_proxy? && !dnssd_running?
                @logger.info "Registering DNSSD service on port: #{@port}"
                @@dnssd = DnsDiscovery.new.register(@port)
              elsif dnssd_running?
                @logger.warn "Stopping DNSSD service"
                @@dnssd.stop
              end

              sleep(10)
            end
          rescue => e
            @logger.fatal "Polling Thread died due to: #{e.class.name}: #{e.message}"
          end
        end
      end

      private

      def can_really_proxy?
        Timeout::timeout(5) do
          test_url = "#{@config["base_url"]}#{@config["test_path"]}"
          @logger.debug "Testing proxy connection by hitting: #{test_url}"
          Net::HTTP.get_response URI(test_url)
        end

        @logger.debug "Can proxy"
        true
      rescue => e
        @logger.warn "Cannot proxy because: #{e.class.name}: #{e.message}"
        false
      end

      def dnssd_running?
        state = @@dnssd && !@@dnssd.stopped?
        @logger.debug  "DNSSD state: #{state.to_s}"
        state
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
