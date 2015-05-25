module Mv
  module Core
    module ActiveRecord
      module ConnectionAdapters
        module Decorators
          module PredefinedEmail
            class Preprocessor
              attr_reader :opts, :validates

              def initialize opts
                @opts = opts
                @validates = opts.delete(:validates) || opts.delete('validates') || {}
              end

              def execute
                handle_column_level_email
                add_null_dependency
                convert_email_validation_to_format

                opts[:validates] = validates if validates.present?
              end

              private

              def handle_column_level_email
                return if (email = (opts.delete(:email) || opts.delete('email'))).nil?

                validates.merge!(email: email)
              end

              def add_null_dependency
                if (email = validates.delete(:email) || validates.delete('email')).present?
                  if opts.fetch(:null, true) && opts.fetch('null', true)
                    email = {} if email == true

                    unless email.key?(:allow_nil) || email.key?('allow_nil')
                      email[:allow_nil] = true
                    end
                  end

                  validates[:email] = email
                end
              end

              def convert_email_validation_to_format
                if (email = validates.delete(:email) || validates.delete('email')).present?

                  email.merge!(with: EMAIL_REGEXP) if email.is_a?(Hash)
                  email = EMAIL_REGEXP if email == true

                  validates[:format] = email
                end
              end
            end

            EMAIL_REGEXP = //

            def add_column table_name, column_name, type, opts
              if type.to_sym == :email
                type = :string
                opts.to_h.merge!(email: true)
              end

              Preprocessor.new(opts).execute if opts.present?

              super table_name, column_name, type, opts
            end
          end
        end
      end
    end
  end
end
