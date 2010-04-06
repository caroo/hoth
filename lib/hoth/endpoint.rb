module Hoth
  class Endpoint
    attr_accessor :host, :port, :transport_type, :endpoint_name

    def initialize(attributes)
      attributes.key?(:endpoint) and @endpoint_name  = attributes[:endpoint].to_sym
      @host           = attributes[:host]
      @port           = attributes[:port]
      @transport_type = attributes[:transport_type]
    end

    def ==(endpoint)
      self.host == endpoint.host &&
        self.port == endpoint.port
    end

    def to_url
      "http://#{@host}:#{@port}/execute"
    end
 
    def is_local?(service_name = nil)
      env_endpoint = ENV["ENDPOINT"] and env_endpoint = env_endpoint.to_sym
      # TODO the following could be optimized/should be moved to another place
      if env_endpoint
        env_endpoint == endpoint_name ? true : false # make dynamic
      elsif service_name
        begin
          "#{service_name.to_s.classify}Impl".constantize
          true
        rescue NameError
          false
        end
      else
        false
      end
    end
  end
end
