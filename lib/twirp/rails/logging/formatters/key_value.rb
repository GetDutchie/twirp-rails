# frozen_string_literal: true

module Twirp
  module Rails
    module Logging
      module Formatters
        class KeyValue
          def call(data)
            fields_to_display(data)
              .map { |key| format(key, data[key]) }
              .join(' ')
          end

          protected

          def fields_to_display(data)
            data.keys
          end

          def format(key, value)
            "#{key}=#{parse_value(key, value)}"
          end

          def parse_value(key, value)
            return Kernel.format('%.2f', value) if value.is_a? Float

            value
          end
        end
      end
    end
  end
end
