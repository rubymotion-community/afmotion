describe "NSMutableURLRequest" do
  describe "parameters=" do
    before do
      @base_url = "http://google.com"
    end

    ["GET", "HEAD", "DELETE", "PUT"].each do |method|
      it "should work with #{method} requests" do
        @request = NSMutableURLRequest.requestWithURL(NSURL.URLWithString(@base_url))

        @request.HTTPMethod = method

        @request.parameters = {herp: "derp", "another" => 3}
        @request.url.absoluteString.should == "http://google.com?herp=derp&another=3"
      end
    end

    [:default, :URL, :JSON, :XML].each do |encoding|
      it "POST should work with #{encoding} encoding" do
        @request = NSMutableURLRequest.requestWithURL(NSURL.URLWithString(@base_url))
        @request.HTTPMethod = "POST"

        parameters = {herp: "derp", "another" => 3}
        case encoding
        when :URL
          @request.parameters = parameters.merge({__encoding__: AFFormURLParameterEncoding})
          String.new(@request.HTTPBody).should == "herp=derp&another=3"
        when :JSON
          @request.parameters = parameters.merge({__encoding__: AFJSONParameterEncoding})
          String.new(@request.HTTPBody).should == "{\"herp\":\"derp\",\"another\":3}"
        when :XML
          @request.parameters = parameters.merge({__encoding__: AFPropertyListParameterEncoding})
          String.new(@request.HTTPBody).should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n<plist version=\"1.0\">\n<dict>\n\t<key>another</key>\n\t<integer>3</integer>\n\t<key>herp</key>\n\t<string>derp</string>\n</dict>\n</plist>\n"
        else
          @request.parameters = parameters
          String.new(@request.HTTPBody).should == "herp=derp&another=3"
        end
      end
    end
  end
end