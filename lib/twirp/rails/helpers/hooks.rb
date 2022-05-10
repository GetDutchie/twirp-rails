# frozen_string_literal: true

module Twirp
  module Rails
    module Helpers
      module Hooks
        HOOK_METHODS = [:before, :on_success, :on_error, :exception_raised]

        def self.included(klass)
          klass.extend ClassMethods
        end

        attr_reader :service_wrapper, :options

        def initialize(service_wrapper, only: [], except: [], **options)
          @service_wrapper = service_wrapper
          @options = options
          @only = only
          @except = except
        end

        def bypass?(env)
          return true if @only.present? && !@only.include?(env[:ruby_method])
          return true if @except.present? && @except.include?(env[:ruby_method])
          false
        end

        module ClassMethods
          def attach(service_wrapper, only: [], except: [], **options)
            hook_instance = self.new(service_wrapper, only: only, except: except, **options)

            unless HOOK_METHODS.any? {|method| hook_instance.respond_to?(method)}
              raise NotImplementedError.new(
                "#{self.name} must implement one of the following methods: #{HOOK_METHODS.join(", ")}"
              )
            end

            if hook_instance.respond_to?(:before)
              service_wrapper.before do |rack_env, env|
                next if hook_instance.bypass?(env)
                hook_instance.before(rack_env, env)
              end
            end

            if hook_instance.respond_to?(:on_success)
              service_wrapper.on_success do |env|
                next if hook_instance.bypass?(env)
                hook_instance.on_success(env)
              end
            end

            if hook_instance.respond_to?(:on_error)
              service_wrapper.on_error do |twerr, env|
                next if hook_instance.bypass?(env)
                hook_instance.on_error(twerr, env)
              end
            end

            if hook_instance.respond_to?(:exception_raised)
              service_wrapper.exception_raised do |e, env|
                next if hook_instance.bypass?(env)
                hook_instance.exception_raised(e, env)
              end
            end

            hook_instance
          end
        end
      end
    end
  end
end
