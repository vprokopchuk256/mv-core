module MigrationValidators
  module Core
    class ValidatorConstraintsList
      attr_reader :raw_list

      def initialize *constraints
        @raw_list = constraints.collect(&:to_s)
      end

      def add constraint
        @raw_list << constraint.to_s
        @raw_list.uniq!
      end

      def remove constraint
        @raw_list.delete(constraint.to_s)
      end

      def include? constraint
        @raw_list.include?(constraint.to_s)
      end

      def self.load(raw_list)
        new(*(YAML.load(raw_list || "") || []))
      end

      def self.dump(list)
        YAML.dump(list.raw_list)
      end
    end
  end
end