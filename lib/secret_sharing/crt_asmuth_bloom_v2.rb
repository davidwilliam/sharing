# frozen_string_literal: true

# module secret sharing
module SecretSharing
  # class for second version of CRT-based secret sharing scheme
  # by Asmuth-Bloom
  class CRTAsmuthBloomV2
    include HenselCode::Tools

    attr_accessor :threshold, :secrecy, :total_shares, :primes,
                  :p, :m_r, :m_to_s, :k_add, :k_mul, :lambda_,
                  :a, :y,
                  :upperbound

    def self.add(shares1, shares2)
      shares1.zip(shares2).map { |s| [s[0][0], s[0][1] + s[1][1]] }
    end

    def self.mul(shares1, shares2)
      shares1.zip(shares2).map { |s| [s[0][0], s[0][1] * s[1][1]] }
    end

    def initialize(params = {})
      @threshold = params[:threshold]
      @secrecy = params[:secrecy]
      @total_shares = params[:total_shares]
      @k_add = params[:k_add]
      @k_mul = params[:k_mul]
      @lambda_ = params[:lambda_]
      generate_unique_primes
      compute_prime_products
      generate_single_prime
    end

    def compute_upperbound(secret)
      @upperbound = ((p * m_to_s) - secret) / p
    end

    def compute_shares(secret)
      compute_upperbound(secret)
      @a = rand(1..upperbound - 1)
      @y = secret + (a * p)
      primes.map.with_index { |prime, i| [i, y % prime] }
    end

    def reconstruct_secret(selected_shares)
      indices = selected_shares.map(&:first)
      moduli = primes.values_at(*indices)
      shares = selected_shares.map(&:last)
      y = crt(moduli, shares)
      y % p
    end

    def generate_primes
      @primes = random_distinct_numbers("prime", total_shares, lambda_)
      @primes.sort!
    end

    def compute_prime_products
      @m_r = primes[0..threshold - 1].inject(:*)
      @m_to_s = 1
      (0..secrecy - 1).each do |i|
        @m_to_s *= primes[total_shares - (i + 2) + 1]
      end
    end

    def generate_single_prime
      bits = lambda_
      @p = random_prime(lambda_)
      while m_r <= (k_add + 1) * ((@p * m_to_s)**(k_mul + 1))
        bits -= 1
        @p = random_prime(bits)
      end
    end

    def generate_unique_primes
      @primes = [random_prime(lambda_)]
      while primes.uniq.size < total_shares
        prime = random_prime(lambda_)
        @primes << prime unless @primes.include?(prime) && (@primes + [prime]).reduce(1, :gcd) != 1
      end
      @primes = @primes.uniq.sort
    end
  end
end
