# frozen_string_literal: true

module Twirp
  module Rails
    class Configuration
      attr_accessor :handlers_paths, :hooks_paths

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
    end
  end
end
