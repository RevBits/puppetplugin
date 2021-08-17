# frozen_string_literal: true

require 'revbits/puppet_module/http'
require 'revbits/puppet_module/secure'

# Puppet function to fetch secret from server
Puppet::Functions.create_function :'puppetplugin::secret' do
  dispatch :with_credentials do
    required_param 'String', :variable_id
    optional_param 'Hash', :options

    return_type 'Sensitive'
  end

  def get_variable_from_pam(url, variable_id, api_key, public_key_a, public_key_b)
    Revbits::PuppetModule::HTTP.get(url, variable_id, api_key, public_key_a, public_key_b)
  end

  def with_credentials(id, options = {})
    opts = options.dup

    secret_creators = {
      prime: 23,
      generated: 9,
    }

    if opts['api_key']
      raise "Please wrap the 'api_key' in Sensitive()'!" \
        unless opts['api_key'].is_a? Puppet::Pops::Types::PSensitiveType::Sensitive
    end

    if opts['appliance_url'].nil? || opts['appliance_url'].empty?
      raise "No 'appliance_url' provided"
    end

    private_key_a, private_key_b = Revbits::PuppetModule::Secure.private_keys

    public_key_a, public_key_b = Revbits::PuppetModule::Secure.public_keys(private_key_a, private_key_b, secret_creators)

    encrypted_values = get_variable_from_pam(opts['appliance_url'], id, opts['api_key'], public_key_a, public_key_b)

    secret = Revbits::PuppetModule::Secure.secret(encrypted_values, private_key_a, private_key_b, secret_creators)

    value = Revbits::PuppetModule::Secure.decrypt(secret, encrypted_values.dig('value'))

    Puppet::Pops::Types::PSensitiveType::Sensitive.new(value)
  end
end
