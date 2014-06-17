motion_require 'version'
motion_require 'client_shared'

module AFMotion
  class Client
    class << self
      attr_accessor :shared

      # Returns an instance of AFHTTPRequestOperationManager
      def build(base_url, &block)
        operation_manager = AFHTTPRequestOperationManager.alloc.initWithBaseURL(base_url.to_url)
        if block
          dsl = AFMotion::ClientDSL.new(operation_manager)
          case block.arity
          when 0
            dsl.instance_eval(&block)
          when 1
            block.call(dsl)
          end
        end
        if !operation_manager.operationQueue
          operation_manager.operationQueue = NSOperationQueue.mainQueue
        end
        operation_manager
      end

      # Sets AFMotion::Client.shared as the built client
      def build_shared(base_url, &block)
        self.shared = self.build(base_url, &block)
      end
    end
  end
end

module AFMotion
  class ClientDSL
    def initialize(operation_manager)
      @operation_manager = WeakRef.new(operation_manager)
    end

    def header(header, value)
      @operation_manager.headers[header] = value
    end

    def authorization(options = {})
      @operation_manager.requestSerializer.authorization = options
    end

    def operation_queue(operation_queue)
      @operation_manager.operationQueue = operation_queue
    end

    OPERATION_TO_REQUEST_SERIALIZER = {
      json: AFJSONRequestSerializer,
      plist: AFPropertyListRequestSerializer
    }
    def request_serializer(serializer)
      if serializer.is_a?(Symbol) || serializer.is_a?(String)
        @operation_manager.requestSerializer = OPERATION_TO_REQUEST_SERIALIZER[serializer.to_sym].serializer
      elsif serializer.is_a?(Class)
        @operation_manager.requestSerializer = serializer.serializer
      else
        @operation_manager.requestSerializer = serializer
      end
    end

    OPERATION_TO_RESPONSE_SERIALIZER = {
      json: AFJSONResponseSerializer,
      xml: AFXMLParserResponseSerializer,
      plist: AFPropertyListResponseSerializer,
      image: AFImageResponseSerializer,
      http: AFHTTPResponseSerializer,
      form: AFHTTPResponseSerializer
    }
    def response_serializer(serializer)
      write_json_options = true
      if serializer.is_a?(Symbol) || serializer.is_a?(String)
        @operation_manager.responseSerializer = OPERATION_TO_RESPONSE_SERIALIZER[serializer.to_sym].serializer
      elsif serializer.is_a?(Class)
        @operation_manager.responseSerializer = serializer.serializer
      else
        @operation_manager.responseSerializer = serializer
        write_json_options = false
      end
      af_serializer = @operation_manager.responseSerializer
      if af_serializer.is_a?(AFJSONResponseSerializer) && write_json_options
        af_serializer.readingOptions = NSJSONReadingMutableContainers
      end
      af_serializer
    end
  end
end

class AFHTTPRequestOperationManager
  include AFMotion::ClientShared

  AFMotion::HTTP_METHODS.each do |method|
    # EX client.get('my/resource.json')
    define_method "#{method}", -> (path, parameters = nil, &callback) do
      create_operation(method, path, parameters, &callback)
    end
  end

  # options = {parameters: , constructingBodyWithBlock: , success:, failure:}
  def PUT(url_string, options = {})
    parameters = options[:parameters]
    block = options[:constructingBodyWithBlock]
    success = options[:success]
    failure = options[:failure]
    request = self.requestSerializer.multipartFormRequestWithMethod("PUT", URLString: NSURL.URLWithString(url_string, relativeToURL:self.baseURL).absoluteString, parameters: parameters, constructingBodyWithBlock:block)
    operation = self.HTTPRequestOperationWithRequest(request, success:success, failure:failure)
    self.operationQueue.addOperation(operation)

    operation
  end
end