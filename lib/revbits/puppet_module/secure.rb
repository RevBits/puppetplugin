# frozen_string_literal: true

require 'aes-everywhere'

module Revbits
  module PuppetModule
    # Module responsible for decrypting data coming from 'PAM'
    module Secure
      class << self
        def private_keys
          # key_a, key_b
          [rand(2..9), rand(2..9)]
        end

        def public_keys(private_key_a, private_key_b, secret_creators)
          [public_key_a(private_key_a, secret_creators), public_key_b(private_key_b, secret_creators)]
        end

        def secret(encrypted_values, private_key_a, private_key_b, secret_creators)
          shared_key_a = shared_key_a(encrypted_values.dig('keyA'), private_key_a, secret_creators.dig(:prime))
          shared_key_b = shared_key_b(encrypted_values.dig('keyB'), private_key_b, secret_creators.dig(:prime))

          shared_key_a**shared_key_b
        end

        def decrypt(secret, encrypted_value)
          AES256.decrypt(encrypted_value.to_s, secret.to_s)
        end

        private

        def shared_key_a(key_a, private_key_a, prime)
          (key_a**private_key_a) % prime
        end

        def shared_key_b(key_b, private_key_b, prime)
          (key_b**private_key_b) % prime
        end

        def public_key_a(public_key_a, secret_creators)
          (secret_creators.dig(:generated)**public_key_a) % secret_creators.dig(:prime)
        end

        def public_key_b(public_key_b, secret_creators)
          (secret_creators.dig(:generated)**public_key_b) % secret_creators.dig(:prime)
        end
      end
    end
  end
end
