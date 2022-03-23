# frozen_string_literal: true

module Twirp
  module Rails
    module Helpers
      module Services
        def self.included(klass)
          klass.extend ClassMethods
          klass.class_eval do
            puts "class_eval #{klass}"
          end
        end

        module ClassMethods
          attr_reader :base_namespace

          def twirp_namespace(namespace)
            puts "Setting namespace #{self} to #{namespace} from #{base_namespace}"
            @@base_namespace = namespace.to_sym
          end

          def register_hook(hook_klass, **options)
            puts "Setting up hook #{self}"
            puts base_hooks
            @@base_hooks = base_hooks.push({hook_klass: hook_klass, options: options})
          end

          def base_hooks
            @@base_hooks ||= []
          end

          def base_namespace
            @@base_namespace ||= nil
          end

          def bind(service_klass, namespace: nil, context: nil)
            namespace = namespace&.to_sym || base_namespace
            if namespace.nil?
              raise ArgumentError.new(
                "namespace must be set before binding a service."
              )
            end

            service_wrapper = Twirp::Rails::ServiceWrapper.new(service_klass.new(new))
            # binding.pry if base_hooks.count > 1
            Twirp::Rails.services << {service_wrapper: service_wrapper, namespace: namespace, context: context, hooks: base_hooks}
          end
        end
      end
    end
  end
end
