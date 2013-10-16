module AFMotion
  module ClientShared
    def headers
      requestSerializer.headers
    end

    def all_headers
      requestSerializer.HTTPRequestHeaders
    end

    def authorization=(authorization)
      requestSerializer.authorization = authorization
    end

    def multipart_post(path, parameters = {}, &callback)
      create_multipart_operation(path, parameters, &callback)
    end

    def create_multipart_operation(path, parameters = {}, &callback)
      parameters = AFMotion::MultipartParametersWrapper.new(parameters)
      inner_callback = Proc.new do |result, form_data,  bytes_written_now,  total_bytes_written, total_bytes_expect|

        case callback.arity
        when 1
          callback.call(result)
        when 2
          callback.call(result, form_data)
        when 3
          progress = nil
          if total_bytes_written && total_bytes_expect
            progress = total_bytes_written.to_f / total_bytes_expect.to_f
          end
          callback.call(result, form_data, progress)
        when 5
          callback.call(result, form_data, bytes_written_now, total_bytes_written, total_bytes_expect)
        end
      end

      multipart_callback = nil
      if callback.arity == 2
        multipart_callback = lambda { |formData|
          inner_callback.call(nil, formData)
        }
      end

      upload_callback = nil
      if callback.arity > 2
        upload_callback = lambda { |bytes_written_now, total_bytes_written, total_bytes_expect|
          inner_callback.call(nil, nil, bytes_written_now, total_bytes_written, total_bytes_expect)
        }
      end

      operation = self.POST(path,
        parameters: parameters,
        constructingBodyWithBlock: multipart_callback,
        success: lambda {|operation, responseObject|
          result = AFMotion::HTTPResult.new(operation, responseObject, nil)
          inner_callback.call(result)
        }, failure: lambda {|operation, error|
          result = AFMotion::HTTPResult.new(operation, nil, error)
          inner_callback.call(result)
        })
      if upload_callback
        operation.setUploadProgressBlock(upload_callback)
      end
      operation
    end

    def create_operation(http_method, path, parameters = {}, &callback)
      method_signature = "#{http_method.upcase}:parameters:success:failure:"
      method = self.method(method_signature)
      success_block = AFMotion::Operation.success_block_for_http_method(http_method, callback)
      operation = method.call(path, parameters, success_block, AFMotion::Operation.failure_block(callback))
    end

    alias_method :create_task, :create_operation

    private
    # To force RubyMotion pre-compilation of these methods
    def dummy
      self.GET("", parameters: nil, success: nil, failure: nil)
      self.HEAD("", parameters: nil, success: nil, failure: nil)
      self.POST("", parameters: nil, success: nil, failure: nil)
      self.POST("", parameters: nil, constructingBodyWithBlock: nil, success: nil, failure: nil)
      self.PUT("", parameters: nil, success: nil, failure: nil)
      self.DELETE("", parameters: nil, success: nil, failure: nil)
      self.PATCH("", parameters: nil, success: nil, failure: nil)
    end
  end
end