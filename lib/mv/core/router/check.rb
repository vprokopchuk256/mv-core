module Mv
  module Core
    module Router
      class Check
        def route validator
          { check_name(validator) => { type: :check } }
        end

        protected

        def check_name validator
          validator.options.with_indifferent_access[:check_name] ||
           :"chk_#{validator.table_name}" 
        end
      end
    end
  end
end