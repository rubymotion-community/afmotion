module AFMotion
  module Operation
    module_function
    def for_request(ns_url_request, &callback)
      operation = AFHTTPRequestOperation.alloc.initWithRequest(ns_url_request)
      success_block = success_block_for_http_method(ns_url_request.HTTPMethod, callback)
      operation.setCompletionBlockWithSuccess(success_block, failure: failure_block(callback))
      operation
    end

    def success_block_for_http_method(http_method, callback)
      if http_method.downcase.to_sym == :head
        return lambda { |operation|
          AFMotion::HTTPResult.new(operation, nil, nil)
        }
      end

      lambda { |operation, responseObject|
        result = AFMotion::HTTPResult.new(operation, responseObject, nil)
        callback.call(result)
      }
    end

    def failure_block(callback)
      lambda { |operation, error|
        result = AFMotion::HTTPResult.new(operation, operation.responseObject, error)
        callback.call(result)
      }
    end
  end

  module Serialization
    def with_request_serializer(serializer_klass)
      self.requestSerializer = serializer_klass.serializer
      self
    end

    def with_response_serializer(serializer_klass)
      self.responseSerializer = serializer_klass.serializer
      self
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

class AFHTTPRequestOperation
  include AFMotion::Serialization
end

class AFHTTPRequestOperationManager
  include AFMotion::Serialization
end