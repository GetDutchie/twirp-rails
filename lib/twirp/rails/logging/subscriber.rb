# frozen_string_literal: true

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
          twirp_call_info = {
            "service" => event.payload[:env][:service].try(:full_name),
            "method" => event.payload[:env][:rpc_method],
            "path" => event.payload[:rack_env]["REQUEST_PATH"],
            "duration" => event.duration
          }

          twirp_call_info[:params] = event.payload[:env][:input].to_h if Twirp::Rails.configuration.logging.log_params

          if (exception = event.payload[:env][:exception]) && Twirp::Rails.configuration.logging.log_exceptions
            twirp_call_info[:exception] = exception
          end

          data = Twirp::Rails.configuration.logging.log_formatter.call(twirp_call_info)
          logger.info data
        end

        def base_log_info(event)
          {
            service: event.payload[:env][:service].try(:full_name),
            method: event.payload[:env][:rpc_method],
            path: event.payload[:rack_env]["REQUEST_PATH"],
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
