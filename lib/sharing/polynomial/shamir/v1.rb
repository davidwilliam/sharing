# frozen_string_literal: true

module Sharing
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

        def self.mul_first_round(shares1, shares2, total_shares, threshold, lambda_, prime)
          xs = shares1.map(&:first)
          shares1.zip(shares2).map.with_index do |s, i|
            beta = lagrange_basis_polynomial_inner_loop(i, xs)
            share = (s[0][1] * s[1][1] * beta) % prime
            shares = create_shares(share, total_shares, threshold, lambda_, prime)
            shares = shares.map{|s| [s[0], (s[1].numerator * mod_inverse(s[1].denominator, prime)) % prime]}
            [s[0][0], shares]
          end
        end

        def self.mul_second_round(mul_round1)
          multiplication_shares = mul_round1.map(&:last).map{|m| m.map(&:last)}.transpose.map(&:sum)
          multiplication_shares.map.with_index{|m,i| [i + 1, m] }
        end

        def self.generate_random_coefficients(total_shares, lambda_)
          random_distinct_numbers("integer", total_shares - 1, lambda_ - 1)
        end

        def self.create_shares(secret, total_shares, threshold, lambda_, prime)
          random_coefficients = generate_random_coefficients(threshold, lambda_)
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
          (1..total_shares).map { |x| [x, f(x, secret, random_coefficients) % p] }
        end

        def reconstruct_secret(points)
          xs = points.map(&:first)
          ys = points.map(&:last)
          l0s = lagrange_basis_polynomial(xs)
          reconstructed_secret = l0s.zip(ys).map { |l, y| l * y }.sum % p
          encode_to_integer(reconstructed_secret)
        end

        private

        def generate_prime
          @p = random_prime(lambda_)
        end

        def generate_random_coefficients
          random_distinct_numbers("integer", threshold - 1, lambda_ - 1)
        end

        def encode_to_integer(reconstructed_secret)
          (reconstructed_secret.numerator * mod_inverse(reconstructed_secret.denominator, p)) % p
        end
      end
    end
  end
end
