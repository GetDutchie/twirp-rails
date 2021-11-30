# frozen_string_literal: true

module Twirp
  module Rails
    class Configuration
      attr_reader :handlers_paths, :hooks_paths
      attr_writer :log_exceptions, :log_params, :log_twirp_calls

      def initialize
        @handlers_paths = []
        @hooks_paths = []
      end

      def add_handlers_path(path)
        @handlers_paths << path.to_s
      end

      def add_hooks_path(path)
        @hooks_paths << path.to_s
      end

      def log_twirp_calls
        @log_twirp_calls ||= true
      end

      def log_exceptions
        @log_exceptions ||= false
      end

      def log_params
        @log_params ||= false
      end
    end
  end
end
