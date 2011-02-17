require 'spec_helper'

describe Exception do
  
  it "should be able to create json with empty backtrace" do
    e = Exception.new "message"
    e2 = JSON(e.to_json)
    e3 = JSON("{\"#{JSON.create_id}\":\"Exception\",\"m\":\"message\",\"b\":null}")
    [ e.message, e.backtrace ].should == [ e2.message, e.backtrace ]
    [ e2.message, e2.backtrace ].should == [ e3.message, e3.backtrace ]
    [ e3.message, e3.backtrace ].should == [ e.message, e.backtrace ]
  end
  
  it "should be able to create json with backtrace" do
    e = Exception.new "message"
    e.set_backtrace ["back", "trace"]
    e2 = JSON(e.to_json)
    e3 = JSON("{\"#{JSON.create_id}\":\"Exception\",\"m\":\"message\",\"b\":[\"back\",\"trace\"]}") 
    [ e.message, e.backtrace ].should == [ e2.message, e.backtrace ]
    [ e2.message, e2.backtrace ].should == [ e3.message, e3.backtrace ]
    [ e3.message, e3.backtrace ].should == [ e.message, e.backtrace ]
  end
  
  it "should be able to deserialize exception from json" do
    e = Exception.new "message"
    e.set_backtrace ["back", "trace"]
    deserialized = JSON(e.to_json)
    deserialized.message.should == "message"
    deserialized.backtrace.should == ["back", "trace"]
  end
  
  it "should be able to serialize and deserialize descendants of the Exception class" do
    class ExceptionSpec <  Exception; end
    e = ExceptionSpec.new "message"
    e.set_backtrace ["back", "trace"]
    deserialized = JSON(e.to_json)
    deserialized.message.should == "message"
    deserialized.backtrace.should == ["back", "trace"]
    deserialized.should be_a ExceptionSpec
  end
  
end
