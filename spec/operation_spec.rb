describe "AFMotion::Operation" do
  before do
    @request = NSURLRequest.requestWithURL(NSURL.URLWithString("http://google.com"))
  end

  describe "::HTTP" do
    describe ".for_request" do
      it "should be a AFHTTPRequestOperation" do
        operation = AFMotion::Operation::HTTP.for_request(@request)
        operation.is_a?(AFHTTPRequestOperation).should == true
      end
    end
  end

  describe "::JSON" do
    describe ".for_request" do
      it "should be a AFJSONRequestOperation" do
        operation = AFMotion::Operation::JSON.for_request(@request)
        operation.is_a?(AFJSONRequestOperation).should == true
      end
    end
  end

  describe "::XML" do
    describe ".for_request" do
      it "should be a AFXMLRequestOperation" do
        operation = AFMotion::Operation::XML.for_request(@request)
        operation.is_a?(AFXMLRequestOperation).should == true
      end
    end
  end

  describe "::PLIST" do
    describe ".for_request" do
      it "should be a AFPropertyListRequestOperation" do
        operation = AFMotion::Operation::PLIST.for_request(@request)
        operation.is_a?(AFPropertyListRequestOperation).should == true
      end
    end
  end
end