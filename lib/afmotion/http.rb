motion_require 'version'

module AFMotion
  class HTTP
    def self.manager
      @manager ||= begin
        manager = AFHTTPSessionManager.manager
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
    def self.configure_manager(manager)
      manager.image!
    end
  end

  [HTTP, JSON, XML, PLIST, Image].each do |base|
    AFMotion::HTTP_METHODS.each do |method_name|
      http_method = method_name.to_s.upcase

      method_signature = "#{http_method}:parameters:headers:progress:success:failure:"
      method_signature.gsub!("progress:", "") if http_method == "HEAD"

      base.define_singleton_method(method_name, -> (url, options = {}, &callback) do
        parameters = options.fetch(:params, {})
        headers = options[:headers]
        progress = options[:progress_block]

        args = [ method_signature,
          url,
          parameters,
          headers,
          progress,
          manager.success_block_for_http_method(method_name, callback),
          manager.failure_block(callback)
        ]

        args.delete_at(4) if http_method == "HEAD" # HEAD doesn't take a progress arg

        base.manager.send(*args)
      end)
    end
  end
end
