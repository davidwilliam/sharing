# frozen_string_literal: true

require "test_helper"

class TestPolynomialShamirV1 < Minitest::Test
  def setup
    @params = {lambda_: 32, total_shares: 5, threshold: 3}
    @sss = SecretSharing::Polynomial::Shamir::V1.new @params
  end

  def test_initialization
    assert_equal @params[:lambda_], @sss.lambda_
    assert_equal @params[:lambda_], @sss.p.bit_length
    assert_equal @params[:total_shares], @sss.total_shares
    assert_equal @params[:threshold], @sss.threshold
  end

  def test_generate_random_coefficients
    random_coefficients = @sss.send(:generate_random_coefficients)

    assert_equal @params[:total_shares] - 1, random_coefficients.size
  end

  def test_polynomial_function_f
    cs = [2,21,23,32]
    secret = 19
    x1 = 1
    x2 = 2
    expected_polynomial_evaluation1 = secret + cs[0]*x1 + cs[1]*x1**2 + cs[2]*x1**3 + cs[3]*x1**4
    expected_polynomial_evaluation2 = secret + cs[0]*x2 + cs[1]*x2**2 + cs[2]*x2**3 + cs[3]*x2**4

    assert_equal expected_polynomial_evaluation1, @sss.send(:f, x1, secret, cs)
    assert_equal expected_polynomial_evaluation2, @sss.send(:f, x2, secret, cs)
  end

  def test_lagrande_basis_polynomial
    @sss.p = 373
    points = [[3, 151], [1, 67], [2, 240]]
    expected_l0s = [1, 3, -3]  
    
    assert_equal expected_l0s, @sss.lagrange_basis_polynomial(points)
  end

  def test_secret_reconstruction
    secret = 23
    shares = @sss.create_shares(secret)
    reconstructed_secret = @sss.reconstruct_secret(shares)

    assert_equal secret, reconstructed_secret
  end

  def test_regular_setup
    params = {lambda_: 32, total_shares: 5, threshold: 3}
    sss = SecretSharing::Polynomial::Shamir::V1.new params

    secret = 18
    shares = sss.create_shares(secret)
    selected_shares = shares.sample(sss.threshold)
    reconstructed_secret = sss.reconstruct_secret(shares)

    assert_equal secret, reconstructed_secret
  end

  def test_larger_setup
    params = {lambda_: 32, total_shares: 15, threshold: 10}
    sss = SecretSharing::Polynomial::Shamir::V1.new params

    secret = 18
    shares = sss.create_shares(secret)
    selected_shares = shares.sample(sss.threshold)
    reconstructed_secret = sss.reconstruct_secret(shares)

    assert_equal secret, reconstructed_secret
  end

end