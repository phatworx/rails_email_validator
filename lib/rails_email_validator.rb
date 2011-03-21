# encoding:utf-8

require 'active_model'

# Validator for email
class EmailValidator < ActiveModel::EachValidator
  # check the options for do mx validation
  def validate_mx?
    options[:validate_mx].nil? or options[:validate_mx] == true
  end

  # check the options for idn support
  def allow_idn?
    options[:allow_idn].nil? or options[:allow_idn] == true
  end

  # validate if an mx exists on domain
  def has_mx?(domain)
    require 'resolv'
    mx = []
    Resolv::DNS.open do |dns|
      mx = dns.getresources(domain, Resolv::DNS::Resource::IN::MX)
    end
    not mx.nil? and mx.size > 0
  end

  # convert an unicode domain_part to asccii for validation
  def convert_idn(domain_part)
    if allow_idn?
      # idn suport if available
      begin
        require 'idn'
        # encode domain part
        return IDN::Idna.toASCII(domain_part)
      rescue LoadError
      rescue IDN::Idna::IdnaError
      end
    end
    domain_part
  end

  # main validator for email
  def validate_each(record, attribute, value)
    unless value.blank?

      # pre var
      valid = true
      local_part = nil
      domain_part = nil

      if valid
        # split local and domain part
        (local_part, domain_part) = value.to_s.split('@', 2)
      end

      domain_part = convert_idn domain_part

      if valid
        # check syntax
        valid = false unless local_part =~ /\A[a-z0-9!\#$%&'*+\/=?^_`{|}~-]+(?:\.[a-z0-9!\#$%&'*+\/=?^_`{|}~-]+)*\Z/
        valid = false unless domain_part =~ /\A(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\Z/
      end

      # check mx
      if valid and validate_mx?
        valid = false unless has_mx? domain_part
      end

      # email valid
      record.errors.add(attribute, :invalid) unless valid
    end
  end
end
