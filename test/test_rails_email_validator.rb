require 'helper'

class ValidateEmailWithMx
  include ActiveModel::Validations
  attr_accessor :email
  validates :email, :email => true
end

class ValidateEmailWithoutMx
  include ActiveModel::Validations
  attr_accessor :email
  validates :email, :email => { :validate_mx => false }
end

class TestRailsEmailValidator < Test::Unit::TestCase


  def test_valid_emails_with_mx_validation
    model = ValidateEmailWithMx.new

    [
        nil,
        '',
        ' ',
        'test@marco-scholl.de'
    ].each do |email|

      model.email = email
      assert model.valid?, "invalid email >>#{email}<<"

    end
  end

  def test_invalid_emails_with_mx_validation
    model = ValidateEmailWithMx.new

    [
        1.2,
        1,
        'email',
        'test@invalidmx.marco-scholl.de'
    ].each do |email|

      model.email = email
      assert !model.valid?, "valid email >>#{email}<<"

    end
  end


  def test_valid_emails_without_mx_validation
    model = ValidateEmailWithoutMx.new

    [
        nil,
        '',
        ' ',
        'test@marco-scholl.de',
        'test@invalidmx.marco-scholl.de'
    ].each do |email|

      model.email = email
      assert model.valid?, "invalid email >>#{email}<<"

    end
  end

  def test_invalid_emails_without_mx_validation
    model = ValidateEmailWithoutMx.new

    [
        1.2,
        1,
        'email'
    ].each do |email|

      model.email = email
      assert !model.valid?, "valid email >>#{email}<<"

    end
  end


end
