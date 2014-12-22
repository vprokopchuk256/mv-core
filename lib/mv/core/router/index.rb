module Mv
  module Core
    module Router
      class Index
        def route table_name, column_name, validation_type, options
          [[index_name(table_name, column_name, options), :index,  {}]]
        end

        protected

        def index_name table_name, column_name, options
          options.with_indifferent_access[:index_name] ||
           :"idx_mv_#{table_name}_#{column_name}_uniq" 
        end
      end
    end
  end
end