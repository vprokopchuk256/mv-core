module Mv
  module Core
    class Error < StandardError
      attr_reader :table_name, :column_name, :validation_type, :options, :error

      def initialize(opts = {})
        opts = opts.with_indifferent_access

        @table_name = opts[:table_name]
        @column_name = opts[:column_name]
        @validation_type = opts[:validation_type]
        @options = opts[:options]
        @error = opts[:error]

        super [
          @table_name ? "table: '#{@table_name}'" : nil,
          @column_name ? "column: '#{@column_name}'" : nil, 
          @validation_type ? "validator: '#{@validation_type}'" : nil, 
          @options ? "options: '#{@options}'" : nil, 
          @error ? "error: '#{@error}'" : nil, 
        ].compact.join(', ')
      end
    end
  end
end