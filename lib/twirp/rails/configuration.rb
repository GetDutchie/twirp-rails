# frozen_string_literal: true

module Twirp
  module Rails
    class Configuration
      attr_reader :handlers_paths, :hooks_paths, :logging

      def initialize
        @handlers_paths = []
        @hooks_paths = []
        @logging = Twirp::Rails::Configurations::Logging.new
      end

      def add_handlers_path(path)
        @handlers_paths << path.to_s
      end

      def add_hooks_path(path)
        @hooks_paths << path.to_s
      end
    end
  end
end
