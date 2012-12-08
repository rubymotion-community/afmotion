module AFMotion
  module Operation
    module HTTP
      def self.for_request(request, &callback)
        operation = AFHTTPRequestOperation.alloc.initWithRequest(request)
        operation.setCompletionBlockWithSuccess(
          lambda { |operation, responseObject|
            result = AFMotion::HTTPResult.new(operation, responseObject, nil)
            callback.call(result)
          },
          failure: lambda {|operation, error|
            result = AFMotion::HTTPResult.new(operation, nil, error)
            callback.call(result)
          }
        )
        operation
      end
    end

    module JSON
      def self.for_request(request, &callback)
        operation = AFJSONRequestOperation.JSONRequestOperationWithRequest(request,
          success: lambda { |request, response, json|
            result = AFMotion::HTTPResult.new(operation, json, nil)
            callback.call(result)
          },
          failure: lambda { |request, response, error, json|
            result = AFMotion::HTTPResult.new(operation, json, error)
            callback.call(result)
          }
        )
      end    
    end

    module XML
      def self.for_request(request, &callback)
        operation = AFXMLRequestOperation.XMLParserRequestOperationWithRequest(request,
          success: lambda { |request, response, document_or_parser|
            result = AFMotion::HTTPResult.new(operation, document_or_parser, nil)
            callback.call(result)
          },
          failure: lambda { |request, response, error, document_or_parser|
            result = AFMotion::HTTPResult.new(operation, document_or_parser, error)
            callback.call(result)
          }
        )
      end    
    end

    module PLIST
      def self.for_request(request, &callback)
        operation = AFPropertyListRequestOperation.propertyListRequestOperationWithRequest(request,
          success: lambda { |request, response, propertyList|
            result = AFMotion::HTTPResult.new(operation, propertyList, nil)
            callback.call(result)
          },
          failure: lambda { |request, response, error, propertyList|
            result = AFMotion::HTTPResult.new(operation, propertyList, error)
            callback.call(result)
          }
        )
      end    
    end

    module Image
      def self.for_request(request, &callback)
        operation = AFImageRequestOperation.imageRequestOperationWithRequest(request,
          imageProcessingBlock: lambda {|ui_image|
            return ui_image
          },
          success: lambda { |request, response, ui_image|
            result = AFMotion::HTTPResult.new(operation, ui_image, nil)
            callback.call(result)
          },
          failure: lambda { |request, response, error|
            result = AFMotion::HTTPResult.new(operation, nil, error)
            callback.call(result)
          }
        )
      end
    end
  end
end