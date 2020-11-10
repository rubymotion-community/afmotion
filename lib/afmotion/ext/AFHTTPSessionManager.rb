motion_require '../client_shared'

module AFMotion
  module Serialization
  def with_request_serializer(serializer_klass)
    self.requestSerializer = serializer_klass.serializer
    self
  end
  
  def with_response_serializer(serializer_klass)
    self.responseSerializer = serializer_klass.serializer
    self
  end
  
  def http!
    with_request_serializer(AFHTTPRequestSerializer).
    with_response_serializer(AFHTTPResponseSerializer)
  end
  
  def json!
    with_request_serializer(AFJSONRequestSerializer).
    with_response_serializer(AFJSONResponseSerializer)
  end
  
  def xml!
    with_response_serializer(AFXMLParserResponseSerializer)
  end
  
  def plist!
    with_request_serializer(AFPropertyListRequestSerializer).
    with_response_serializer(AFPropertyListResponseSerializer)
  end
  
  def image!
    with_response_serializer(AFImageResponseSerializer)
  end
  end
end

class AFHTTPSessionManager
  include AFMotion::Serialization
  include AFMotion::ClientShared
  
  AFMotion::HTTP_METHODS.each do |method|
    # EX client.get('my/resource.json')
    define_method "#{method}", -> (path, options = {}, &callback) do
      create_task(method, path, options, &callback)
    end
  end

  # options = {parameters: , constructingBodyWithBlock: , success:, failure:}
  def PUT(url_string, options = {})
    parameters = options[:parameters]
    block = options[:constructingBodyWithBlock]
    progress = options[:progress_block]
    success = options[:success]
    failure = options[:failure]
  
    request = self.requestSerializer.multipartFormRequestWithMethod("PUT", URLString: NSURL.URLWithString(url_string, relativeToURL: self.baseURL).absoluteString, parameters:parameters, constructingBodyWithBlock:block, error:nil)
  
    task = self.dataTaskWithRequest(request, uploadProgress: progress, downloadProgress: nil, completionHandler: ->(response, responseObject, error) {
      if error && failure
      failure.call(task, error)
      elsif success
      success.call(task, responseObject)
      end
    })
  
    task.resume
  
    task
  end
end