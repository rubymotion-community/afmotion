motion_require 'http_client'
motion_require 'version'

=begin
  AFMotion::SessionClient.build("http://google.com") do |client|
    client.session_configuration :default # :ephemeral
    client.session_configuration :background, "com.usepropeller.afmotion"
    client.session_configuration my_session_configuration

    response_serializer

    request_serializer
  end
=end
module AFMotion
  class SessionClient
    class << self

      attr_accessor :shared

      # Returns an instance of AFHTTPRequestOperationManager
      def build(base_url, &block)
        dsl = AFMotion::SessionClientDSL.new(base_url)
        case block.arity
        when 0
          dsl.instance_eval(&block)
        when 1
          block.call(dsl)
        end

        dsl.to_session_manager
      end

      # Sets AFMotion::Client.shared as the built client
      def build_shared(base_url, &block)
        self.shared = self.build(base_url, &block)
      end
    end
  end
end

module AFMotion
  class SessionClientDSL < ClientDSL
    class Config
      attr_accessor :responseSerializer, :operationQueue, :requestSerializer, :sessionConfiguration

      class MockRequestSerializer
        attr_accessor :authorization
      end

      def requestSerializer
        @requestSerializer ||= MockRequestSerializer.new
      end

      def requestSerializer=(requestSerializer)
        if @requestSerializer && @requestSerializer.is_a?(MockRequestSerializer)
          requestSerializer.authorization = @requestSerializer.authorization
        end
        @requestSerializer = requestSerializer
      end

      def headers
        @headers ||= {}
      end
    end

    attr_accessor :operation_manager
    alias_method :config, :operation_manager

    def initialize(base_url)
      @base_url = base_url
      @operation_manager = Config.new
    end

    def to_session_manager
      session_manager = AFHTTPSessionManager.alloc.initWithBaseURL(@base_url.to_url,
          sessionConfiguration: config.sessionConfiguration)
      session_manager.responseSerializer = config.responseSerializer if config.responseSerializer
      if !config.requestSerializer.is_a?(Config::MockRequestSerializer)
        session_manager.requestSerializer = config.requestSerializer
      elsif config.requestSerializer.authorization
        session_manager.requestSerializer.authorization = config.requestSerializer.authorization
      end
      config.headers.each do |key, value|
        session_manager.requestSerializer.headers[key] = value
      end
      session_manager.operationQueue = config.operationQueue if config.operationQueue
      session_manager
    end

    SESSION_CONFIGURATION_SHORTHAND = {
      default: :defaultSessionConfiguration,
      ephemeral: :ephemeralSessionConfiguration,
      background: "backgroundSessionConfiguration:".to_sym
    }

    def session_configuration(session_configuration, identifier = nil)
      if session_configuration.is_a?(Symbol) || session_configuration.is_a?(String)
        method_signature = SESSION_CONFIGURATION_SHORTHAND[session_configuration.to_sym]
        ns_url_session_configuration = begin
          if identifier
            NSURLSessionConfiguration.send(method_signature, identifier)
          else
            NSURLSessionConfiguration.send(method_signature)
          end
        end
        self.config.sessionConfiguration = ns_url_session_configuration
      elsif session_configuration.is_a?(NSURLSessionConfiguration) ||
          # cluster class smh
          session_configuration.class.to_s.include?("URLSessionConfiguration")
        self.config.sessionConfiguration = session_configuration
      else
        raise "Invalid type for session_configuration; need Symbol, String, or NSURLSessionConfiguration, but got #{session_configuration.class}"
      end
    end
  end
end

class AFHTTPSessionManager
  include AFMotion::ClientShared

  AFMotion::HTTP_METHODS.each do |method|
    # EX client.get('my/resource.json')
    define_method "#{method}", -> (path, parameters = {}, &callback) do
      create_task(method, path, parameters, &callback)
    end
  end

  # options = {parameters: , constructingBodyWithBlock: , success:, failure:}
  def PUT(url_string, options = {})
    parameters = options[:parameters]
    block = options[:constructingBodyWithBlock]
    success = options[:success]
    failure = options[:failure]

    request = self.requestSerializer.multipartFormRequestWithMethod("PUT", URLString: NSURL.URLWithString(url_string, relativeToURL: self.baseURL).absoluteString, parameters:parameters, constructingBodyWithBlock:block)

    task = self.dataTaskWithRequest(request, completionHandler: ->(response, responseObject, error) {
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