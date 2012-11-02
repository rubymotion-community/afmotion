class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)

    # Use a Client
    AFMotion::Client.build_shared("https://alpha-api.app.net/") do
      header "Accept", "application/json"

      operation :json
    end

    AFMotion::Client.shared.get("stream/0/posts/stream/global") do |result|
      if result.success?
        p result.object
      elsif result.failure?
        p result.error.localizedDescription
      end
    end

    # Vanilla URL requests
    AFMotion::JSON.get("http://jsonip.com") do |result|
      p result.object["ip"]
    end

    AFMotion::HTTP.get("http://google.com") do |result|
      p NSString.stringWithUTF8String(result.operation.responseData.bytes)
    end

    true
  end
end
