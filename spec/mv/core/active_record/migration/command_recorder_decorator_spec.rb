require 'spec_helper'

require 'mv/core/active_record/migration/command_recorder_decorator'

describe Mv::Core::ActiveRecord::Migration::CommandRecorderDecorator do
  before do
    ::ActiveRecord::Migration::CommandRecorder.send(:prepend, described_class)
  end

  let(:recorder) { ::ActiveRecord::Migration::CommandRecorder.new }

  describe "#validates" do
    subject { recorder.validates :table_name, :column_name, length: { is: 4 } }

    it "should record validates action" do
      expect(recorder).to receive(:record).with(:validates, [:table_name, :column_name, {:length=>{:is=>4}}])
      subject
    end
  end
end