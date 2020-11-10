motion_require 'version'
motion_require 'client_shared'
motion_require 'session_client_dsl'
motion_require 'ext/AFHTTPSessionManager'

=begin
  AFMotion::SessionClient.build("http://google.com") do |client|
    client.session_configuration :default # :ephemeral
    client.session_configuration :background, "com.usepropeller.afmotion"
    client.session_configuration my_session_configuration

    response_serializer

    request_serializer
  end
=end
module AFMotion
  class SessionClient
    class << self

      attr_accessor :shared

      # Returns an instance of AFHTTPRequestOperationManager
      def build(base_url, &block)
        dsl = AFMotion::SessionClientDSL.new(base_url)
        
        if block_given?
          case block.arity
          when 0
            dsl.instance_eval(&block)
          when 1
            block.call(dsl)
          end  
        end
        
        dsl.to_session_manager
      end

      # Sets AFMotion::Client.shared as the built client
      def build_shared(base_url, &block)
        self.shared = self.build(base_url, &block)
      end
    end
  end
  
  # These are now the same thing
  class Client < SessionClient
  end
end
