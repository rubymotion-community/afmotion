class NSMutableURLRequest
  alias_method :url, :URL

  def url=(url)
    self.setURL(url.to_url)
  end

  def content_type=(content_type)
    self.setValue(content_type, forHTTPHeaderField: "Content-Type")
  end

  def parameters=(params = {})
    method = self.HTTPMethod

    af_encoding = params[:__encoding__] || AFFormURLParameterEncoding
    string_encoding = params[:__string_encoding__] || NSUTF8StringEncoding

    params.delete :__encoding__
    params.delete :__string_encoding__

    use_url_based_params = ["GET", "HEAD", "DELETE", "PUT"].member?(method)

    if use_url_based_params && !params.empty?
      url_string = String.new(self.url.absoluteString)
      has_query = url_string.rangeOfString("?").location == NSNotFound
      format = has_query ? "?" : "&"
      encoded = AFQueryStringFromParametersWithEncoding(params, string_encoding)
      self.url = (url_string << format) << encoded
    elsif !use_url_based_params
      charset = CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(string_encoding))
      error = Pointer.new(:object)
      case af_encoding
      when AFFormURLParameterEncoding
        self.content_type = "application/x-www-form-urlencoded; charset=%@" << charset
        self.HTTPBody = AFQueryStringFromParametersWithEncoding(params, string_encoding).dataUsingEncoding(string_encoding)
      when AFJSONParameterEncoding
        self.content_type = "application/json; charset=%@" << charset
        self.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: 0, error: error)
      when AFPropertyListParameterEncoding
        self.content_type = "application/x-plist; charset=%@" << charset
        self.HTTPBody = NSPropertyListSerialization.dataWithPropertyList(params, format: NSPropertyListXMLFormat_v1_0, options: 0, error: error)
      end

      if error[0]
        p "NSURLRequest #{self.inspect}#parameters=#{params.inspect} ERROR: #{error.localizedDescription}"
      end
    end
  end
end