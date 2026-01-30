# frozen_string_literal: true

require 'active_support'
require 'active_support/log_subscriber'

module Twirp
  module Rails
    module Logging
      class Subscriber < ActiveSupport::LogSubscriber
        cattr_accessor :log_writer

        def instrumenter(event)
          if Subscriber.log_writer
            Subscriber.log_writer.call(event)
          else
            default_log_writer(event)
          end
        end

        def default_log_writer(event)
          env = event.payload[:env]
          return if env.nil? # Guard against missing payload

          twirp_call_info = {
            **status_info(event),
            **base_log_info(event)
          }

          twirp_call_info[:params] = env[:input].to_h if Twirp::Rails.application_config.logging.log_params

          if (exception = env[:exception]) && Twirp::Rails.application_config.logging.log_exceptions
            twirp_call_info[:exception] = exception
          end

          data = Twirp::Rails.application_config.logging.log_formatter.call(twirp_call_info)
          logger.info data
        end

        def base_log_info(event)
          env = event.payload[:env] || {}
          rack_env = event.payload[:rack_env] || {}

          {
            service: env[:service].try(:full_name),
            method: env[:rpc_method],
            path: rack_env["REQUEST_PATH"],
            time: Time.current.iso8601,
            duration: event.duration
          }
        end

        def status_info(event)
          status = {}

          if (twerr = event.payload[:twerr])
            status[:status] = twerr.code&.upcase || "UNKNOWN"
          else
            status[:status] = "OK"
          end

          status
        end
      end
    end
  end
end
