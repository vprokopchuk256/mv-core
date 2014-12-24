require 'mv/core/validation/base'

module Mv
  module Core
    module Validation
      class Uniqueness < Base
        include ActiveModel::Validations

        attr_reader :index_name

        validate :index_name_allowance

        def initialize(table_name, column_name, opts)
          super(table_name, column_name, opts)
          
          @index_name = opts.with_indifferent_access[:index_name] || default_index_name
        end

        def to_a
          super + [index_name.to_s]
        end

        protected 

        def available_as
          [:trigger, :check, :index]
        end

        def default_as
          :index
        end

        def default_index_name
          "idx_mv_#{table_name}_#{column_name}_uniq" if index?
        end

        private

        def index?
          as.to_sym == :index
        end

        def index_name_allowance
          if index_name.present? && as.to_sym != :index
            errors.add(:create_trigger_name, 'allowed when :as == :index')
          end
        end
      end
    end
  end
end