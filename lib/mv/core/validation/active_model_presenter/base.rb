module Mv
  module Core
    module Validation
      module ActiveModelPresenter
        class Base
          attr_reader :validation

          delegate :column_name, to: :validation

          def initialize(validation)
            @validation = validation
          end
          
          def options
            unless @options
              @options = option_names.inject({}) do |res, option_name|
                option_value = validation.send(option_name)
                res[option_name] = option_value if user_options.has_key?(option_name) && 
                                                    !option_value.nil?
                res
              end

              @options = true if @options.blank?
              @options = { validation_name => @options }
            end

            @options
          end

          def option_names
            [:on, :allow_blank, :allow_nil, :message]
          end


          private

          def user_options
            @user_options ||= validation.options.symbolize_keys
          end
        end
      end
    end
  end
end