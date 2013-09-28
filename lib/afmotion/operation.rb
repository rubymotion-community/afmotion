module AFMotion
  module Operation
    module_function
    def for_request(ns_url_request, &callback)
      operation = AFHTTPRequestOperation.alloc.initWithRequest(ns_url_request)
      operation.setCompletionBlockWithSuccess(success_block(callback), failure: failure_block(callback))
      operation
    end

    def success_block(callback)
      lambda { |operation, responseObject|
        result = AFMotion::HTTPResult.new(operation, responseObject, nil)
        callback.call(result)
      }
    end

    def failure_block(callback)
      lambda { |operation, error|
        result = AFMotion::HTTPResult.new(operation, nil, error)
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