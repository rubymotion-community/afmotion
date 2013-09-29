module AFMotion
  module HTTPBuilder
    def self.included(base)
      AFMotion::HTTP_METHODS.each do |method|
        base.send(:define_singleton_method, method, -> (url, parameters = {}, &callback) do
          operation_manager.send(method.to_s.upcase, url,
            parameters: parameters,
            success: AFMotion::Operation.success_block_for_http_method(method, callback),
            failure: AFMotion::Operation.failure_block(callback))
        end)
      end
    end
  end

  module HTTP
    include AFMotion::HTTPBuilder

    module_function
    def operation_manager
      @operation_manager ||= begin
        manager = AFHTTPRequestOperationManager.manager
        configure_manager(manager)
        manager
      end
    end

    def configure_manager(manager)
    end
  end

  module JSON
    include AFMotion::HTTPBuilder

    module_function
    def configure_manager(manager)
      manager.json!
    end
  end

  module XML
    include AFMotion::HTTPBuilder

    module_function
    def configure_manager(manager)
      manager.xml!
    end
  end

  module PLIST
    include AFMotion::HTTPBuilder

    module_function
    def configure_manager(manager)
      manager.plist!
    end
  end

  module Image
    include AFMotion::HTTPBuilder

    module_function
    def configure_operation(operation)
      operation.image!
    end
  end
end