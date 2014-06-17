describe "AFMotion::SessionClientDSL" do
  before do
    @dsl = AFMotion::SessionClientDSL.new("http://url")
  end

  describe "#header" do
    it "should set header" do
      @dsl.header "Accept", "application/json"
      @dsl.to_session_manager.requestSerializer.HTTPRequestHeaders["Accept"].should == "application/json"
    end
  end

  describe "#authorization" do
    it "should set authorization" do
      @dsl.authorization username: "clay", password: "test"
      @dsl.to_session_manager.requestSerializer.HTTPRequestHeaders["Authorization"].nil?.should == false
    end
  end

  describe "#request_serializer" do
    it "should set request_serializer if provided type" do
      @dsl.request_serializer AFJSONRequestSerializer
      @dsl.to_session_manager.requestSerializer.is_a?(AFJSONRequestSerializer).should == true
    end

    it "should set request_serializer if provided string" do
      [["json", AFJSONRequestSerializer], ["plist", AFPropertyListRequestSerializer]].each do |op, op_class|
        @dsl.request_serializer op
        @dsl.to_session_manager.requestSerializer.is_a?(op_class).should == true
      end
    end
  end

  describe "#response_serializer" do
    it "should set response_serializer if provided type" do
      @dsl.response_serializer AFJSONResponseSerializer
      @dsl.to_session_manager.responseSerializer.is_a?(AFJSONResponseSerializer).should == true
    end

    it "should set response_serializer if provided string" do
      [["json", AFJSONResponseSerializer],
       ["form", AFHTTPResponseSerializer],
       ["http", AFHTTPResponseSerializer],
       ["xml", AFXMLParserResponseSerializer],
       ["plist", AFPropertyListResponseSerializer],
       ["image", AFImageResponseSerializer]].each do |enc, enc_class|
        @dsl.response_serializer enc
        @dsl.to_session_manager.responseSerializer.is_a?(enc_class).should == true
      end
    end

    it "should set mutable reading options for JSON serializer" do
      @dsl.response_serializer :json
      @dsl.to_session_manager.responseSerializer.readingOptions.should == NSJSONReadingMutableContainers
    end

    it "should not set reading options for JSON serializer if raw one supplied" do
      @dsl.response_serializer AFJSONResponseSerializer.serializer
      @dsl.to_session_manager.responseSerializer.readingOptions.should.not == NSJSONReadingMutableContainers
    end
  end

  describe "#session_configuration" do
    describe "for default" do
      it "should work" do
        @dsl.session_configuration :default
        @dsl.to_session_manager.sessionConfiguration.URLCache.diskCapacity.should > 0
      end
    end

    describe "for ephemeral" do
      it "should work" do
        @dsl.session_configuration :ephemeral
        @dsl.to_session_manager.sessionConfiguration.URLCache.diskCapacity.should == 0
      end
    end

    describe "for background" do
      it "should work" do
        @dsl.session_configuration :background, "com.usepropeller.afmotion.test"
        manager = @dsl.to_session_manager
        manager.sessionConfiguration.sessionSendsLaunchEvents.should == true
        manager.sessionConfiguration.identifier.should == "com.usepropeller.afmotion.test"
      end
    end

    describe "for instances" do
      it "should work" do
        session_config = NSURLSessionConfiguration.defaultSessionConfiguration
        session_config.identifier = "test"
        @dsl.session_configuration session_config
        @dsl.to_session_manager.sessionConfiguration.should == session_config
      end
    end
  end
end

describe "AFMotion::SessionClient" do
  describe ".build" do
    it "should return an AFHTTPSessionManager" do
      client = AFMotion::SessionClient.build("http://url") do
      end
      client.is_a?(AFHTTPSessionManager).should == true
    end
  end

  describe ".build_shared" do
    it "should set AFMotion::SessionClient.shared" do
      client = AFMotion::SessionClient.build_shared("http://url") do
      end
      AFMotion::SessionClient.shared.should == client
    end
  end
end

describe "AFHTTPSessionManager" do
  before do
    @client = AFHTTPSessionManager.alloc.initWithBaseURL("http://bing.com/".to_url,
      sessionConfiguration: NSURLSessionConfiguration.defaultSessionConfiguration)
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
      @client.requestSerializer.HTTPRequestHeaders["Authorization"].split[0].should == "Basic"
    end
  end

  describe "#build_shared" do
    it "should set AFMotion::Client.shared" do
      @client.authorization = {token: "clay"}
      @client.requestSerializer.HTTPRequestHeaders["Authorization"].split[0].should == "Token"
    end
  end

  describe "#headers" do
    describe "#[]" do
      it "should return a header" do
        @client.requestSerializer.setValue("test_value", forHTTPHeaderField: "test")
        @client.headers["test"].should == "test_value"
      end
    end

    describe "#[]=" do
      it "should set a header" do
        @client.headers["test"] = "test_set_value"
        @client.requestSerializer.HTTPRequestHeaders["test"].should == "test_set_value"
      end
    end

    describe "#delete" do
      it "should remove a header" do
        @client.requestSerializer.setValue("test_value", forHTTPHeaderField: "test")
        @client.headers.delete("test").should == "test_value"
        @client.requestSerializer.HTTPRequestHeaders["test"].should == nil
      end
    end
  end


  ["multipart_post", "multipart_put"].each do |multipart_method|
    describe "##{multipart_method}" do
      it "should trigger multipart request" do
        @client.send(multipart_method, "", test: "Herp") do |result, form_data|
          @result = result
          resume if result
        end

        wait_max(10) do
          @result.should.not == nil
          @result.task.currentRequest.valueForHTTPHeaderField("Content-Type").include?("multipart/form-data").should == true
        end
      end

      it "should work with form data" do
        @client.send(multipart_method, "", test: "Herp") do |result, form_data|
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

      it "should have upload callback with raw progress" do
        image = UIImage.imageNamed("test")
        @data = UIImagePNGRepresentation(image)
        @file_added = nil
        @client.send(multipart_method, "", test: "Herp") do |result, form_data, progress|
          if form_data
            @file_added = true
            form_data.appendPartWithFileData(@data, name: "test", fileName:"test.png", mimeType: "image/png")
          elsif progress
            @progress ||= progress
          elsif result
            @result = result
            resume
          end
        end

        wait_max(20) do
          @file_added.should == true
          if (UIDevice.currentDevice.model =~ /simulator/i).nil?
            @progress.should <= 1.0
            @progress.should.not == nil
          end
          @result.should.not == nil
        end
      end
    end
  end
end