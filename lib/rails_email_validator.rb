# encoding:utf-8

require 'active_model'
require 'email_validation'

# Validator for email
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.blank?
      EmailValidation.is_valid?(value, options)

      # email valid
      record.errors.add(attribute, :invalid) unless EmailValidation.is_valid?(value, options)
    end
  end
end
