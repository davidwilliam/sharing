# frozen_string_literal: true

module SecretSharing
  module Polynomial
    module Shamir
      # first supported version of Shamir secret sharing scheme
      class V1
        include HenselCode::Tools
        extend HenselCode::Tools
        include Tools
        extend Tools

        attr_accessor :lambda_, :p, :total_shares, :threshold

        def self.add(shares1, shares2, prime)
          shares1.zip(shares2).map { |s| [s[0][0], (s[0][1] + s[1][1]) % prime] }
        end

        def self.sub(shares1, shares2, prime)
          shares1.zip(shares2).map { |s| [s[0][0], (s[0][1] - s[1][1]) % prime] }
        end

        def self.smul(shares, scalar, prime)
          shares.map { |s| [s[0], (s[1] * scalar) % prime] }
        end

        def self.sdiv(shares, scalar, prime)
          shares.map { |s| [s[0], (s[1] * mod_inverse(scalar, prime)) % prime] }
        end

        def self.generate_random_coefficients(total_shares, lambda_)
          random_distinct_numbers("integer", total_shares - 1, lambda_ - 1)
        end

        def self.create_shares(secret, total_shares, lambda_, prime)
          random_coefficients = generate_random_coefficients(total_shares, lambda_)
          (1..total_shares).map.with_index { |x, i| [i + 1, f(x, secret, random_coefficients) % prime] }
        end

        def initialize(params = {})
          @lambda_ = params[:lambda_]
          @total_shares = params[:total_shares]
          @threshold = params[:threshold]
          generate_prime
        end

        def create_shares(secret)
          random_coefficients = generate_random_coefficients
          (1..total_shares).map.with_index { |x, i| [i + 1, f(x, secret, random_coefficients) % p] }
        end

        def reconstruct_secret(points)
          xs = points.map(&:first)
          ys = points.map(&:last)
          l0s = lagrange_basis_polynomial(xs)
          l0s.zip(ys).map { |l, y| l * y }.sum % p
        end

        private

        def generate_prime
          @p = random_prime(lambda_)
        end

        def generate_random_coefficients
          random_distinct_numbers("integer", total_shares - 1, lambda_ - 1)
        end
      end
    end
  end
end
