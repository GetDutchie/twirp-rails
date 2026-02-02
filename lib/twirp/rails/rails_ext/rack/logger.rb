# frozen_string_literal: true

require 'active_support'
require 'active_support/concern'
require 'rails/rack/logger'

module Twirp
  module Rails
    module RackLoggerExtension
      # Suppress "Started POST /twirp/..." messages for Twirp requests
      # while preserving Rails' instrumentation and tag management.
      #
      # This replaces the old monkey-patch that completely overrode call_app,
      # which broke Rails 7.2's instrumentation, body proxy, and tag lifecycle.
      private

      def started_request_message(request)
        # Suppress log for Twirp requests (they have their own logging via Subscriber)
        # Default path prefix is /twirp but can be customized via routes scope option
        path = request.path rescue nil
        return nil if path&.include?('/twirp/')

        super
      end
    end
  end
end

# Only prepend if the method exists (Rails 4.2+)
if Rails::Rack::Logger.private_method_defined?(:started_request_message)
  Rails::Rack::Logger.prepend(Twirp::Rails::RackLoggerExtension)
end
