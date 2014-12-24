class ValidValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.invalid?
      value.errors.full_messages.each do |message|
        record.errors.add(:validation, message)
      end
    end
  end
end       