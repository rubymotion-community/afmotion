module AFMotion
  class SessionClientDSL
  class Config
    attr_accessor :responseSerializer, :requestSerializer, :sessionConfiguration

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

  attr_accessor :config

  def initialize(base_url)
    @base_url = base_url
    @config = Config.new
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
    session_manager
  end

  SESSION_CONFIGURATION_SHORTHAND = {
    default: :defaultSessionConfiguration,
    ephemeral: :ephemeralSessionConfiguration,
    background: (Object.const_defined?("UIDevice") && UIDevice.currentDevice.systemVersion.to_f >= 8.0 ? "backgroundSessionConfigurationWithIdentifier:" : "backgroundSessionConfiguration:").to_sym
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
  
  def header(header, value)
    @headers ||= {}
    @headers[header] = value
    apply_header(header, value)
  end

  def authorization(options = {})
    @authorization = options
    apply_authorization(options)
  end

  OPERATION_TO_REQUEST_SERIALIZER = {
    json: AFJSONRequestSerializer,
    plist: AFPropertyListRequestSerializer
  }
  def request_serializer(serializer)
    if serializer.is_a?(Symbol) || serializer.is_a?(String)
    config.requestSerializer = OPERATION_TO_REQUEST_SERIALIZER[serializer.to_sym].serializer
    elsif serializer.is_a?(Class)
    config.requestSerializer = serializer.serializer
    else
    config.requestSerializer = serializer
    end
    reapply_options
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
    config.responseSerializer = OPERATION_TO_RESPONSE_SERIALIZER[serializer.to_sym].serializer
    elsif serializer.is_a?(Class)
    config.responseSerializer = serializer.serializer
    else
    config.responseSerializer = serializer
    write_json_options = false
    end
    af_serializer = config.responseSerializer
    if af_serializer.is_a?(AFJSONResponseSerializer) && write_json_options
    af_serializer.readingOptions = NSJSONReadingMutableContainers
    end
    af_serializer
  end

  private

  def reapply_options
    @headers.each{ |h,v| apply_header(h, v) } unless @headers.nil?
    apply_authorization(@authorization) unless @authorization.nil?
  end

  def apply_header(header, value)
    config.headers[header] = value
  end

  def apply_authorization(options)
    config.requestSerializer.authorization = options
  end
  
  end
end