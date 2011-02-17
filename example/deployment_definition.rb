Hoth::ServiceDeployment.define do
  service_module :statistics_module do
    env :test, {
      :endpoint => Hoth::Endpoint.new(
        :host           => 'localhost',
        :port           => 9292,
        :transport_type => :json
      ),
    }

    path "services/search_service"
  end
end
