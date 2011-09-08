require 'spec_helper'

describe Hoth::DeploymentModule do
  
  it "should have a name" do
    deployment_module = Hoth::DeploymentModule.new :name => :my_service_module
    deployment_module.name.should equal(:my_service_module)
  end
  
  it "should have an environment" do
    deployment_module = Hoth::DeploymentModule.new
    
    env_specific_options = {:endpoint => "Endpoint"}
    deployment_module.env :test, env_specific_options
    deployment_module[:test].should be_a(Hoth::DeploymentModule::Environment)

    deployment_module.env :staging, :production, env_specific_options
    deployment_module[:staging].should be_a(Hoth::DeploymentModule::Environment)
    deployment_module[:production].should be_a(Hoth::DeploymentModule::Environment)
    
    [:test, :staging, :production].each do |environment|
      deployment_module[environment].endpoint.should == "Endpoint"
    end
  end
  
  it "should have a path pointing to the service root" do
    deployment_module = Hoth::DeploymentModule.new
    deployment_module.path "services_dir/my_service"
    deployment_module.path.should == "services_dir/my_service"
  end

  describe Hoth::DeploymentModule::Environment do
    it "should have an endpoint" do
      endpoint_mock = mock("Hoth::Endpoint").as_null_object
      
      env = Hoth::DeploymentModule::Environment.new(:endpoint => endpoint_mock)
      env.endpoint.should equal(endpoint_mock)
    end
  end
  
end
