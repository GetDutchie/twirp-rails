# frozen_string_literal: true

module Twirp
  module Rails
    module Helpers
      module Services
        def self.included(klass)
          klass.extend ClassMethods
        end

        module ClassMethods
          attr_reader :base_namespace

          def twirp_namespace(namespace)
            @base_namespace = namespace.to_sym
          end

          def register_hook(hook_klass, **options)
            @base_hooks = base_hooks.push({hook_klass: hook_klass, options: options})
          end

          def base_hooks
            @base_hooks ||= []
          end

          def bind(service_klass, namespace: nil, context: nil, hooks: [])
            namespace = namespace&.to_sym || find_namespace
            if namespace.nil?
              raise ArgumentError.new(
                "namespace must be set before binding a service."
              )
            end

            hooks = hooks.map do |hook|
              if hook.is_a?(Hash)
                hook
              else
                {
                  hook_klass: hook,
                  options: {}
                }
              end
            end

            hooks = hooks + all_base_hooks

            service_wrapper = Twirp::Rails::ServiceWrapper.new(service_klass.new(new))

            Twirp::Rails.services << {service_wrapper: service_wrapper, namespace: namespace, context: context, hooks: hooks}
          end

          private

          def all_base_hooks
            self.ancestors.inject([]) do |arr, ancestor|
              arr.concat(ancestor.base_hooks) if ancestor.include?(Twirp::Rails::Helpers::Services)
              arr
            end
          end

          def find_namespace
            ancestor = self.ancestors.find do |ancestor|
              ancestor.include?(Twirp::Rails::Helpers::Services) && ancestor.base_namespace.present?
            end

            ancestor.base_namespace if ancestor.present?
          end
        end
      end
    end
  end
end
