module AFMotion
  # ported from https://github.com/AFNetworking/AFNetworking/blob/master/UIKit%2BAFNetworking/UIProgressView%2BAFNetworking.m
  class SessionObserver

    def initialize(task, callback)
      @callback = callback
      task.addObserver(self, forKeyPath:"state", options:0, context:nil)
      task.addObserver(self, forKeyPath:"countOfBytesSent", options:0, context:nil)
    end

    def observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
      if keyPath == "countOfBytesSent"
        # Could be -1, see https://github.com/AFNetworking/AFNetworking/issues/1354
        expectation = (object.countOfBytesExpectedToSend > 0) ? object.countOfBytesExpectedToSend.to_f : nil
        @callback.call(nil, object.countOfBytesSent.to_f, expectation)
      end

      if keyPath == "state" && object.state == NSURLSessionTaskStateCompleted
        begin
          object.removeObserver(self, forKeyPath: "state")
          object.removeObserver(self, forKeyPath: "countOfBytesSent")
          @callback = nil
        rescue
        end
      end
    end
  end

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
      create_multipart_operation(:post, path, parameters, &callback)
    end

    def multipart_put(path, parameters = {}, &callback)
      create_multipart_operation(:put, path, parameters, &callback)
    end

    def create_multipart_operation(http_method, path, parameters = {}, &callback)
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
      if callback.arity > 1
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

      http_method = http_method.to_s.upcase
      if http_method == "POST"
        operation_or_task = self.POST(path,
          parameters: parameters,
          constructingBodyWithBlock: multipart_callback,
          success: AFMotion::Operation.success_block_for_http_method(:post, inner_callback),
          failure: AFMotion::Operation.failure_block(inner_callback))
      else
        operation_or_task = self.PUT(path,
          parameters: parameters,
          constructingBodyWithBlock: multipart_callback,
          success: AFMotion::Operation.success_block_for_http_method(:post, inner_callback),
          failure: AFMotion::Operation.failure_block(inner_callback))
      end
      if upload_callback
        if operation_or_task.is_a?(AFURLConnectionOperation)
          operation_or_task.setUploadProgressBlock(upload_callback)
        else
          # using NSURLSession - messy, probably leaks
          @observer = SessionObserver.new(operation_or_task, upload_callback)
        end
      end
      operation_or_task
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