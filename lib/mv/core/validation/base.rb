module Mv
  module Core
    module Validation
      class Base
        include Comparable
        include ActiveModel::Validations

        attr_reader :table_name, :column_name, :message, :on, :create_trigger_name, 
                    :update_trigger_name, :allow_nil, :allow_blank, :as, :options

        validates :on, inclusion: { in: :available_on }, allow_nil: true
        validates :allow_nil, :allow_blank, inclusion: { in: [true, false] }
        validates :as, inclusion: { in: :available_as }

        validates :on, absence: { message: 'allowed when :as == :trigger' }, unless: :trigger?
        validates :create_trigger_name, absence: { message: 'allowed when :on in [:save, :create] and :as == :trigger'}, unless: "create? && trigger?"
        validates :update_trigger_name, absence: { message: 'allowed when :on in [:save, :update] and :as == :trigger'}, unless: "update? && trigger?"

        def initialize table_name, column_name, options
          @table_name = table_name
          @column_name = column_name
          @options = options

          options.with_indifferent_access.tap do |options|
            @message = options[:message] || default_message
            @as = options[:as] || default_as
            @on = options[:on] || default_on
            @create_trigger_name = options[:create_trigger_name] || default_create_trigger_name
            @update_trigger_name = options[:update_trigger_name] || default_update_trigger_name
            @allow_nil = options[:allow_nil].nil? ? default_allow_nil : options[:allow_nil]
            @allow_blank = options[:allow_blank].nil? ? default_allow_blank : options[:allow_blank]
          end
        end

        def to_a
          [table_name.to_s, column_name.to_s, message.to_s, on.to_s, create_trigger_name.to_s, 
           update_trigger_name.to_s, allow_nil, allow_blank, as.to_s]
        end

        def <=> other_validation
          [self.class.name, to_a] <=> [other_validation.class.name, other_validation.to_a]
        end
        
        def update?
          [:save, :update].include?(on.try(:to_sym))
        end

        def create?
          [:save, :create].include?(on.try(:to_sym))
        end

        def full_message 
          compose_full_message(message)
        end

        protected 

        def available_as
          [:trigger]
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

        def compose_full_message message
          "#{column_name.to_s.camelize} #{message}"
        end

        private

        def trigger?
          as.try(:to_sym) == :trigger
        end
      end
    end
  end
end