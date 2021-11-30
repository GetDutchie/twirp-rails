# frozen_string_literal: true

module Twirp
  module Rails
    class LogSubscriber < ActiveSupport::LogSubscriber
      cattr_accessor :log_writer

      def instrumenter(event)
        if LogSubscriber.log_writer
          LogSubscriber.log_writer.call(event)
        else
          default_log_writer(event)
        end
      end

      def default_log_writer(event)
        twirp_call_info = {
          "path" => event.payload[:rack_env]["REQUEST_PATH"],
          "service" => event.payload[:env][:service].try(:full_name),
          "method" => event.payload[:env][:rpc_method],
          "duration" => event.duration
        }

        if (twerr = event.payload[:twerr])
          twirp_call_info["error_code"] = twerr.code
        end

        twirp_call_info["params"] = event.payload[:env][:input].to_h if Twirp::Rails.configuration.log_params

        if (exception = event.payload[:env][:exception]) && Twirp::Rails.configuration.log_exceptions
          twirp_call_info['exception'] = exception
        end

        data = Lograge::Formatters::KeyValue.new.call(twirp_call_info)
        logger.info data
      end
    end
  end
end