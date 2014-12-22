require 'mv/core/constraint/description'

module Mv
  module Core
    module Router
      class Check
        def route table_name, column_name, validation_type, options
          [Mv::Core::Constraint::Description.new(check_name(table_name, options), :check)]
        end

        protected

        def check_name table_name, options
          options.with_indifferent_access[:check_name] ||
           :"chk_mv_#{table_name}" 
        end
      end
    end
  end
end