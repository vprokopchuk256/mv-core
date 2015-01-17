require 'spec_helper'

describe Mv::Core::ActiveRecord::Migration::CommandRecorderDecorator do
  let(:recorder) { ::ActiveRecord::Migration::CommandRecorder.new }

  describe "#validates" do
    subject { recorder.validates :table_name, :column_name, length: { is: 4 } }

    it "should record validates action" do
      expect(recorder).to receive(:record).with(:validates, [:table_name, :column_name, {:length=>{:is=>4}}])
      subject
    end
  end
end