module Mv
  module Core
    class Error < StandardError
      attr_reader :table_name, :column_name, :validator_name, :options, :error

      def initialize(opts = {})
        opts = opts.with_indifferent_access

        @table_name = opts[:table_name]
        @column_name = opts[:column_name]
        @validator_name = opts[:validator_name]
        @options = opts[:options]
        @error = opts[:error]

        super [
          @table_name ? "table: '#{@table_name}'" : nil,
          @column_name ? "column: '#{@column_name}'" : nil, 
          @validator_name ? "validator: '#{@validator_name}'" : nil, 
          @options ? "options: '#{@options}'" : nil, 
          @error ? "error: '#{@error}'" : nil, 
        ].compact.join(', ')
      end
    end
  end
end