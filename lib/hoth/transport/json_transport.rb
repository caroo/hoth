require 'json'
require 'net/http'

module Hoth
  module Transport
    class JsonTransport < HothTransport 
      
      def call_remote_with(*args)
        response = Typhoeus::Request.post self.endpoint.to_url,
          :params          => { 'name' => self.name.to_s, 'params' => args.to_json },
          :headers         => {'Accept' => "application/json"},
          :follow_location => true,
          :max_redirects   => 1,
          :connect_timeout => 10_000, # 10 sec
          :timeout         => 300_000 # 300 sec

        case response.code
        when 200...300
          Hoth::Logger.debug "#{self.class}: success. response.body: #{response.body}, \n" +
            "time: #{response.time}, start_time: #{response.start_time}, name_lookup_time: #{response.name_lookup_time}, " +
            "start_transfer_time: #{response.start_transfer_time}, pretransfer_time: #{response.pretransfer_time}, " +
            "app_connect_time: #{response.app_connect_time}"
          JSON(response.body)["result"]
        when 500...600
          Hoth::Logger.debug "#{self.class}: failure. response.body: #{response.body}"
          begin
            raise JSON(response.body)["error"]
          rescue JSON::ParserError => jpe
            raise TransportError.wrap(jpe)
          end
        when 0
          raise Hoth::TransportError, "HTTP over JSON failed, curl_return_code: #{response.curl_return_code}, curl_error_message: #{response.curl_error_message}"
        else
          raise NotImplementedError, "HTTP code: #{response.code}, message: #{response.body}"
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
