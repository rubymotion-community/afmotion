class AFHTTPRequestSerializer
  class HeaderWrapper
    def initialize(serializer)
      @serializer = WeakRef.new(serializer)
    end

    def [](header)
      @serializer.HTTPRequestHeaders[header]
    end

    def []=(header, value)
      @serializer.setValue(value, forHTTPHeaderField: header)
    end

    def delete(header)
      value = self[header]
      self[header] = nil
      value
    end
  end

  def headers
    @header_wrapper ||= HeaderWrapper.new(self)
  end

  # options can be
  # - {username: ___, password: ____}
  # or
  # - {token: ___ }
  
  # def authorization=(options = {})
  #   if options.nil?
  #     clearAuthorizationHeader
  #   elsif options[:username] && options[:password]
  #     puts options
  #     # @serializer.setValue(options[:username], forHTTPHeaderField: 'Username')
  #     puts "serializer: #{@serializer}"
  #     @serializer.setValue("Basic #{options[:username]}:#{options[:password]}", forHTTPHeaderField: "Authorization")
  #     # @serializer.setValue(options[:password], forHTTPHeaderField: 'Password')
  #     # setAuthorizationHeaderFieldWithUsername(options[:username], password: options[:password])
  #   elsif options[:token]
  #     # @serializer.setValue(options[:token], forHTTPHeaderField: 'Token')
  #     puts "serializer: #{@serializer}"
  #     @serializer.setValue("Token #{options[:token]}", forHTTPHeaderField: "Authorization")
  #     # setAuthorizationHeaderFieldWithToken(options[:token])
  #   else
  #     raise "Not a valid authorization hash: #{options.inspect}"
  #   end
  # end
end
