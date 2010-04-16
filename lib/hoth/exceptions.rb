module Hoth
  class HothException < StandardError
    attr_reader :original

    attr_accessor :source_endpoint

    def self.wrap(original)
      wrapped = new("#{original.class} says: #{original.message}")
      wrapped.set_backtrace original.backtrace
      wrapped.instance_variable_set :@original, original
      wrapped
    end

    def self.json_create(object)
      result = new(object['m'])
      result.set_backtrace object['b']
      result.source_endpoint = object['s']
      result
    end

    def to_json(*args)
      {
        JSON.create_id => self.class.name,
        'm'   => message,
        'b'   => backtrace,
        's'   => source_endpoint,
      }.to_json(*args)
    end
  end

  class ServiceNotAvailable < HothException; end
  class TransportError < ServiceNotAvailable; end
  class ConnectionError < ServiceNotAvailable; end
end