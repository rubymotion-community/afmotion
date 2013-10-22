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

  response_serializer :json
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

  response_serializer :json
end

client.get("stream/0/posts/stream/global") do |result|
  ...
end
```

If you're constantly used one web service, you can use the `AFMotion::Client.shared` variable have a common reference. It can be set like a normal variable or created with `AFMotion::Client.build_shared`.

`AFHTTPClient` supports methods of the form `AFHTTPClient#get/post/put/patch/delete(url, request_parameters)`. The `request_parameters` is a hash containing your parameters to attach as the request body or URL parameters, depending on request type. For example:

```ruby
client.get("users", id: 1) do |result|
  ...
end

client.post("users", name: "@clayallsopp", library: "AFMotion") do |result|
  ...
end
```

#### Multipart Requests

`AFHTTPClient` supports multipart form requests (i.e. for image uploading) - simply use `multipart_post` and it'll convert your parameters into properly encoded multipart data. For all other types of request data, use the `form_data` object passed to your callback:

```ruby
# an instance of UIImage
image = my_function.get_image
data = UIImagePNGRepresentation(image)

client.multipart_post("avatars") do |result, form_data|
  if form_data
    # Called before request runs
    # see: https://github.com/AFNetworking/AFNetworking/wiki/AFNetworking-FAQ
    form_data.appendPartWithFileData(data, name: "avatar", fileName:"avatar.png", mimeType: "image/png")
  elsif result.success?
    ...
  else
    ...
  end
end
```

This is an instance of `AFMultipartFormData` - for more info, see the [AFNetworking docs][http://cocoadocs.org/docsets/AFNetworking/2.0.0/Protocols/AFMultipartFormData.html].

If you want to track upload progress, you can add a third callback argument which returns the upload percentage between 0.0 and 1.0:

```ruby
client.multipart_post("avatars") do |result, form_data, progress|
  if form_data
    # Called before request runs
    # see: https://github.com/AFNetworking/AFNetworking/wiki/AFNetworking-FAQ
    form_data.appendPartWithFileData(data, name: "avatar", fileName:"avatar.png", mimeType: "image/png")
  elsif progress
    # 0.0 < progress < 1.0
    my_widget.update_progress(progress)
  else
  ...
end
```

#### Headers

You can set default HTTP headers using `client.headers`, which is sort of like a `Hash`:

```ruby
client.headers["Accept"]
#=> "application/json"

client.headers["Accept"] = "something_else"
#=> "application/something_else"

client.headers.delete "Accept"
#=> "application/something_else"
```

#### Client Operations

If you want to grab an `AFURLConnectionOperation` from your client instance, use `create_operation` or `create_multipart_operation`:

```ruby
operation = client.create_operation(:get, "http://google.com", {q: "hello"}) do |result|
end

multipart_operation = client.create_multipart_operation(:get, "http://google.com", {q: "hello"}) do |result, form_data, progress|
end

# elsewhere
client.enqueueHTTPRequestOperation(operation)
```

#### Client Building DSL

The `AFMotion::Client` DSL allows the following properties:

- `header(header, value)`
- `authorization(username: ___, password: ____)` for HTTP Basic auth, or `authorization(token: ____)` for Token based auth.
- `request_serializer(serializer)`. Allows you to set an [`AFURLRequestSerialization`](http://cocoadocs.org/docsets/AFNetworking/2.0.0/Protocols/AFURLRequestSerialization.html) for all your client's requests, which determines how data is encoded on the way to the server. So if your API is always going to be JSON, you should set `operation(:json)`. Accepts `:json` and `:plist`, or any instance of `AFURLRequestSerialization`.
- `response_serializer(serializer)`. Allows you to set an [`AFURLResponseSerialization`](http://cocoadocs.org/docsets/AFNetworking/2.0.0/Protocols/AFURLResponseSerialization.html), which determines how data is decoded once the server respnds. Accepts `:json`, `:xml`, `:plist`, `:image`, `:http`, or any instance of `AFURLResponseSerialization`.
