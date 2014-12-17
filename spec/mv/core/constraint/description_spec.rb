require 'spec_helper'

require 'mv/core/constraint/description'

describe Mv::Core::Constraint::Description do
  subject { described_class.new(:name, :type, { event: :create })}

  describe '#initialize' do
    its(:name) { is_expected.to eq(:name) }
    its(:type) { is_expected.to eq(:type) }
    its(:options) { is_expected.to eq({event: :create}) }
  end

  describe '==' do
    it { is_expected.to eq(described_class.new('name', 'type', { 'event' => 'create' }))} 
    it { is_expected.not_to eq(described_class.new('name', 'type', { 'event' => 'update' }))} 
  end

  describe 'to_a' do
    its(:to_a) { is_expected.to eq([:name, :type, {event: :create}])}
  end
end