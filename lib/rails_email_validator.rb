
require 'active_model'

class EmailValidator < ActiveModel::EachValidator
  # check the options for do mx validation
  def validate_mx?
    options[:validate_mx].nil? or options[:validate_mx] == true
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

  # main validator for email
  def validate_each(record, attribute, value)
    unless value.blank?
      # split local and domain part
      (local_part, domain_part) = value.split('@', 2)

      # pre var
      valid = true

      # check syntax
      valid = false unless local_part =~ /\A[A-Za-z0-9.!\#$%&'*+-\/=?^_`{|}~]+\Z/
      valid = false unless domain_part =~ /\A((?:[-a-zA-Z0-9]+\.)+[a-zA-Z]{2,})\Z/

      # check mx
      if valid and validate_mx?
        valid = false unless has_mx? domain_part
      end

      # email valid
      record.errors.add(attribute, :invalid) unless valid
    end
  end
end
