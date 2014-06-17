motion_require 'version'

module AFMotion
  class HTTP
    def self.operation_manager
      @operation_manager ||= begin
        manager = AFHTTPRequestOperationManager.manager
        configure_manager(manager)
        manager
      end
    end

    def self.configure_manager(manager)
      manager.http!
    end
  end

  class JSON < HTTP
    def self.configure_manager(manager)
      manager.json!
      manager.responseSerializer.readingOptions = NSJSONReadingMutableContainers
    end
  end

  class XML < HTTP
    def self.configure_manager(manager)
      manager.xml!
    end
  end

  class PLIST < HTTP
    def self.configure_manager(manager)
      manager.plist!
    end
  end

  class Image < HTTP
    def self.configure_manager(operation)
      operation.image!
    end
  end

  [HTTP, JSON, XML, PLIST, Image].each do |base|
    AFMotion::HTTP_METHODS.each do |method_name|
      method_signature = "#{method_name.to_s.upcase}:parameters:success:failure:"
      base.define_singleton_method(method_name, -> (url, parameters = nil, &callback) do
        base.operation_manager.send(method_signature, url,
          parameters,
          AFMotion::Operation.success_block_for_http_method(method_name, callback),
          AFMotion::Operation.failure_block(callback))
      end)
    end
  end
end