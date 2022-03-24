# frozen_string_literal: true

require "test_helper"

class TestPolynomialShamirV1 < Minitest::Test
  def setup
    @params = { lambda_: 32, total_shares: 5, threshold: 3 }
    @sss = SecretSharing::Polynomial::Shamir::V1.new @params
  end

  def test_initialization
    assert_equal @params[:lambda_], @sss.lambda_
    assert_equal @params[:lambda_], @sss.p.bit_length
    assert_equal @params[:total_shares], @sss.total_shares
    assert_equal @params[:threshold], @sss.threshold
  end

  def test_generate_random_coefficients
    random_coefficients = SecretSharing::Polynomial::Shamir::V1.generate_random_coefficients(@sss.total_shares,
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
    params = { lambda_: 32, total_shares: 5, threshold: 3 }
    sss = SecretSharing::Polynomial::Shamir::V1.new params

    secret = 18
    shares = sss.create_shares(secret)
    selected_shares = shares.sample(sss.total_shares)
    reconstructed_secret = sss.reconstruct_secret(selected_shares)

    assert_equal secret, reconstructed_secret
  end

  def test_larger_setup
    params = { lambda_: 32, total_shares: 20, threshold: 10 }
    sss = SecretSharing::Polynomial::Shamir::V1.new params

    secret = 18
    shares = sss.create_shares(secret)
    selected_shares = shares.sample(sss.total_shares)
    reconstructed_secret = sss.reconstruct_secret(selected_shares)

    assert_equal secret, reconstructed_secret
  end

  def test_addition
    params = { lambda_: 32, total_shares: 5, threshold: 5 }
    sss = SecretSharing::Polynomial::Shamir::V1.new params

    secret1 = 18
    secret2 = 23

    shares1 = sss.create_shares(secret1)
    shares2 = sss.create_shares(secret2)

    shares1_add_shares2 = SecretSharing::Polynomial::Shamir::V1.add(shares1, shares2, sss.p)
    selected_shares1_add_shares2 = shares1_add_shares2.sample(sss.threshold)

    assert_equal secret1 + secret2, sss.reconstruct_secret(selected_shares1_add_shares2)
  end

  def test_subtraction
    params = { lambda_: 32, total_shares: 5, threshold: 5 }
    sss = SecretSharing::Polynomial::Shamir::V1.new params

    secret1 = 23
    secret2 = 18

    shares1 = sss.create_shares(secret1)
    shares2 = sss.create_shares(secret2)

    shares1_sub_shares2 = SecretSharing::Polynomial::Shamir::V1.sub(shares1, shares2, sss.p)
    selected_shares1_sub_shares2 = shares1_sub_shares2.sample(sss.threshold)

    assert_equal secret1 - secret2, sss.reconstruct_secret(selected_shares1_sub_shares2)
  end

  def test_scalar_multiplication
    params = { lambda_: 32, total_shares: 5, threshold: 5 }
    sss = SecretSharing::Polynomial::Shamir::V1.new params

    secret = 19
    scalar = 12

    shares = sss.create_shares(secret)

    shares_smul_scalar = SecretSharing::Polynomial::Shamir::V1.smul(shares, scalar, sss.p)
    selected_shares_smul_scalar = shares_smul_scalar.sample(sss.threshold)

    assert_equal secret * scalar, sss.reconstruct_secret(selected_shares_smul_scalar)
  end

  def test_scalar_division
    params = { lambda_: 32, total_shares: 5, threshold: 5 }
    sss = SecretSharing::Polynomial::Shamir::V1.new params

    secret = 80
    scalar = 4

    shares = sss.create_shares(secret)

    shares_sdiv_scalar = SecretSharing::Polynomial::Shamir::V1.sdiv(shares, scalar, sss.p)
    selected_shares_sdiv_scalar = shares_sdiv_scalar.sample(sss.threshold)

    assert_equal secret / scalar, sss.reconstruct_secret(selected_shares_sdiv_scalar)
  end
end
