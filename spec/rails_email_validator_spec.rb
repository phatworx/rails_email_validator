# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe EmailValidator do
  before do
    class ValidateEmail
      include ActiveModel::Validations
      attr_accessor :email
    end
  end

  describe "default email validation" do

    before do
      class ValidateDefaultEmail < ValidateEmail
        validates :email, :email => true
      end
      @object = ValidateDefaultEmail.new
    end

    describe "email validation with valid mx host" do

      it "should validate without errors" do
        [
            'test@marco-scholl.de'
        ].each do |email|

          @object.email = email
          @object.should be_valid

        end
      end

    end

    describe "email validation with invalid mx host" do
      it "should validate with errors" do
        [
            'test@invalidmx.marco-scholl.de'
        ].each do |email|

          @object.email = email
          @object.should_not be_valid

        end
      end
    end
  end

  describe "email vaildation with disabled mx check" do
    before do
      class ValidateEmailWithoutMx < ValidateEmail
        validates :email, :email => {:validate_mx => false}
      end
      @object = ValidateEmailWithoutMx.new
    end

    describe "valid email validation" do

      it "should validate without errors" do
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

          @object.email = email
          @object.should be_valid

        end
      end

    end

    describe "invalid email validation" do
      it "should validate with errors" do

        [
            1.2,
            1,
            'email',
            'test@localhost',
            'müller@example.net',
            'test@example.net..'
        ].each do |email|

          @object.email = email
          @object.should_not be_valid

        end
      end
    end

    describe "valid email validation with idn domains" do
      it "should validate without errors" do
        [
            'mueller@müller.de',
            'test@räksmörgås.nu',
            'test@sub1.räksmörgås.nu',
            'test@xn--rksmrgs-5wao1o.nu',
            'test@sub1.xn--rksmrgs-5wao1o.nu'
        ].each do |email|

          @object.email = email
          @object.should be_valid
        end
      end
    end

  end

  describe "email vaildation with disabled idn support" do
    before do
      class ValidateEmailDisabledIdm < ValidateEmail
        validates :email, :email => {:allow_idn => false}
      end
      @object = ValidateEmailDisabledIdm.new
    end

    describe "valid email with idn domain" do
      it "should validate with errors" do
        [
            'mueller@müller.de',
            'test@räksmörgås.nu',
            'test@sub1.räksmörgås.nu',
            'test@xn--rksmrgs-5wao1o.nu',
            'test@sub1.xn--rksmrgs-5wao1o.nu'
        ].each do |email|

          @object.email = email
          @object.should_not be_valid
        end
      end
    end
  end

end

