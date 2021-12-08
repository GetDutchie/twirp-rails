# frozen_string_literal: true

module Twirp
  module Rails
    class ServiceWrapper
      attr_reader :service

      def initialize(service)
        @service = service
        @before_route_request = []
        @on_error = []
        @exception_raised = []
      end

      def before_route_request(&block) @before_route_request << block; end

      def on_error(&block)
        service.on_error(&block)
        @on_error << block
      end

      def exception_raised(&block)
        service.exception_raised(&block)
        @exception_raised << block
      end

      def call(rack_env)
        rack_request = Rack::Request.new(rack_env)

        content_type = rack_request.get_header("CONTENT_TYPE")
        path_parts = rack_request.fullpath.split("/")
        method_name = path_parts[-1]
        base_env = service.class.rpcs[method_name] || {}

        env = base_env.merge(
          content_type: content_type
        )

        @before_route_request.each do |hook|
          result = hook.call(rack_env, env)
          return error_response(result, env) if result.is_a? ::Twirp::Error
        end

        service.call(rack_env)
      end

      def method_missing(method, *args, &block)
        if service.respond_to?(method)
          service.send(method, *args, &block)
        else
          super
        end
      end

      private

      def error_response(twerr, env)
        begin
          @on_error.each{|hook| hook.call(twerr, env) }
          service.class.error_response(twerr)
        rescue => e
          return exception_response(e, env)
        end
      end

      def exception_response(e, env)
        raise e if service.class.raise_exceptions

        begin
          @exception_raised.each{|hook| hook.call(e, env) }
        rescue => hook_e
          e = hook_e
        end

        twerr = Twirp::Error.internal_with(e)
        service.class.error_response(twerr)
      end
    end
  end
end
