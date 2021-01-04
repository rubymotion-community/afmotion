describe "AFMotion" do

  modules = [AFMotion::HTTP, AFMotion::JSON, AFMotion::XML, AFMotion::PLIST]

  modules.each do |_module|
    describe _module.to_s do
      extend WebStub::SpecHelpers

      before do
        disable_network_access!
        @result = nil
      end

      after do
        enable_network_access!
        reset_stubs
      end


      it "should have all the HTTP methods" do
        AFMotion::HTTP_METHODS.each do |method|
          _module.respond_to?(method).should == true
        end
      end

      describe ".get" do
        before do
          @result = nil
        end

        it "should work with string" do
          _module.get("https://google.com") do |result|
            @result = result
            resume
          end
          wait_max(10) do
            @result.nil?.should == false
          end
        end
      end

      describe ".head" do
        before do
          @result = nil
        end

        it "should work with string" do
          _module.head("http://google.com") do |result|
            @result = result
            resume
          end
          wait_max(10) do
            @result.nil?.should == false
          end
        end
      end

    end
  end

  describe "AFMotion::Image" do
    before do
      @result = nil
    end

    it "should work with an image" do
      url = "https://www.google.com/images/srpr/logo3w.png"
      AFMotion::Image.get(url) do |result|
        @result = result
        resume
      end
      wait_max(10) do
        @result.nil?.should == false
        @result.object.is_a?(UIImage).should == true
      end
    end
  end
end
