require 'json'
require 'net/http'
module Hoth
  module Transport
    class JsonTransport < HothTransport
      CONNECTION_ERRORS = [
        Timeout::Error,
        Errno::EINVAL,
        Errno::ECONNRESET,
        EOFError,
        Net::HTTPBadResponse,
        Net::HTTPHeaderSyntaxError,
        Net::ProtocolError,
        Errno::ECONNREFUSED,
        SocketError
      ]

      ##
      # The usual Net::HTTP.post_form does not respect the read_timeout setting,
      # so this method just do the same and sets the timeout value
      #
      def post_form(url, params)
        request = Net::HTTP::Post.new(url.path)
        request.form_data = params
        req.basic_auth url.user, url.password if url.user
        http = Net::HTTP.new(url.host, url.port)
        if timeout = Hoth::Config.timeout
          http.read_timeout = timeout
        end
        http.start do |started|
          started.request(request)
        end
      end

      def call_remote_with(*args)
        uri = URI.parse(self.endpoint.to_url)
        params = { 'name' => self.name.to_s, 'params' => args.to_json }
        Hoth::Logger.info "Connecting to '#{uri}' with #{params.inspect}."

        response = post_form(uri, params)
        case response
        when Net::HTTPSuccess
          begin
            JSON(response.body)["result"]
          rescue JSON::ParserError => e
            unless @retried
              headers = response.header.to_enum.inject({}) { |h, (k, v)| h[k] = v ; h }
              Hoth::Logger.warn("HTTP body not complete body: #{response.body}, headers: #{headers}")
              call_again(*args)
            else
              raise TransportError.wrap(e)
            end
          end
        when Net::HTTPServerError
          Hoth::Logger.debug "response.body: #{response.body}"
          begin
            raise JSON(response.body)["error"]
          rescue JSON::ParserError => jpe
            raise TransportError.wrap(jpe)
          end
        when Net::HTTPRedirection, Net::HTTPClientError, Net::HTTPInformation, Net::HTTPUnknownResponse
          #TODO Handle redirects(3xx) and http errors(4xx), http information(1xx), unknown responses(xxx)
          raise NotImplementedError, "HTTP code: #{response.code}, message: #{response.message}"
        end
      rescue *CONNECTION_ERRORS => e
        Hoth::Logger.error "Connecting to '#{uri}' with #{params.inspect} failed with #{e.class}: #{([e] + e.backtrace) * "\n"}"
        raise ConnectionError.wrap(e)
      end

      def self.decode_params(params)
        Hoth::Logger.debug "Params we gonna send: #{params.inspect}"
        JSON.parse(params)
      rescue JSON::ParserError => jpe
        raise TransportError.wrap(jpe)
      end

      private

      def call_again(*args)
        @retried = true
        call_remote_with(*args)
      ensure
        @retried = false
      end
    end
  end
end
