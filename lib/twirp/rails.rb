# frozen_string_literal: true
require "twirp/rails/logging/formatters/json"
require "twirp/rails/logging/formatters/key_value"
require "twirp/rails/configuration"
require 'twirp/rails/logging/adapter'
require 'twirp/rails/logging/subscriber'
require "twirp/rails/service_wrapper"
require "twirp/rails/helpers/hooks"
require "twirp/rails/helpers/services"
require "twirp/rails/routes"
require "twirp/rails/version"
require 'active_support'

module Twirp
  module Rails
    class << self
      attr_accessor :application

      def configuration
        @configuration ||= Configuration.new
      end

      def configure(&block)
        yield configuration if block_given?
        configuration
      end

      def setup_logging(app)
        @application = app

        require "twirp/rails/rails_ext/rack/logger"

        if application.config.twirp.logging.log_writer.is_a?(Proc)
          log_twirp_calls!(&app.config.twirp.logging.log_writer)
        else
          log_twirp_calls!
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
          Dir[File.join(handlers_path.to_s, '**', '*.rb')].sort.each {|f| require f }
        end
      end

      def load_hooks
        configuration.hooks_paths.each do |hooks_path|
          Dir[File.join(hooks_path.to_s, '**', '*.rb')].sort.each { |f| require f }
        end
      end

      def application_config
        application.config.twirp
      end
    end
  end
end


require "twirp/rails/railtie" if defined?(Rails)
