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
      if @multipart
        multipart_callback = callback.arity == 1 ? nil : lambda { |formData|
          callback.call(nil, formData)
        }
        upload_callback = callback.arity > 2 ? lambda { |bytes_written_now, total_bytes_written, total_bytes_expect|
          case callback.arity
          when 3
            callback.call(nil, nil, total_bytes_written.to_f / total_bytes_expect.to_f)
          when 5
            callback.call(nil, nil, bytes_written_now, total_bytes_written, total_bytes_expect)
          end
        } : nil
        request = self.multipartFormRequestWithMethod(method, path: path,
          parameters: parameters,constructingBodyWithBlock: multipart_callback)
        operation = self.HTTPRequestOperationWithRequest(request,
          success: lambda {|operation, responseObject|
            result = AFMotion::HTTPResult.new(operation, responseObject, nil)
            case callback.arity
            when 1
              callback.call(result)
            when 2
              callback.call(result, nil)
            when 3
              callback.call(result, nil, nil)
            when 5
              callback.call(result, nil, nil, nil, nil)
            end
          }, failure: lambda {|operation, error|
            result = AFMotion::HTTPResult.new(operation, nil, error)
            case callback.arity
            when 1
              callback.call(result)
            when 2
              callback.call(result, nil)
            when 3
              callback.call(result, nil, nil)
            when 5
              callback.call(result, nil, nil, nil, nil)
            end
          })
        if upload_callback
          operation.setUploadProgressBlock(upload_callback)
        end
        self.enqueueHTTPRequestOperation(operation)
        @multipart = nil
        @operation = operation
      else
        request = self.requestWithMethod(method.upcase, path:path, parameters:parameters)
        @operation = self.HTTPRequestOperationWithRequest(request, success: lambda {|operation, responseObject|
            result = AFMotion::HTTPResult.new(operation, responseObject, nil)
            callback.call(result)
          }, failure: lambda {|operation, error|
            result = AFMotion::HTTPResult.new(operation, nil, error)
            callback.call(result)
          })
        self.enqueueHTTPRequestOperation(@operation)
      end
    end
  end

  def multipart
    @multipart = true
    self
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