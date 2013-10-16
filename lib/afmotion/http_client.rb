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
          dsl.instance_eval(&block)
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
      if serializer.is_a?(Symbol) || serializer.is_a?(String)
        @operation_manager.responseSerializer = OPERATION_TO_RESPONSE_SERIALIZER[serializer.to_sym].serializer
      elsif serializer.is_a?(Class)
        @operation_manager.responseSerializer = serializer.serializer
      else
        @operation_manager.responseSerializer = serializer
      end
    end
  end
end

# TODO: remove this when/if https://github.com/AFNetworking/AFNetworking/issues/1388 resolved
module AFMotion
  module QueryPairHelper
    module_function

    def af_QueryStringPairsFromDictionary(dictionary)
      af_QueryStringPairsFromKeyAndValue(nil, dictionary)
    end

    def af_QueryStringPairsFromKeyAndValue(key, value)
      mutableQueryStringComponents = []
      if value.is_a?(NSDictionary)
        sortDescriptor = NSSortDescriptor.sortDescriptorWithKey("description", ascending: true, selector:'caseInsensitiveCompare:')
        value.allKeys.sortedArrayUsingDescriptors([sortDescriptor]).each do |nestedKey|
          nestedValue = value[nestedKey]
          if nestedValue
            mutableQueryStringComponents += af_QueryStringPairsFromKeyAndValue(key ? "#{key}[#{nestedKey}]" : nestedKey, nestedValue)
          end
        end
      elsif value.is_a?(NSArray)
        value.each do |obj|
          mutableQueryStringComponents += af_QueryStringPairsFromKeyAndValue(key, obj)
        end
      elsif value.is_a?(NSSet)
        value.each do |obj|
          mutableQueryStringComponents += af_QueryStringPairsFromKeyAndValue(key, obj)
        end
      else
        mutableQueryStringComponents << AFQueryStringPair.alloc.initWithField(key, value: value)
      end

      mutableQueryStringComponents
    end
  end

  class MultipartParametersWrapper < Hash
    def initialize(parameters)
      super()
      query_pairs = QueryPairHelper.af_QueryStringPairsFromDictionary(parameters)
      query_pairs.each do |key_pair|
        self[key_pair.field] = key_pair.value
      end
    end
  end
end

class AFHTTPRequestOperationManager
  include AFMotion::ClientShared

  AFMotion::HTTP_METHODS.each do |method|
    # EX client.get('my/resource.json')
    define_method "#{method}", -> (path, parameters = {}, &callback) do
      create_operation(method, path, parameters, &callback)
    end
  end
end