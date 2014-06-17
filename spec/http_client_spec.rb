describe "AFMotion::ClientDSL" do
  before do
    @client = AFHTTPRequestOperationManager.alloc.initWithBaseURL("http://url".to_url)
    @dsl = AFMotion::ClientDSL.new(@client)
  end

  describe "#header" do
    it "should set header" do
      @dsl.header "Accept", "application/json"
      @client.requestSerializer.HTTPRequestHeaders["Accept"].should == "application/json"
    end
  end

  describe "#authorization" do
    it "should set authorization" do
      @dsl.authorization username: "clay", password: "test"
      @client.requestSerializer.HTTPRequestHeaders["Authorization"].nil?.should == false
    end
  end

  describe "#request_serializer" do
    it "should set request_serializer if provided type" do
      @dsl.request_serializer AFJSONRequestSerializer
      @client.requestSerializer.is_a?(AFJSONRequestSerializer).should == true
    end

    it "should set request_serializer if provided string" do
      [["json", AFJSONRequestSerializer], ["plist", AFPropertyListRequestSerializer]].each do |op, op_class|
        @dsl.request_serializer op
        @client.requestSerializer.is_a?(op_class).should == true
      end
    end
  end

  describe "#response_serializer" do
    it "should set response_serializer if provided type" do
      @dsl.response_serializer AFJSONResponseSerializer
      @client.responseSerializer.is_a?(AFJSONResponseSerializer).should == true
    end

    it "should set response_serializer if provided string" do
      [["json", AFJSONResponseSerializer],
       ["form", AFHTTPResponseSerializer],
       ["http", AFHTTPResponseSerializer],
       ["xml", AFXMLParserResponseSerializer],
       ["plist", AFPropertyListResponseSerializer],
       ["image", AFImageResponseSerializer]].each do |enc, enc_class|
        @dsl.response_serializer enc
        @client.responseSerializer.is_a?(enc_class).should == true
      end
    end

    it "should set mutable reading options for JSON serializer" do
      @dsl.response_serializer :json
      @client.responseSerializer.readingOptions.should == NSJSONReadingMutableContainers
    end

    it "should not set reading options for JSON serializer if raw one supplied" do
      @dsl.response_serializer AFJSONResponseSerializer.serializer
      @client.responseSerializer.readingOptions.should.not == NSJSONReadingMutableContainers
    end
  end
end

describe "AFMotion::Client" do
  describe ".build" do
    it "should return an AFHTTPRequestOperationManager" do
      client = AFMotion::Client.build("http://url")
      client.is_a?(AFHTTPRequestOperationManager).should == true
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
    @client = AFHTTPRequestOperationManager.alloc.initWithBaseURL("http://google.com/".to_url)
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
          @result.operation.request.valueForHTTPHeaderField("Content-Type").include?("multipart/form-data").should == true
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
        @file_added = false
        @client = AFHTTPRequestOperationManager.alloc.initWithBaseURL("http://bing.com/".to_url)
        @client.send(multipart_method, "", test: "Herp") do |result, form_data, progress|
          if form_data
            @file_added = true
            form_data.appendPartWithFileData(@data, name: "test", fileName:"test.png", mimeType: "image/png")
          elsif progress
            @progress ||= progress
          elsif result
            resume
          end
        end

        wait_max(20) do
          @file_added.should == true
          @progress.should <= 1.0
          @progress.should.not == nil
        end
      end
    end
  end
end