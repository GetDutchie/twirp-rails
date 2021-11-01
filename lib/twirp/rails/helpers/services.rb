# frozen_string_literal: true

module Twirp
  module Rails
    module Helpers
      module Services
        def self.included(klass)
          klass.extend ClassMethods
        end

        module ClassMethods
          @@base_namespace = nil
          @@base_hooks = []

          def twirp_namespace(namespace)
            @@base_namespace = namespace.to_sym
          end

          def twirp_hooks(*args)
            @@base_hooks += args
          end

          def base_namespace
            @@base_namespace
          end

          def base_hooks
            @@base_hooks
          end

          def bind(service_klass, namespace: nil, context: nil, hooks: [])
            namespace = namespace&.to_sym || base_namespace
            if namespace.nil?
              raise ArgumentError.new(
                "namespace must be set before binding a service."
              )
            end

            service = service_klass.new(new)

            hooks = base_hooks + hooks

            hooks.each do |hook|
              hook_klass = Twirp::Rails.hooks.dig(namespace, hook)
              if hook_klass.nil?
                raise ArgumentError.new("Unknown hook #{hook} for #{namespace} namespace")
              end
              hook_klass.attach(service)
            end

            Twirp::Rails.services << [service, namespace, context]
          end
        end
      end
    end
  end
end
