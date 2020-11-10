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

    def multipart_post(path, options = {}, &callback)
      create_multipart_task(:post, path, options, &callback)
    end

    def multipart_put(path, options = {}, &callback)
      create_multipart_task(:put, path, options, &callback)
    end

    def create_multipart_task(http_method, path, options = {}, &callback)
      parameters = options[:params]
      headers = options.fetch(:headers, {})
      progress = options[:progress_block]

      inner_callback = Proc.new do |result, form_data|
        case callback.arity
        when 1
          callback.call(result)
        when 2
          callback.call(result, form_data)
        end
      end

      multipart_callback = nil
      if callback.arity > 1
        multipart_callback = lambda { |formData|
          inner_callback.call(nil, formData)
        }
      end

      http_method = http_method.to_s.upcase
      if http_method == "POST"
        task = self.POST(path,
          parameters: parameters,
          headers: headers,
          constructingBodyWithBlock: multipart_callback,
          progress: progress,
          success: success_block_for_http_method(:post, inner_callback),
          failure: failure_block(inner_callback))
      else
        task = self.PUT(path,
          parameters: parameters,
          headers: headers,
          constructingBodyWithBlock: multipart_callback,
          progress: progress,
          success: success_block_for_http_method(:post, inner_callback),
          failure: failure_block(inner_callback))
      end
      task
    end

    def create_task(http_method, path, options = {}, &callback)
      parameters = options.fetch(:params, {})
      headers = options.fetch(:headers, {})
      progress = options[:progress_block]

      method_signature = "#{http_method.to_s.upcase}:parameters:headers:progress:success:failure"
      success = success_block_for_http_method(http_method, callback)
      failure = failure_block(callback)
      method_and_args = [method_signature, path, parameters, headers, progress, success, failure]

      # HEAD doesn't take a progress arg
      if http_method.to_s.upcase == "HEAD"
        method_signature.gsub!("progress:", "")
        method_and_args.delete_at(4)
      end

      self.public_send(*method_and_args)
    end

    def success_block_for_http_method(http_method, callback)
      if http_method.downcase.to_sym == :head
        return ->(task) {
          result = AFMotion::HTTPResult.new(task, nil, nil)
          callback.call(result)
        }
      end

      ->(task, responseObject) {
        result = AFMotion::HTTPResult.new(task, responseObject, nil)
        callback.call(result)
      }
    end

    def failure_block(callback)
      ->(task, error) {
        result = AFMotion::HTTPResult.new(task, nil, error)
        callback.call(result)
      }
    end

    private
    # To force RubyMotion pre-compilation of these methods
    def dummy
      self.GET("", parameters: nil, headers: nil, progress: nil, success: nil, failure: nil)
      self.HEAD("", parameters: nil, headers: nil, success: nil, failure: nil)
      self.POST("", parameters: nil, headers: nil, progress: nil, success: nil, failure: nil)
      self.POST("", parameters: nil, headers: nil, constructingBodyWithBlock: nil, progress: nil, success: nil, failure: nil)
      self.PUT("", parameters: nil, headers: nil, progress: nil, success: nil, failure: nil)
      self.DELETE("", parameters: nil, headers: nil, progress: nil, success: nil, failure: nil)
      self.PATCH("", parameters: nil, headers: nil, progress: nil, success: nil, failure: nil)
    end
  end
end
