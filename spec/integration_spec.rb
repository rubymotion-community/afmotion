describe "AFMotion" do
  extend WebStub::SpecHelpers

  before do
    disable_network_access!
    @object = nil
    @result = nil
  end

  after do
    enable_network_access!
    reset_stubs
  end

  describe "JSON" do
    it "should use mutable containers" do
      url = "http://example.com/"
      stub_request(:get, url).
        to_return(json: {"data" => ["thing"]}, delay: 0.3)

      AFMotion::JSON.get(url) do |result|
        @result = result
        @object = result.object
        resume
      end

      wait_max 1.0 do
        array = @object['data']
        array << 'derp'
        array.count.should == 2

        @object['hello'] = 'world'
        @object.count.should == 2

        @object.delete('data')
        @object.count.should == 1

        @result.status_code.should == 200
      end
    end
  end

  describe "Client" do
    describe "JSON" do
      it "should use mutable containers" do
        base_url = "http://example.com/"
        path = "path"
        stub_request(:get, base_url + path).
          to_return(json: {"data" => ["thing"]}, delay: 0.3)

        client = AFMotion::Client.build(base_url) do
          response_serializer :json
        end

        client.get(path, params: nil) do |result|
          @result = result
          @object = result.object
          resume
        end

        wait_max 1.0 do
          array = @object['data']
          array << 'derp'
          array.count.should == 2

          @object['hello'] = 'world'
          @object.count.should == 2

          @object.delete('data')
          @object.count.should == 1

          @result.status_code.should == 200
        end
      end
    end
  end
end
