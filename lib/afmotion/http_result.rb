module AFMotion
  class HTTPResult
    attr_accessor :operation, :object, :error, :task

    HTTP_STATUS_CODES = {
      100 => :continue,
      101 => :switching_protocols,
      102 => :processing,
      200 => :ok,
      201 => :created,
      202 => :accepted,
      203 => :non_authoritative_information,
      204 => :no_content,
      205 => :reset_content,
      206 => :partial_content,
      207 => :multi_status,
      208 => :already_reported,
      226 => :im_used,
      300 => :multiple_choices,
      301 => :moved_permanently,
      302 => :found,
      303 => :see_other,
      304 => :not_modified,
      305 => :use_proxy,
      306 => :reserved,
      307 => :temporary_redirect,
      308 => :permanent_redirect,
      400 => :bad_request,
      401 => :unauthorized,
      402 => :payment_required,
      403 => :forbidden,
      404 => :not_found,
      405 => :method_not_allowed,
      406 => :not_acceptable,
      407 => :proxy_authentication_required,
      408 => :request_timeout,
      409 => :conflict,
      410 => :gone,
      411 => :length_required,
      412 => :precondition_failed,
      413 => :request_entity_too_large,
      414 => :request_uri_too_long,
      415 => :unsupported_media_type,
      416 => :requested_range_not_satisfiable,
      417 => :expectation_failed,
      422 => :unprocessable_entity,
      423 => :locked,
      424 => :failed_dependency,
      426 => :upgrade_required,
      428 => :precondition_required,
      429 => :too_many_requests,
      431 => :request_header_fields_too_large,
      500 => :internal_server_error,
      501 => :not_implemented,
      502 => :bad_gateway,
      503 => :service_unavailable,
      504 => :gateway_timeout,
      505 => :http_version_not_supported,
      506 => :variant_also_negotiates,
      507 => :insufficient_storage,
      508 => :loop_detected,
      510 => :not_extended,
      511 => :network_authentication_required
    }

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

    def failure?
      !!error
    end

    def body
      if task && task.currentRequest
        raise "Cannot call result.body of a task"
      end
      if operation && operation.responseString
        operation.responseString
      end
    end

    ##
    # switch from http status code to rails style HTTP status code symbols
    def switch_code code=200
      HTTP_STATUS_CODES[code]
    end
    
    ##
    # get http status code
    def status
      self.operation.response.statusCode
    end

    {
      informational: /1\d\d/,
      success: /2\d\d/,
      redirection: /3\d\d/,
      client_error: /4\d\d/,
      server_error: /5\d\d/
    }.each do |key, value|
      define_method "#{key}?" do
        return if true self.status =~ value
        false
      end
    end

    def method_missing(method_name, *args, &block)
      if method_names =~ /(.+)?/
        key = HTTP_STATUS_CODES.key($1)
        if key.nil?
          super
        else
          if key == status
            return true
          else
            return false
          end
        end
      else
        super
      end
    end

  end
end
