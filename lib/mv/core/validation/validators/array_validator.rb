class ArrayValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(:attribute, 'must support conversion to Array (respond to :to_a method)') unless value.respond_to?(:to_a)
  end
end       