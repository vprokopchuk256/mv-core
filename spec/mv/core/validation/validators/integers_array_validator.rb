class IntegersArrayValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.respond_to?(:to_a)
      record.errors.add(:attribute, 
                        'must contain positive integers only') unless value.to_a.all?{|v| v.kind_of?(Integer) && v >=0  }

    else
      record.errors.add(:attribute, 
                        'must support conversion to Array (respond to :to_a method)') unless value.respond_to?(:to_a)
    end
  end
end       
