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

        def self.mul_first_round(shares, total_shares, threshold, lambda_, prime)
          shares1, shares2 = shares
          xs = shares1.map(&:first)
          shares1.zip(shares2).map.with_index do |s, i|
            share = prepare_share_for_multiplication(i, xs, prime, s)
            reshares = create_shares(share, total_shares, threshold, lambda_, prime)
            encode_reshares(reshares, prime, s)
          end
        end

        def self.encode_reshares(reshares, prime, s_pair)
          reshares_encoded = reshares.map do |ss|
            [ss[0], (ss[1].numerator * mod_inverse(ss[1].denominator, prime)) % prime]
          end
          [s_pair[0][0], reshares_encoded]
        end

        def self.prepare_share_for_multiplication(index, xs_, prime, s_pair)
          beta = lagrange_basis_polynomial_inner_loop(index, xs_)
          (s_pair[0][1] * s_pair[1][1] * beta) % prime
        end

        def self.mul_second_round(mul_round1)
          multiplication_shares = mul_round1.map(&:last).map { |m| m.map(&:last) }.transpose.map(&:sum)
          multiplication_shares.map.with_index { |m, i| [i + 1, m] }
        end

        def self.select_mul_shares(total_shares, threshold, shares)
          indices = (0..total_shares - 1).to_a.sample((2 * threshold) - 1)
          shares.map { |shares_| shares_.values_at(*indices) }
        end

        def self.generate_random_coefficients(total_shares, lambda_)
          random_distinct_numbers("integer", total_shares - 1, lambda_ - 1)
        end

        def self.create_shares(secret, total_shares, threshold, lambda_, prime)
          random_coefficients = generate_random_coefficients(threshold, lambda_)
          (1..total_shares).map.with_index { |x, i| [i + 1, f(x, secret, random_coefficients) % prime] }
        end

        def self.generate_division_masking(prime)
          r1, r2 = random_distinct_numbers("integer", 2, prime.bit_length - 1)
          r3 = (r2 * mod_inverse(r1, prime)) % prime
          [r1, r2, r3]
        end

        def self.compute_numerator_denominator(shares1, shares2, r1_, r2_, prime)
          cs = shares1.map { |i, share| [i, (share * r1_) % prime] }
          ds = shares2.map { |i, share| [i, (share * r2_) % prime] }
          [cs, ds]
        end

        def initialize(params = {})
          @lambda_ = params[:lambda_]
          @total_shares = params[:total_shares]
          @threshold = params[:threshold]
          generate_prime
        end

        def params
          [lambda_, p, total_shares, threshold]
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

        def reconstruct_division(cs_, ds_, r3_)
          c, d = [cs_, ds_].map { |shares| reconstruct_secret(shares) }
          c_d_encoded = (c * mod_inverse(d, p) * r3_) % p
          HenselCode::TruncatedFinitePadicExpansion.new(p, 1, c_d_encoded).to_r
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
