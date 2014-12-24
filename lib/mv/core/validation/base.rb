module Mv
  module Core
    module Validation
      class Base
        include Comparable
        include ActiveModel::Validations

        attr_reader :table_name, :column_name, :message, :on, :create_trigger_name, 
                    :update_trigger_name, :allow_nil, :allow_blank, :as, :check_name

        validates :on, inclusion: { in: :available_on }, allow_nil: true
        validates :allow_nil, :allow_blank, inclusion: { in: [true, false] }
        validates :as, inclusion: { in: :available_as }

        validate :on_allowance,
                 :create_trigger_name_allowance, 
                 :update_trigger_name_allowance, 
                 :check_name_allowance

        def initialize table_name, column_name, opts
          @table_name = table_name
          @column_name = column_name

          opts.with_indifferent_access.tap do |opts|
            @message = opts[:message] || default_message
            @as = opts[:as] || default_as
            @on = opts[:on] || default_on
            @create_trigger_name = opts[:create_trigger_name] || default_create_trigger_name
            @update_trigger_name = opts[:update_trigger_name] || default_update_trigger_name
            @allow_nil = opts[:allow_nil] || default_allow_nil
            @allow_blank = opts[:allow_blank] || default_allow_blank
            @check_name = opts[:check_name] || default_check_name
          end
        end

        def to_a
          [table_name.to_s, column_name.to_s, message.to_s, on.to_s, create_trigger_name.to_s, 
           update_trigger_name.to_s, allow_nil, allow_blank, as.to_s, check_name.to_s]
        end

        def <=> other_validation
          [self.class, to_a] <=> [other_validation.class, other_validation.to_a]
        end
        
        def update?
          [:save, :update].include?(on.try(:to_sym))
        end

        def create?
          [:save, :create].include?(on.try(:to_sym))
        end

        protected 

        def available_as
          [:trigger, :check]
        end

        def available_on 
          [:save, :update, :create]
        end

        def default_message
          "#{self.class.name.split('::').last} violated on the table #{table_name} column #{column_name}"
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

        def default_check_name
          "chk_mv_#{table_name}_#{column_name}"  if check?
        end

        private

        def check?
          as.try(:to_sym) == :check
        end

        def trigger?
          as.try(:to_sym) == :trigger
        end

        def on_allowance  
          errors.add(:on, 'allowed when :as == :trigger') if on && !trigger? 
        end

        def create_trigger_name_allowance
          if create_trigger_name.present? &&
             !(create? && trigger?)
            errors.add(:create_trigger_name, 'allowed when :on in [:save, :create] and :as == :trigger')
          end
        end

        def update_trigger_name_allowance
          if update_trigger_name.present? &&
             !(update? && trigger?)
            errors.add(:update_trigger_name, 'allowed when :on in [:save, :create] and :as == :trigger')
          end
        end

        def check_name_allowance
          if check_name.present? && !check?
            errors.add(:check_name, 'allowed when :as == :trigger')
          end
        end
      end
    end
  end
end