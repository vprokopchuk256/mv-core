module MigrationValidators
  @migration_validators_table_name = :migration_validators

  class << self
    attr_accessor :migration_validators_table_name
  end
end
