
class EmailValidation
  # check the options for do mx validation
  def self.validate_mx?(options)
    options[:validate_mx].nil? or options[:validate_mx] == true
  end

  # check the options for idn support
  def self.allow_idn?(options)
    options[:allow_idn].nil? or options[:allow_idn] == true
  end

  # validate if an mx exists on domain
  def self.has_mx?(domain)
    require 'resolv'
    mx = []
    Resolv::DNS.open do |dns|
      mx = dns.getresources(domain, Resolv::DNS::Resource::IN::MX)
    end
    not mx.nil? and mx.size > 0
  end

  # convert an unicode domain_part to asccii for validation
  def self.convert_idn(domain_part, options)
    if allow_idn?(options)
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
  
  def self.is_valid?(value, options={})
    return false if value.blank?
    
    # pre var
    valid = true
    local_part = nil
    domain_part = nil

    if valid
      # split local and domain part
      (local_part, domain_part) = value.to_s.split('@', 2)
    end

    domain_part = convert_idn(domain_part, options)

    if valid
      # check syntax
      valid = false unless local_part =~ /\A[a-z0-9!\#$%&'*+\/=?^_`{|}~-]+(?:\.[a-z0-9!\#$%&'*+\/=?^_`{|}~-]+)*\Z/i
      valid = false unless domain_part =~ /\A(?:[a-z0-9](?:[_a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\Z/i
    end

    # check mx
    if valid and validate_mx?(options)
      valid = false unless has_mx? domain_part
    end
    
    valid
  end
end