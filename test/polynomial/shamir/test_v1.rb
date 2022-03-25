# frozen_string_literal: true

require "test_helper"

class TestPolynomialShamirV1 < Minitest::Test
  def setup
    @params = { lambda_: 16, total_shares: 6, threshold: 3 }
    @sss = Sharing::Polynomial::Shamir::V1.new @params
  end

  def test_initialization
    assert_equal @params[:lambda_], @sss.lambda_
    assert_equal @params[:lambda_], @sss.p.bit_length
    assert_equal @params[:total_shares], @sss.total_shares
    assert_equal @params[:threshold], @sss.threshold
  end

  def test_generate_random_coefficients
    random_coefficients = Sharing::Polynomial::Shamir::V1.generate_random_coefficients(@sss.total_shares,
                                                                                       @sss.lambda_)

    assert_equal @params[:total_shares] - 1, random_coefficients.size
  end

  def test_polynomial_function_f
    cs = [2, 21, 23, 32]
    secret = 19
    [1].each do |x|
      expected_polynomial_evaluation = secret + (0..3).map { |i| (cs[i] * (x**(i + 1))) }.sum

      assert_equal expected_polynomial_evaluation, @sss.send(:f, x, secret, cs)
    end
  end

  def test_lagrande_basis_polynomial
    @sss.p = 373
    points = [[3, 151], [1, 67], [2, 240]]
    xs = points.map(&:first)
    expected_l0s = [1, 3, -3]

    assert_equal expected_l0s, @sss.lagrange_basis_polynomial(xs)
  end

  def test_secret_reconstruction
    secret = 23
    shares = @sss.create_shares(secret)
    reconstructed_secret = @sss.reconstruct_secret(shares)

    assert_equal secret, reconstructed_secret
  end

  def test_regular_setup
    params = { lambda_: 16, total_shares: 5, threshold: 3 }
    sss = Sharing::Polynomial::Shamir::V1.new params

    secret = 18
    shares = sss.create_shares(secret)
    selected_shares = shares.sample(sss.threshold)
    reconstructed_secret = sss.reconstruct_secret(selected_shares)

    assert_equal secret, reconstructed_secret
  end

  def test_larger_setup
    params = { lambda_: 16, total_shares: 6, threshold: 3 }
    sss = Sharing::Polynomial::Shamir::V1.new params

    secret = 19
    shares = sss.create_shares(secret)

    selected_shares = shares.sample(sss.threshold)
    reconstructed_secret = sss.reconstruct_secret(selected_shares)

    assert_equal secret, reconstructed_secret
  end
end
