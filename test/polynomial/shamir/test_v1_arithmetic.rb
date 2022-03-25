# frozen_string_literal: true

require "test_helper"

class TestPolynomialShamirV1 < Minitest::Test
  def setup
    @params = { lambda_: 16, total_shares: 6, threshold: 3 }
    @sss = Sharing::Polynomial::Shamir::V1.new @params
  end

  def test_addition
    params = { lambda_: 32, total_shares: 5, threshold: 5 }
    sss = Sharing::Polynomial::Shamir::V1.new params

    secret1 = 18
    secret2 = 23

    shares1 = sss.create_shares(secret1)
    shares2 = sss.create_shares(secret2)

    shares1_add_shares2 = Sharing::Polynomial::Shamir::V1.add(shares1, shares2, sss.p)
    selected_shares1_add_shares2 = shares1_add_shares2.sample(sss.threshold)

    assert_equal secret1 + secret2, sss.reconstruct_secret(selected_shares1_add_shares2)
  end

  def test_subtraction
    params = { lambda_: 32, total_shares: 5, threshold: 5 }
    sss = Sharing::Polynomial::Shamir::V1.new params

    secret1 = 23
    secret2 = 18

    shares1 = sss.create_shares(secret1)
    shares2 = sss.create_shares(secret2)

    shares1_sub_shares2 = Sharing::Polynomial::Shamir::V1.sub(shares1, shares2, sss.p)
    selected_shares1_sub_shares2 = shares1_sub_shares2.sample(sss.threshold)

    assert_equal secret1 - secret2, sss.reconstruct_secret(selected_shares1_sub_shares2)
  end

  def test_scalar_multiplication
    params = { lambda_: 32, total_shares: 5, threshold: 5 }
    sss = Sharing::Polynomial::Shamir::V1.new params

    secret = 19
    scalar = 12

    shares = sss.create_shares(secret)

    shares_smul_scalar = Sharing::Polynomial::Shamir::V1.smul(shares, scalar, sss.p)
    selected_shares_smul_scalar = shares_smul_scalar.sample(sss.threshold)

    assert_equal secret * scalar, sss.reconstruct_secret(selected_shares_smul_scalar)
  end

  def test_scalar_division
    params = { lambda_: 32, total_shares: 5, threshold: 5 }
    sss = Sharing::Polynomial::Shamir::V1.new params

    secret = 80
    scalar = 4

    shares = sss.create_shares(secret)

    shares_sdiv_scalar = Sharing::Polynomial::Shamir::V1.sdiv(shares, scalar, sss.p)
    selected_shares_sdiv_scalar = shares_sdiv_scalar.sample(sss.threshold)

    assert_equal secret / scalar, sss.reconstruct_secret(selected_shares_sdiv_scalar)
  end

  def test_multiplication
    secrets = [5, 8]
    shares = secrets.map { |secret| @sss.create_shares(secret) }
    lambda_, p, total_shares, threshold = @sss.params

    selected_shares = Sharing::Polynomial::Shamir::V1.select_mul_shares(total_shares, threshold, shares)

    mul_round1 = Sharing::Polynomial::Shamir::V1.mul_first_round(selected_shares,
                                                                 total_shares, threshold, lambda_, p)
    mul_round2 = Sharing::Polynomial::Shamir::V1.mul_second_round(mul_round1)

    selected_multiplication_shares = mul_round2.sample(@sss.threshold)

    assert_equal secrets.inject(:*), @sss.reconstruct_secret(selected_multiplication_shares)
  end
end
