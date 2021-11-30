# frozen_string_literal: true

require "twirp/rails/configuration"
require 'twirp/rails/logging_adapter'
require 'twirp/rails/log_subscriber'
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
        if configuration.log_twirp_calls
          if configuration.log_twirp_calls.is_a?(Proc)
            log_twirp_calls!(&configuration.log_twirp_calls)
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
        Twirp::Rails::LoggingAdapter.install

        Twirp::Rails::LogSubscriber.log_writer = log_writer if block_given?
        Twirp::Rails::LogSubscriber.attach_to(:twirp)
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
