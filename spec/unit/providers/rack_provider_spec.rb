require File.expand_path(File.join(File.dirname(__FILE__), '../../',  'spec_helper'))

require File.expand_path(File.join(File.dirname(__FILE__), '../../../',  'lib', 'hoth', 'providers', 'rack_provider'))

describe Hoth::Providers::RackProvider do
  it "should be able to handle exceptions" do
    app = stub("ApplicationStub").as_null_object
    middleware = Hoth::Providers::RackProvider.new app
    env = {"PATH_INFO" => "/execute/some_method", "other_params" => nil}
    Rack::Request.should_receive(:new).and_raise(RuntimeError)
    
    rack_response = middleware.call env
    rack_response.first.should == 500 #status code
    rack_response.last.should match('json_class')
    rack_response.last.should match('RuntimeError')
  end
  
  it "should decode params" do
    app = stub("ApplicationStub").as_null_object
    middleware = Hoth::Providers::RackProvider.new app
    params = "json_encoded_params"
    Hoth::Transport::HttpTransport.should_receive(:decode_params).with(params).and_return(decoded_params = mock("DecodedParamsMock"))
    env = {"PATH_INFO" => "/execute/", "params" => {"params" => params, "name" => "some_service_name"}}
    Rack::Request.should_receive(:new).with(env).and_return(request_mock = mock("RequestMock"))
    request_mock.should_receive(:params).twice.and_return(params_mock = mock("ParamsMock"))
    params_mock.should_receive(:[]).with("params").and_return(params)
    params_mock.should_receive(:[]).with("name").and_return("some_service_name")
    middleware.call env
  end
end