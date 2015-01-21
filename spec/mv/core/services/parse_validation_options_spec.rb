require 'spec_helper'

require 'mv/core/services/parse_validation_options'

describe Mv::Core::Services::ParseValidationOptions do
  subject(:service) { described_class.new(opts) }

  describe "#initialize" do
    let(:opts) { { validates: { presence: true } } }
    
    its(:opts) { is_expected.to eq(opts) }
  end

  describe "#execute" do
    subject { service.execute } 

    describe "validates" do
      let(:opts) { { validates: { presence: true } } }

      it { is_expected.to eq(presence: true) }

      it "deletes handled parameters" do
        subject
        expect(opts).to be_empty
      end
    end

    describe "validates as string" do
      let(:opts) { { "validates" => { presence: true } } }

      it { is_expected.to eq(presence: true) }

      it "deletes handled parameters" do
        subject
        expect(opts).to be_empty
      end
    end

    describe "validates with simplification" do
      let(:opts) { { validates: '{column_name} > 1' } }

      it { is_expected.to eq(custom: '{column_name} > 1') }
    end

    describe "simplifications are defined" do
      let(:opts) do
        { absence: true, 
          custom: '{column_name} > 1', 
          exclusion: 1..2, 
          inclusion: 1..2, 
          length: 1..3, 
          presence: true, 
          uniqueness: true, 
          not_known_validation: true } 
      end

      it { is_expected.to eq({uniqueness: true, 
                              exclusion: 1..2,
                              inclusion: 1..2,
                              length: 1..3,
                              presence: true,
                              absence: true,
                              custom: "{column_name} > 1"}) }

      it "deletes handled parameters" do
        subject
        expect(opts).to eq(not_known_validation: true)
      end
    end

    describe "string simplifications are defined" do
      let(:opts) do
        { 'absence' => true, 
          'custom' => '{column_name} > 1', 
          'exclusion' => 1..2, 
          'inclusion' => 1..2, 
          'length' => 1..3, 
          'presence' => true, 
          'uniqueness' => true, 
          'not_known_validation' => true } 
      end

      it { is_expected.to eq({uniqueness: true, 
                              exclusion: 1..2,
                              inclusion: 1..2,
                              length: 1..3,
                              presence: true,
                              absence: true,
                              custom: "{column_name} > 1"}) }

      it "deletes handled parameters" do
        subject
        expect(opts).to eq('not_known_validation' => true)
      end
    end
  end
end