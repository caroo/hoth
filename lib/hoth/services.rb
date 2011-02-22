module Hoth
  class Services
    def self.define(&block)
      (@definition || Definition.new).instance_eval(&block)
    end
    
    def self.env
      (ENV["RAILS_ENV"] || 'test').to_sym
    end

    def self.define_service_method(service, method_name)
      metaclass = class << self; self; end
      metaclass.__send__ :define_method, method_name do |*args|
        service.execute(*args)
      end
    end

    class << self
      def method_missing(meth, *args, &blk)
        if _service = ServiceRegistry.locate_service(meth)
          Hoth::Services.define_service_method(_service, meth)
          Hoth::Services.__send__(meth, *args)
        else
          super
        end
      end
    end
    
  end
end
