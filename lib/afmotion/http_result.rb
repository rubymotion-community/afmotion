module AFMotion
  class HTTPResult
    attr_accessor :object, :error, :task

    def initialize(task, responseObject, error)
      self.task = task
      self.object = responseObject
      self.error = error
    end

    def success?
      !failure?
    end

    def failure?
      !!error
    end
    
    # include this for backwards compatibility (?)
    def operation
      puts "HTTPResult#operation is deprecated and returns a task, switch to using #task"
      task
    end

    def status_code
      if self.task && self.task.response
        self.task.response.statusCode
      else
        nil
      end
    end

    def body
      self.object
    end
  end
end
