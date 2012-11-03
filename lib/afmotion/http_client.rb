module AFMotion
  class ClientDSL
    def initialize(client)
      @client = client
    end

    def header(header, value)
      @client.setDefaultHeader(header, value: value)
    end

    def authorization(options = {})
      @client.authorization = options
    end

    def operation(operation)
      klass = operation
      if operation.is_a?(Symbol) or operation.is_a?(String)
        klass = case operation.to_s
                when "json"
                  AFJSONRequestOperation
                when "plist"
                  AFPropertyListRequestOperation
                when "xml"
                  AFXMLRequestOperation
                when "http"
                  AFHTTPRequestOperation
                else
                  raise "Not a valid operation: #{operation.inspect}"
                end
      end

      @client.registerHTTPOperationClass(klass)
    end

    def parameter_encoding(encoding)
      enc = encoding
      if encoding.is_a?(Symbol) or encoding.is_a?(String)
        enc = case encoding.to_s
              when "json"
                AFJSONParameterEncoding
              when "plist"
                AFPropertyListParameterEncoding
              when "form"
                AFFormURLParameterEncoding
              else
                p "Not a valid parameter encoding: #{encoding.inspect}; using AFFormURLParameterEncoding"
                AFFormURLParameterEncoding
              end
      end
      @client.parameterEncoding = enc
    end
  end
end

module AFMotion
  class Client
    class << self
      attr_accessor :shared

      # Returns an instance of AFHTTPClient
      def build(base_url, &block)
        client = AFHTTPClient.clientWithBaseURL(base_url.to_url)
        if block
          dsl = AFMotion::ClientDSL.new(client)
          dsl.instance_eval(&block)
        end
        client
      end

      # Sets AFMotion::Client.shared as the built client
      # TODO: Make sure this only happens once (dispatch_once not available)
      def build_shared(base_url, &block)
        self.shared = self.build(base_url, &block)
      end
    end
  end
end

class AFHTTPClient
  AFMotion::HTTP_METHODS.each do |method|
    # EX client.get('my/resource.json')
    define_method "#{method}", -> (path, parameters = {}, &callback) do
      fn = "#{method}Path:parameters:success:failure:"
      self.send(fn, path, parameters,
        lambda {|operation, responseObject|
          result = AFMotion::HTTPResult.new(operation, responseObject, nil)
          callback.call(result)
        }, lambda {|operation, error|
          result = AFMotion::HTTPResult.new(operation, nil, error)
          callback.call(result)
        })
    end

  end

  # options can be
  # - {username: ___, password: ____}
  # or
  # - {token: ___ }
  def authorization=(options = {})
    if options.nil?
      clearAuthorizationHeader
    elsif options[:username] && options[:password]
      setAuthorizationHeaderWithUsername(options[:username], password: options[:password])
    elsif options[:token]
      setAuthorizationHeaderWithToken(options[:token])
    else
      raise "Not a valid authorization hash: #{options.inspect}"
    end
  end

  private
  # To force RubyMotion pre-compilation of these methods
  def dummy
    self.getPath("", parameters: nil, success: nil, failure: nil)
    self.postPath("", parameters: nil, success: nil, failure: nil)
    self.putPath("", parameters: nil, success: nil, failure: nil)
    self.deletePath("", parameters: nil, success: nil, failure: nil)
    self.patchPath("", parameters: nil, success: nil, failure: nil)
  end
end