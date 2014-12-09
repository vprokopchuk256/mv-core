module Mv
  module Core
    module Router
      class Index
        def route validator
          { index_name(validator) => { type: :index } }
        end

        protected

        def index_name validator
          validator.options.with_indifferent_access[:index_name] ||
           :"idx_#{validator.table_name}_#{validator.column_name}_uniq" 
        end
      end
    end
  end
end