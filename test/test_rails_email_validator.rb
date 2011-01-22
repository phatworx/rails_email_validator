# encoding: utf-8

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

class ValidateEmailDisabledIdm
  include ActiveModel::Validations
  attr_accessor :email
  validates :email, :email => {:allow_idn => false}
end


class TestRailsEmailValidator < Test::Unit::TestCase


  def test_valid_emails_with_mx_validation
    model = ValidateEmailWithMx.new

    [
        'test@marco-scholl.de'
    ].each do |email|

      model.email = email
      assert model.valid?, ">>#{email}<<"

    end
  end

  def test_invalid_emails_with_mx_validation
    model = ValidateEmailWithMx.new

    [
        'test@invalidmx.marco-scholl.de'
    ].each do |email|

      model.email = email
      assert !model.valid?, ">>#{email}<<"

    end
  end


  def test_valid_emails_without_mx_validation
    model = ValidateEmailWithoutMx.new

    [
        nil,
        '',
        ' ',
        'test@example.net',
        'test@sub1.example.net',
        'test@sub1.example.co.uk',
        'test@sub2.sub1.example.net',
        'test@sub2.sub1.example.tttttttt',
        'test@mexample.net.'
    ].each do |email|

      model.email = email
      assert model.valid?, ">>#{email}<<"

    end
  end

  def test_invalid_emails_without_mx_validation
    model = ValidateEmailWithoutMx.new

    [
        1.2,
        1,
        'email',
        'test@localhost',
        'müller@example.net',
        'test@example.net..'
    ].each do |email|

      model.email = email
      assert !model.valid?, ">>#{email}<<"

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
      assert model.valid?, ">>#{email}<<"
    end
  end

  def test_idn_with_disabled_idn_support
    model = ValidateEmailDisabledIdm.new

    [
        'mueller@müller.de',
        'test@räksmörgås.nu',
        'test@sub1.räksmörgås.nu',
        'test@xn--rksmrgs-5wao1o.nu',
        'test@sub1.xn--rksmrgs-5wao1o.nu'
    ].each do |email|

      model.email = email
      assert !model.valid?, ">>#{email}<<"
    end
  end


end
