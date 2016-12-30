require_relative 'base'

module Mv
  module Core
    module Validation
      class Uniqueness < Base
        include ActiveModel::Validations

        attr_reader :index_name

        validates :index_name, absence: { message: 'allowed when :as == :index' }, unless: :index?

        def initialize(table_name, column_name, opts)
          opts = opts == true ? {} : opts

          super(table_name, column_name, opts)

          @index_name = opts.with_indifferent_access[:index_name] || default_index_name
        end

        def to_a
          super + [index_name.to_s]
        end

        protected

        def available_as
          super + [:index]
        end

        def default_as
          :index
        end

        def default_index_name
          "idx_mv_#{table_name}_#{column_name}_uniq" if index?
        end

        def default_message
          'is not unique'
        end

        private

        def index?
          as.to_sym == :index
        end
      end
    end
  end
end
