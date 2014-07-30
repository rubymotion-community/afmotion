module AFMotion
  class HTTPResult
    attr_accessor :operation, :object, :error, :task

    def initialize(operation_or_task, responseObject, error)
      if defined?(NSURLSessionTask) && operation_or_task.is_a?(NSURLSessionTask) ||
        # cluser class ugh
        operation_or_task.class.to_s.include?("Task")
        self.task = operation_or_task
      else
        self.operation = operation_or_task
      end
      self.object = responseObject
      self.error = error
    end

    def success?
      !failure?
    end

    def failure?
      !!error
    end

    def status_code
      if self.operation
        self.operation.response.statusCode
      else
        self.task.response.statusCode
      end
    end

    def body
      if task && task.currentRequest
        raise "Cannot call result.body of a task"
      end
      if operation && operation.responseString
        operation.responseString
      end
    end
  end
end
