# frozen_string_literal: true

module Twirp
  module Rails
    module Helpers
      module Hooks
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
        end
      end
    end
  end
end
