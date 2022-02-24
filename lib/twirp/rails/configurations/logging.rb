# frozen_string_literal: true

module Twirp
  module Rails
    module Configurations
      class Logging
        attr_accessor :log_twirp_calls, :log_exceptions, :log_params

        LOG_FORMATTERS = {
          json: Twirp::Rails::Logging::Formatters::Json,
          key_value: Twirp::Rails::Logging::Formatters::KeyValue
        }.freeze

        def initialize
          @log_twirp_calls = true
          @log_exceptions = false
          @log_params = false
          @log_formatter = LOG_FORMATTERS[:key_value].new
        end

        def log_formatter=(format)
          format = format.to_sym
          raise ArgumentError, 'Twirp::Rails defined an invalid log formatter' unless LOG_FORMATTERS.keys.include?(format)

          @log_formatter = LOG_FORMATTERS[format].new
        end
      end
    end
  end
end
