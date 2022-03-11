# frozen_string_literal: true

module SecretSharing
  # CRT-based secret sharing
  class CRT
    include HenselCode::Tools

    attr_accessor :total_number_of_shares, :threshold, :primes, :bits,
                  :prime_product_1, :prime_product_2

    def initialize(total_number_of_shares, threshold, bits)
      @total_number_of_shares = total_number_of_shares
      @threshold = threshold
      @bits = bits
      generate_primes
    end

    def generate_shares(secret)
      alpha_min = (prime_product_1 - secret)/primes[0]
      alpha_max = (prime_product_2 - secret)/primes[0]
      alpha = rand(alpha_min..alpha_max)
      x = secret + alpha * primes[0]
      primes[1..-1].map.with_index{|prime,i| [i, x % prime] }
    end

    def reconstruct_secret(selected_shares)
      selected_primes = primes[1..-1].values_at(*(selected_shares.map{|s| s[0] }))
      crt(selected_primes, selected_shares.map(&:last)) % primes[0]
    end

    private

    def generate_primes
      while true
        @primes = random_distinct_primes(total_number_of_shares, bits)
        compute_prime_products
        break if shares_secrecy_condition
      end
    end

    def compute_prime_products
      index = total_number_of_shares - threshold + 2
      @prime_product_1 = @primes[0] * @primes[index..-1].reduce(:*)
      @prime_product_2 = @primes[1..threshold].reduce(:*)
    end

    def shares_secrecy_condition
      prime_product_1 < prime_product_2
    end

    def crt(mods, remainders)
      max = mods.inject( :* )
      series = remainders.zip(mods).map{ |r,m| (r * max * mod_inverse(max/m, m) / m) }
      series.inject( :+ ) % max
    end
  end
end