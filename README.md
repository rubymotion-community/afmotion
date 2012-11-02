# AFMotion

AFMotion is a thin RubyMotion wrapper for [AFNetworking](https://github.com/AFNetworking/AFNetworking), the absolute best networking library on iOS.

## Usage

AFMotion can be used with standalone URL requests:

```ruby
AFMotion::HTTP.get("http://google.com") do |result|
  p result.body
end

AFMotion::JSON.get("http://jsonip.com") do |result|
  p result.object["ip"]
end
```

### HTTPClient

If you're interacting with a web service, you can use the outstanding `AFHTTPClient` with this nice wrapper:

```ruby
# DSL Mapping to properties of AFHTTPClient

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
```