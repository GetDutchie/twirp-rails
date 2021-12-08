# frozen_string_literal: true
require "twirp/rails/rails_ext/rack/logger"
require "twirp/rails/logging/formatters/json"
require "twirp/rails/logging/formatters/key_value"
require "twirp/rails/configurations/logging"
require "twirp/rails/configuration"
require 'twirp/rails/logging/adapter'
require 'twirp/rails/logging/subscriber'
require "twirp/rails/service_wrapper"
require "twirp/rails/helpers/hooks"
require "twirp/rails/helpers/services"
require "twirp/rails/routes"
require "twirp/rails/engine"
require "twirp/rails/version"

module Twirp
  module Rails
    class << self
      def configuration
        @configuration ||= Configuration.new
      end

      def configure(&block)
        yield configuration if block_given?
        setup
        configuration
      end

      def setup
        if configuration.logging.log_twirp_calls
          if configuration.logging.log_twirp_calls.is_a?(Proc)
            log_twirp_calls!(&configuration.logging.log_twirp_calls)
          else
            log_twirp_calls!
          end
        end
      end

      # A store to register rack apps, which are the instantiated services.
      # @return [Array<Twirp::Service>]
      def services
        @services ||= []
      end

      def hooks
        @hooks ||= {}
      end

      def global_service_hooks
        @global_service_hooks ||= []
      end

      def log_twirp_calls!(&log_writer)
        Twirp::Rails::Logging::Adapter.install

        Twirp::Rails::Logging::Subscriber.log_writer = log_writer if block_given?
        Twirp::Rails::Logging::Subscriber.attach_to(:twirp)
      end

      def load_handlers
        configuration.handlers_paths.each do |handlers_path|
          ::Rails.application.reloader.to_prepare do
            Dir[File.join(handlers_path.to_s, '**', '*.rb')].sort.each { |f| require f }
          end
        end
      end

      def load_hooks
        configuration.hooks_paths.each do |hooks_path|
          ::Rails.application.reloader.to_prepare do
            Dir[File.join(hooks_path.to_s, '**', '*.rb')].sort.each { |f| require f }
          end
        end
      end
    end
  end
end
