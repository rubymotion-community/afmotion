# AFMotion

[![Build Status](https://travis-ci.org/clayallsopp/afmotion.png?branch=master)](https://travis-ci.org/clayallsopp/afmotion) [![FOSSA Status](https://app.fossa.io/api/projects/git%2Bhttps%3A%2F%2Fgithub.com%2Fclayallsopp%2Fafmotion.svg?size=small)](https://app.fossa.io/projects/git%2Bhttps%3A%2F%2Fgithub.com%2Fclayallsopp%2Fafmotion?ref=badge_small)

AFMotion is a thin RubyMotion wrapper for [AFNetworking](https://github.com/AFNetworking/AFNetworking), the absolute best networking library on iOS and OS X.

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

```ruby

@client = AFMotion::... # create your client

@client.get("stream/0/posts/stream/global") do |result|
  if result.success?
    p (result.operation || result.task) # depending on your client
  elsif result.failure?
    p result.error.localizedDescription
  end
end
```

#### Migration from AFMotion 2.x

_Breaking Change_
Parameters must now be specified with the `params:` keyword arg.

AFMotion 2.x

```ruby
AFMotion::HTTP.get("http://google.com", q: "rubymotion") do |result|
  # sends request to http://google.com?q=rubymotion
end
```

AFMotion 3.x

```ruby
AFMotion::HTTP.get("http://google.com", params: { q: "rubymotion" }) do |result|
  # sends request to http://google.com?q=rubymotion
end
```

This allows you to also pass in a progress_block or additional headers on the fly:

```ruby
AFMotion::HTTP.get("http://url.com/large_file.mov", params: { quality: "high" }, progress_block: proc { |progress| update_progress(progress) }, headers: {}) do |result|
  # sends request to http://google.com?q=rubymotion
end
```

For grouping similar requests (AFHTTPSession), use `AFMotion::Client` (now exactly the same as `AFMotion::SessionClient`)

#### AFMotion::Client

If you're interacting with a web service, you can use [`AFHTTPRequestOperationManager`](http://cocoadocs.org/docsets/AFNetworking/2.0.0/Classes/AFHTTPRequestOperationManager.html) with this nice wrapper:

```ruby
# DSL Mapping to properties of AFHTTPRequestOperationManager

@client = AFMotion::Client.build("https://alpha-api.app.net/") do
  header "Accept", "application/json"

  response_serializer :json
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

2. `require 'afmotion'` or add to your `Gemfile` (`gem 'afmotion'`)

3. `rake pod:install`

## Overview

### Results

Each AFMotion wrapper callback yields an `AFMotion::HTTPResult` object. This object has properties like so:

```ruby
AFMotion::some_function do |result|
  p result.task.inspect
  p result.status_code

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
AFMotion::HTTP.get("http://google.com", params: { q: "rubymotion" }) do |result|
  # sends request to http://google.com?q=rubymotion
end
```

- `AFMotion::HTTP.get/post/put/patch/delete(url)...`
- `AFMotion::JSON.get/post/put/patch/delete(url)...`
- `AFMotion::XML.get/post/put/patch/delete(url)...`
- `AFMotion::PLIST.get/post/put/patch/delete(url)...`
- `AFMotion::Image.get/post/put/patch/delete(url)...`

### HTTP Client

If you're constantly accesing a web service, it's a good idea to use an `AFHTTPSessionManager`. Things lets you add a common base URL and request headers to all the requests issued through it, like so:

```ruby
client = AFMotion::Client.build("https://alpha-api.app.net/") do
  header "Accept", "application/json"

  response_serializer :json
end

client.get("stream/0/posts/stream/global") do |result|
  # result.operation exists
  ...
end
```

If you're constantly used one web service, you can use the `AFMotion::Client.shared` variable have a common reference. It can be set like a normal variable or created with `AFMotion::Client.build_shared`.

`AFHTTPRequestOperationManager` & `AFHTTPSessionManager` support methods of the form `Client#get/post/put/patch/delete(url, request_parameters)`. The `request_parameters` is a hash containing your parameters to attach as the request body or URL parameters, depending on request type. For example:

```ruby
client.get("users", params: { id: 1 }) do |result|
  ...
end

client.post("users", params: { name: "@clayallsopp", library: "AFMotion" }) do |result|
  ...
end
```

#### Multipart Requests

`AFHTTPSessionManager` support multipart form requests (i.e. for image uploading) - simply use `multipart_post` and it'll convert your parameters into properly encoded multipart data. For all other types of request data, use the `form_data` object passed to your callback:

```ruby
# an instance of UIImage
image = my_function.get_image
data = UIImagePNGRepresentation(image)

client.multipart_post("avatars") do |result, form_data|
  if form_data
    # Called before request runs
    # see: http://cocoadocs.org/docsets/AFNetworking/2.5.0/Protocols/AFMultipartFormData.html
    form_data.appendPartWithFileData(data, name: "avatar", fileName:"avatar.png", mimeType: "image/png")
  elsif result.success?
    ...
  else
    ...
  end
end
```

This is an instance of [`AFMultipartFormData`](http://cocoadocs.org/docsets/AFNetworking/2.0.0/Protocols/AFMultipartFormData.html).

If you want to track upload progress, simply add a progress_block (Taking a single arg: `NSProgress`)

```ruby
client.multipart_post("avatars", progress_block: proc { |progress| update_progress(progress) }) do |result, form_data|
  if form_data
    # Called before request runs
    # see: https://github.com/AFNetworking/AFNetworking/wiki/AFNetworking-FAQ
    form_data.appendPartWithFileData(data, name: "avatar", fileName:"avatar.png", mimeType: "image/png")
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

#### Client Building DSL

The `AFMotion::Client` & `AFMotion::SessionClient` DSLs allows the following properties:

- `header(header, value)`
- `authorization(username: ___, password: ____)` for HTTP Basic auth, or `authorization(token: ____)` for Token based auth.
- `request_serializer(serializer)`. Allows you to set an [`AFURLRequestSerialization`](http://cocoadocs.org/docsets/AFNetworking/2.0.0/Protocols/AFURLRequestSerialization.html) for all your client's requests, which determines how data is encoded on the way to the server. So if your API is always going to be JSON, you should set `operation(:json)`. Accepts `:json` and `:plist`, or any instance of `AFURLRequestSerialization` and must be called before calling `header` or `authorization` or else the [headers will not be applied](https://github.com/clayallsopp/afmotion/issues/78).
- `response_serializer(serializer)`. Allows you to set an [`AFURLResponseSerialization`](http://cocoadocs.org/docsets/AFNetworking/2.0.0/Protocols/AFURLResponseSerialization.html), which determines how data is decoded once the server respnds. Accepts `:json`, `:xml`, `:plist`, `:image`, `:http`, or any instance of `AFURLResponseSerialization`.

For `AFMotion::SessionClient` only:

- `session_configuration(session_configuration, identifier = nil)`. Allows you to set the [`NSURLSessionConfiguration`](https://developer.apple.com/library/ios/documentation/Foundation/Reference/NSURLSessionConfiguration_class/Reference/Reference.html#//apple_ref/occ/cl/NSURLSessionConfiguration). Accepts `:default`, `:ephemeral`, `:background` (with the `identifier` as a String), or an instance of `NSURLSessionConfiguration`.

You can also configure your client by passing it as a block argument:

```ruby
client = AFMotion::SessionClient.build("https://alpha-api.app.net/") do |client|
  client.session_configuration :default

  client.header "Accept", @custom_header
end
```

## License

[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bhttps%3A%2F%2Fgithub.com%2Fclayallsopp%2Fafmotion.svg?size=large)](https://app.fossa.io/projects/git%2Bhttps%3A%2F%2Fgithub.com%2Fclayallsopp%2Fafmotion?ref=badge_large)
