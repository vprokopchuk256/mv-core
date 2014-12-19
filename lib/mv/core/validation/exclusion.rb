module Mv
  module Core
    module Validation
      class Exclusion
        include ActiveModel::Validations

        attr_reader :table_name, :column_name, :in, :message, :on, :create_trigger_name, 
                    :update_trigger_name, :allow_nil, :allow_blank, :as

        validates :on, inclusion: { in: :available_on }, allow_nil: true
        validates :allow_nil, :allow_blank, inclusion: { in: [true, false] }
        validates :as, inclusion: { in: :available_as }
        validates :in, presence: true

        validate :in_type, 
                 :on_allowance,
                 :create_trigger_name_allowance, 
                 :update_trigger_name_allowance

        def initialize(table_name, column_name, opts)
          @table_name = table_name
          @column_name = column_name

          opts.with_indifferent_access.tap do |opts|
            @in = opts[:in]
            @message = opts[:message] || default_message
            @as = opts[:as] || default_as
            @on = opts[:on] || default_on
            @create_trigger_name = opts[:create_trigger_name] || default_create_trigger_name
            @update_trigger_name = opts[:update_trigger_name] || default_update_trigger_name
            @allow_nil = opts[:allow_nil] || default_allow_nil
            @allow_blank = opts[:allow_blank] || default_allow_blank
          end
        end

        protected 

        def available_as
          [:trigger, :check]
        end

        def available_on 
          [:save, :update, :create]
        end

        def default_message
          "Exclusion violated on the table #{table_name} column #{column_name}"
        end

        def default_on
          :save if trigger?
        end

        def default_as
          :trigger
        end

        def default_create_trigger_name
          "trg_mv_#{table_name}_ins" if create? && trigger?
        end

        def default_update_trigger_name
          "trg_mv_#{table_name}_upd" if update? && trigger?
        end

        def default_allow_nil
          false
        end

        def default_allow_blank
          false
        end

        private

        def trigger?
          as.to_sym == :trigger
        end

        def update?
          [:save, :update].include?(on.try(:to_sym))
        end

        def create?
          [:save, :create].include?(on.try(:to_sym))
        end

        def in_type
          errors.add(:in, 'must support conversion to Array (respond to :to_a method)') unless self.in.respond_to?(:to_a)
        end

        def on_allowance  
          errors.add(:on, 'allowed when :as == :trigger') if on && !trigger? 
        end

        def create_trigger_name_allowance
          if create_trigger_name.present? &&
             (![:save, :create].include?(on.to_sym) || as.to_sym != :trigger)
            errors.add(:create_trigger_name, 'allowed when :on in [:save, :create] and :as == :trigger')
          end
        end

        def update_trigger_name_allowance
          if update_trigger_name.present? &&
             (![:save, :update].include?(on.to_sym) || as.to_sym != :trigger)
            errors.add(:update_trigger_name, 'allowed when :on in [:save, :create] and :as == :trigger')
          end
        end
      end
    end
  end
end