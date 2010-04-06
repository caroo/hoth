require 'json'
require 'net/http'

module Hoth
  module Transport
    class JsonTransport < HothTransport     
      def call_remote_with(*args)
        uri = URI.parse(self.endpoint.to_url)
        params = { 'name' => self.name.to_s, 'params' => args.to_json }
        Hoth::Logger.info "Connecting to '#{uri}' with #{params.inspect}."
        response = Net::HTTP.post_form(uri, params)
        case response
        when Net::HTTPSuccess
          Hoth::Logger.debug "response.body: #{response.body}"
          JSON(response.body)["result"]
        when Net::HTTPServerError
          begin
            raise JSON(response.body)["error"]
          rescue JSON::ParserError => jpe
            raise TransportError.wrap(jpe)
          end
        when Net::HTTPRedirection, Net::HTTPClientError, Net::HTTPInformation, Net::HTTPUnknownResponse
          #TODO Handle redirects(3xx) and http errors(4xx), http information(1xx), unknown responses(xxx)
          raise NotImplementedError, "HTTP code: #{response.code}, message: #{response.message}"
        end       
      end

      def self.decode_params(params)
        Hoth::Logger.debug "Params we gonna send: #{params.inspect}"
        JSON.parse(params)
      rescue JSON::ParserError => jpe
        raise TransportError.wrap(jpe)
      end
      
    end
  end
end
