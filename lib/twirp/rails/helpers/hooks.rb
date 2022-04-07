# frozen_string_literal: true

module Twirp
  module Rails
    module Helpers
      module Hooks
        HOOK_METHODS = [:before, :on_success, :on_error, :exception_raised]

        def self.included(klass)
          klass.extend ClassMethods
        end

        module ClassMethods
          def register_hook(namespace, key)
            Twirp::Rails.hooks[namespace] ||= {}

            if Twirp::Rails.hooks.dig(namespace, key).present?
              raise ArgumentError.new(
                "A hook with the key #{key} has already been registered under the #{namespace} namespace"
              )
            end

            if Twirp::Rails.hooks[namespace].values.include?(self)
              raise ArgumentError.new(
                "#{self} is already registered."
              )
            end

            Twirp::Rails.hooks[namespace][key] = self
          end

          def attach(service)
            hook_instance = self.new

            unless HOOK_METHODS.any? {|method| hook_instance.respond_to?(method)}
              raise NotImplementedError.new(
                "#{self.name} must implement one of the following methods: #{HOOK_METHODS.join(", ")}"
              )
            end

            if hook_instance.respond_to?(:before)
              service.before do |rack_env, env|
                hook_instance.before(rack_env, env)
              end
            end

            if hook_instance.respond_to?(:on_success)
              service.on_success do |env|
                hook_instance.on_success(env)
              end
            end

            if hook_instance.respond_to?(:on_error)
              service.on_error do |twerr, env|
                hook_instance.on_error(twerr, env)
              end
            end

            if hook_instance.respond_to?(:exception_raised)
              service.exception_raised do |e, env|
                hook_instance.exception_raised(e, env)
              end
            end
          end
        end
      end
    end
  end
end
