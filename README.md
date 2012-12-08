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

### Web Services

If you're interacting with a web service, you can use `AFHTTPClient` with this nice wrapper:

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

### Images

Loading images from the internet is pretty common. AFNetworking's existing methods aren't bad at all, but just incase you want extra Ruby:

```ruby
  image_view = UIImageView.alloc.initWithFrame CGRectMake(0, 0, 100, 100)
  image_view.url = "http://i.imgur.com/r4uwx.jpg"

  # or

  placeholder = UIImage.imageNamed "placeholder-avatar"
  image_view.url = {url: "http://i.imgur.com/r4uwx.jpg", placeholder: placeholder}
```

You can also request arbitrary images:

```ruby
  AFMotion::Image.get("https://www.google.com/images/srpr/logo3w.png") do |result|
    image_view = UIImageView.alloc.initWithImage(result.object)
  end
```

## Install

1. `gem install afmotion`

2. `require 'afmotion'` or add to your `Gemfile`

3. In your `Rakefile`, add:

```ruby
Motion::Project::App.setup do |app|
  ...

  app.pods do
    pod 'AFNetworking'
  end
end
```

## Overview

### Results

Each AFMotion wrapper callback yields an `AFMotion::HTTPResult` object. This object has properties like so:

```ruby
AFMotion::some_function do |result|
  # result.operation is the AFURLConnectionOperation instance
  p result.operation.inspect

  if result.success?
    # result.object depends on the type of operation.
    # For JSON and PLIST, this is usually a Hash.
    # For XML, this is an NSXMLParser
    # For HTTP, this is an NSURLResponse
    # For Image, this is a UIImage
    p result.object

  elsif result.failure?
    # result.error is an NSError
    p result.error.localizedDescription
  end
end
```

### Operations

There are wrappers for each `AFURLConnectionOperation` subclass, each of the form:

```ruby
AFMotion::Operation::[Operation Type].for_request(ns_url_request) do |result|
  ...
end
```

- `AFMotion::Operation::HTTP.for_request...`
- `AFMotion::Operation::JSON.for_request...`
- `AFMotion::Operation::XML.for_request...`
- `AFMotion::Operation::PLIST.for_request...`
- `AFMotion::Operation::Image.for_request...`

### One-off Requests

There are wrappers which automatically run a URL request for a given URL and HTTP method, of the form:

```ruby
AFMotion::[Operation Type].[HTTP method](url, [Parameters = {}]) do |result|
  ...
end
```

Example:

```ruby
AFMotion::HTTP.get("http://google.com", q: "rubymotion") do |result|
  # sends request to http://google.com?q=rubymotion
end
```

- `AFMotion::HTTP.get/post/put/patch/delete(url)...`
- `AFMotion::JSON.get/post/put/patch/delete(url)...`
- `AFMotion::XML.get/post/put/patch/delete(url)...`
- `AFMotion::PLIST.get/post/put/patch/delete(url)...`
- `AFMotion::Image.get/post/put/patch/delete(url)...`

### HTTP Client

If you're constantly accesing a web service, it's a good idea to use an `AFHTTPClient`. Things lets you add a common base URL and request headers to all the requests issued through it, like so:

```ruby
client = AFMotion::Client.build("https://alpha-api.app.net/") do
  header "Accept", "application/json"

  operation :json
end

client.get("stream/0/posts/stream/global") do |result|
  ...
end
```

If you're constantly used one web service, you can use the `AFMotion::Client.shared` variable have a common reference. It can be set like a normal variable or created with `AFMotion::Client.build_shared`.

#### Client Building DSL

The `AFMotion::Client` DSL allows the following properties:

- `header(header, value)`
- `authorization(username: ___, password: ____)` for HTTP Basic auth, or `authorization(token: ____)` for Token based auth.
- `operation(operation_type)`. Allows you to set a common operation class for all your client's requests. So if your API is always going to be JSON, you should set `operation(:json)`. Accepts `:json`, `:plist`, `:xml`, or `:http`
- `parameter_encoding(encoding)`. Allows you to set a body format for requests parameters. For example, when you send a POST request you might want the parameters to be encoding as a JSON object instead of the traditional `key=val` format. Accepts `:json`, `:plist`, and `:form` (normal encoding).