describe "AFMotion::ClientDSL" do
  before do
    @client = AFHTTPClient.clientWithBaseURL("http://url".to_url)
    @dsl = AFMotion::ClientDSL.new(@client)
  end

  describe "#header" do
    it "should set header" do
      @dsl.header "Accept", "application/json"
      @client.defaultValueForHeader("Accept").should == "application/json"
    end
  end

  describe "#authorization" do
    it "should set authorization" do
      @dsl.authorization username: "clay", password: "test"
      @client.defaultValueForHeader("Authorization").nil?.should == false
    end
  end

  describe "#operation" do
    it "should set operation if provided type" do
      @dsl.operation AFJSONRequestOperation
      @client.registeredHTTPOperationClassNames.member?("AFJSONRequestOperation").should == true
    end

    it "should set operation if provided string" do
      [["json", "AFJSONRequestOperation"], ["xml", "AFXMLRequestOperation"], ["plist", "AFPropertyListRequestOperation"]].each do |op, op_class|
        @dsl.operation op
        @client.registeredHTTPOperationClassNames.member?(op_class).should == true
      end
    end
  end

  describe "#parameter_encoding" do
    it "should set encoding if provided type" do
      @dsl.parameter_encoding AFJSONParameterEncoding
      @client.parameterEncoding.should == AFJSONParameterEncoding
    end

    it "should set encoding if provided string" do
      [["json", AFJSONParameterEncoding], ["form", AFFormURLParameterEncoding], ["plist", AFPropertyListParameterEncoding]].each do |enc, enc_class|
        @dsl.parameter_encoding enc
        @client.parameterEncoding.should == enc_class
      end
    end
  end
end

describe "AFMotion::Client" do
  describe ".build" do
    it "should return an AFHTTPClient" do
      client = AFMotion::Client.build("http://url")
      client.is_a?(AFHTTPClient).should == true
    end
  end

  describe ".build_shared" do
    it "should set AFMotion::Client.shared" do
      client = AFMotion::Client.build_shared("http://url")
      AFMotion::Client.shared.should == client
    end
  end
end

describe "AFHTTPClient" do
  before do
    @client = AFHTTPClient.clientWithBaseURL("http://google.com/".to_url)
  end

  describe "URL Helpers" do
    it "should exist" do
      AFMotion::HTTP_METHODS.each do |method|
        @client.respond_to?(method).should == true
      end
    end
  end

  # Pretty basic test
  it "should work" do
    @result = nil
    @client.get("") do |result|
      @result = result
      resume
    end
    wait_max(10) do
      @result.nil?.should == false
    end
  end

  describe "#authorization=" do
    it "should set basic auth" do
      @client.authorization = {username: "clay", password: "pass"}
      @client.defaultValueForHeader("Authorization").split[0].should == "Basic"
    end
  end

  describe "#build_shared" do
    it "should set AFMotion::Client.shared" do
      @client.authorization = {token: "clay"}
      @client.defaultValueForHeader("Authorization").split[0].should == "Token"
    end
  end

  describe "#multipart" do
    it "should trigger multipart logic" do
      @client.multipart.should == @client
      @client.instance_variable_get("@multipart").should == true
    end

    it "should trigger multipart request" do
      @client.multipart.post("", test: "Herp") do |result|
        @result = result
        resume
      end

      wait_max(10) do
        @result.should.not == nil
        @result.operation.request.valueForHTTPHeaderField("Content-Type").include?("multipart/form-data").should == true
      end
    end

    it "should work with form data" do
      @client.multipart.post("", test: "Herp") do |result, form_data|
        if result
          resume
        else
          @form_data = form_data
        end
      end

      wait_max(10) do
        @form_data.should.not == nil
      end
    end
  end
end