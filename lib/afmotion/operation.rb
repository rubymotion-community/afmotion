module AFMotion
  module Operation
    module_function

    def success_block_for_http_method(http_method, callback)
      if http_method.downcase.to_sym == :head
        return lambda { |operation_or_task|
          result = AFMotion::HTTPResult.new(operation_or_task, nil, nil)
          callback.call(result)
        }
      end

      lambda { |operation_or_task, responseObject|
        result = AFMotion::HTTPResult.new(operation_or_task, responseObject, nil)
        callback.call(result)
      }
    end

    def failure_block(callback)
      lambda { |operation_or_task, error|
        result = AFMotion::HTTPResult.new(operation_or_task, nil, error)
        callback.call(result)
      }
    end
  end
end
