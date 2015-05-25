require 'spec_helper'

Dir[
  File.join(File.expand_path(File.dirname(__FILE__)), 'abstract_adapter_decorator/**/*.rb')
].each { |f| require f }

describe Mv::Core::ActiveRecord::ConnectionAdapters::AbstractAdapterDecorator do
  let(:original_connection) { double(:original_connection) }

  let(:wrapped_connection) do
    Class.new(SimpleDelegator) do
      prepend Mv::Core::ActiveRecord::ConnectionAdapters::AbstractAdapterDecorator
    end
  end

  subject(:conn) { wrapped_connection.new(original_connection) }

  include_examples 'abstract_adapter_decorator#add_column'
  include_examples 'abstract_adapter_decorator#remove_column'
  include_examples 'abstract_adapter_decorator#rename_column'
  include_examples 'abstract_adapter_decorator#change_column'
  include_examples 'abstract_adapter_decorator#rename_table'
  include_examples 'abstract_adapter_decorator#drop_table'
end
