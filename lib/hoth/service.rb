module Hoth
  class Service
    attr_accessor :name, :endpoint, :params, :return_value
    
    def initialize(name, args = {})
      @name             = name
      endpoint          = args[:endpoint]
      deployment_module = ServiceDeployment.module(endpoint)
      @endpoint         = deployment_module[Services.env].endpoint
      @params           = args[:params]
      @return_value     = args[:returns]
    end
    
    def transport
      @transport ||= "hoth/transport/#{endpoint.transport_type}_transport".camelize.constantize.new(self)
    end
    
    def service_impl_class
      @service_impl_class_name ||= "#{self.name.to_s.camelize}Impl"
      # in Rails development environment we cannot cache the class constant, because it gets unloaded, so you get 
      # an "A copy of xxxImpl has been removed from the module tree but is still active!" error from ActiveSupport dependency mechanism
      # TODO: Try to solve this problem
      # TODO: get rid of these Rails dependencies
      @service_impl_class_name.constantize
    end
    
    if defined? ::NewRelic
      include NewRelic::Agent::Instrumentation::ControllerInstrumentation

      def execute(*args)
        NewRelic::Agent::ShimAgent === NewRelic::Agent.instance and NewRelic::Agent.manual_start
        local = self.endpoint.is_local?(name)
        perform_action_with_newrelic_trace :class_name => @service_impl_class_name, :name => "execute#{' (local)' if local}", :category => 'Custom' do
          if local
            service_impl_class.execute(*args)
          else
            transport.call_remote_with(*args)
          end
        end
      end
    else
      def execute(*args)
        if self.endpoint.is_local?(name)
          service_impl_class.execute(*args)
        else
          transport.call_remote_with(*args)
        end
      end
    end
  end
end
