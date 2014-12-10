require 'spec_helper'

require 'mv/core/constraints/containers/factory'

describe Mv::Core::Constraints::Containers::Factory do
  describe "#create_containers" do
    describe "#trigger" do
      describe "one route" do
        subject(:create_containers) { 
          described_class.new.create_containers(
            update_trigger_name: { type: :trigger, event: :update } 
          )
        }

        its(:length) { is_expected.to eq(1) }
        its(:first) { is_expected.to be_instance_of(Mv::Core::Constraints::Containers::Trigger) }
      end

      describe "two routes" do
        subject(:create_containers) { 
          described_class.new.create_containers(
            update_trigger_name: { type: :trigger, event: :update },
            create_trigger_name: { type: :trigger, event: :create } 
          )
        }

        its(:length) { is_expected.to eq(2) }
      end
    end    

    describe "#check" do
      subject(:create_containers) { 
        described_class.new.create_containers(check_name: { type: :check })
      }

      its(:length) { is_expected.to eq(1) }
      its(:first) { is_expected.to be_instance_of(Mv::Core::Constraints::Containers::Check) }
    end    

    describe "#index" do
      subject(:create_containers) { 
        described_class.new.create_containers(check_name: { type: :index })
      }

      its(:length) { is_expected.to eq(1) }
      its(:first) { is_expected.to be_instance_of(Mv::Core::Constraints::Containers::Index) }
    end    
  end 
end