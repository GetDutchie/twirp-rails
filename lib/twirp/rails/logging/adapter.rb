# frozen_string_literal: true

require 'twirp/rails/routes'

module Twirp
  module Rails
    module Logging
      module Adapter# :nodoc:

        def self.install
          return unless defined?(ActiveSupport::Notifications)

          Twirp::Rails::Routes.on_create_service do |service_wrapper|
            Logging::Adapter.instrument service_wrapper
          end
        end

        def self.instrument(service_wrapper)
          instrumenter = ActiveSupport::Notifications.instrumenter

          service_wrapper.before_route_request do |rack_env, env|
            env[:service] = service_wrapper.service

            payload = {
              rack_env: rack_env,
              env: env
            }

            instrumenter.start 'instrumenter.twirp', payload
          end

          # Since before_route_request is called before Twirp::Service#call,
          # the env is reinstantiated in subsequent hooks we need to add back anything
          # added to the env by the before_route_request hook.
          service_wrapper.before do |rack_env, env|
            env[:service] = service_wrapper.service
          end

          service_wrapper.on_error do |twerr, env|
            env[:service] = service_wrapper.service

            payload = {
              twerr: twerr,
              env: env
            }

            instrumenter.finish 'instrumenter.twirp', payload
          end

          service_wrapper.on_success do |env|
            instrumenter.finish 'instrumenter.twirp', {}
          end

          service_wrapper.exception_raised do |e, env|
            env[:exception] = {
              class: e.class,
              message: e.message,
              backtrace: e.backtrace.join("\n")
            }
          end
        end
      end
    end
  end
end
