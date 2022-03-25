# frozen_string_literal: true

module Sharing
  module Polynomial
    # helper tool for computations with polynomials
    module Tools
      def lagrange_basis_polynomial_inner_loop(index, xs_)
        product = 1
        (0..xs_.size - 1).reject { |l| l == index }.each do |j|
          product *= Rational(-xs_[j], xs_[index] - xs_[j])
        end
        product
      end

      def lagrange_basis_polynomial(xs_)
        (0..xs_.size - 1).map { |i| lagrange_basis_polynomial_inner_loop(i, xs_) }
      end

      def f(poly_var, secret, random_coefficients)
        secret + random_coefficients.each_with_index.inject(0) { |sum, (c, i)| sum + (c * (poly_var**(i + 1))) }
      end
    end
  end
end
