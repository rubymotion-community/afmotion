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
  def authorization=(options = {})
    if options.nil?
      clearAuthorizationHeader
    elsif options[:username] && options[:password]
      setAuthorizationHeaderFieldWithUsername(options[:username], password: options[:password])
    else
      raise "Not a valid authorization hash: #{options.inspect}"
    end
  end
end
