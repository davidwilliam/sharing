module SecretSharing
  module Polynomial
    module Shamir
      class V1
        include HenselCode::Tools

        attr_accessor :lambda_, :p, :total_shares, :threshold

        def initialize(params = {})
          @lambda_ = params[:lambda_]
          @total_shares = params[:total_shares]
          @threshold = params[:threshold]
          generate_prime
        end

        def f(poly_var, secret, random_coefficients)
          secret + random_coefficients.each_with_index.inject(0){|sum, (c,i)| sum += c * poly_var**(i+1) }
        end

        def create_shares(secret)
          random_coefficients = generate_random_coefficients
          (1..total_shares).map.with_index{|x,i| [i + 1, f(x, secret, random_coefficients) % p] }
        end

        def lagrange_basis_polynomial_inner_loop(i, points)
          pts = points.map(&:first)
          product = 1
          (0..points.size - 1).select{|l| l != i}.each do |j|
            product *= Rational(-pts[j], pts[i] - pts[j])
          end
          product
        end

        def lagrange_basis_polynomial(points)
          (0..points.size - 1).map{|i| lagrange_basis_polynomial_inner_loop(i, points)}
        end

        def reconstruct_secret(points)
          ys = points.map(&:last)
          l0s = lagrange_basis_polynomial(points)
          l0s.zip(ys).map{|l,y| l * y }.sum % p
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