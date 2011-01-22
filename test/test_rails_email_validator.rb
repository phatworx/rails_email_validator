# encoding:utf-8

require 'helper'

class ValidateEmailWithMx
  include ActiveModel::Validations
  attr_accessor :email
  validates :email, :email => true
end

class ValidateEmailWithoutMx
  include ActiveModel::Validations
  attr_accessor :email
  validates :email, :email => {:validate_mx => false}
end

class TestRailsEmailValidator < Test::Unit::TestCase


  def test_valid_emails_with_mx_validation
    model = ValidateEmailWithMx.new

    [
        'test@marco-scholl.de'
    ].each do |email|

      model.email = email
      assert model.valid?, "invalid email >>#{email}<<"

    end
  end

  def test_invalid_emails_with_mx_validation
    model = ValidateEmailWithMx.new

    [
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
        'test@sub1.marco-scholl.de',
        'test@sub2.sub1.marco-scholl.de',
        'test@marco-scholl.de.'
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
        'email',
        'müller@test.de',
        'test@marco-scholl.de..'
    ].each do |email|

      model.email = email
      assert !model.valid?, "valid email >>#{email}<<"

    end
  end

  def test_idn_adresses
    model = ValidateEmailWithoutMx.new

    [
        'mueller@müller.de',
        'test@räksmörgås.nu',
        'test@sub1.räksmörgås.nu',
        'test@xn--rksmrgs-5wao1o.nu',
        'test@sub1.xn--rksmrgs-5wao1o.nu'
    ].each do |email|

      model.email = email
      assert model.valid?, "invalid email >>#{email}<<"
    end
  end


end
