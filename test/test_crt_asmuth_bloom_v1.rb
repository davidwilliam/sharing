# frozen_string_literal: true

require "test_helper"

class TestCRTAsmuthBloomV1 < Minitest::Test
  def setup
    @params = { lambda_: 64, threshold: 10, secrecy: 3, total_shares: 13, k_add: 5000, k_mul: 2 }

    @crt = SecretSharing::CRTAsmuthBloomV1.new @params

    @shares1 = @crt.compute_shares(5)
    @shares2 = @crt.compute_shares(8)
    @shares3 = @crt.compute_shares(9)
  end

  def test_initialization
    assert_equal @params[:threshold], @crt.threshold
    assert_equal @params[:secrecy], @crt.secrecy
    assert_equal @params[:total_shares], @crt.total_shares
  end

  def test_primes_initialization
    assert_equal @params[:total_shares], @crt.primes.size
  end

  def test_first_condition
    assert_equal @crt.primes, @crt.primes.sort
  end

  def test_second_condition
    assert_equal 1, @crt.primes.reduce(1, :gcd)
  end

  def test_third_condition
    all_primes = [@crt.p] + @crt.primes
    assert_equal 1, all_primes.reduce(1, :gcd)
  end

  def test_fourth_condition
    expected_condition = @crt.m_r > (@crt.k_add + 1) * ((@crt.p * @crt.m_to_s)**(@crt.k_mul + 1))
    assert expected_condition
  end

  def test_create_shares
    secret = 8
    shares = @crt.compute_shares(secret)

    selected_shares = shares.sample(@crt.threshold)

    assert_equal secret, @crt.reconstruct_secret(selected_shares)
  end

  def test_addition
    addition_shares = SecretSharing::CRTAsmuthBloomV1.add(@shares1, @shares2)

    selected_shares_add = addition_shares.sample(@crt.threshold)

    assert_equal 8 + 5, @crt.reconstruct_secret(selected_shares_add)
  end

  def test_multiplication
    multiplication_shares = SecretSharing::CRTAsmuthBloomV1.mul(@shares1, @shares2)

    selected_shares_mul = multiplication_shares.sample(@crt.threshold)

    assert_equal 8 * 5, @crt.reconstruct_secret(selected_shares_mul)
  end

  def test_addition_depth
    addition_shares_one = SecretSharing::CRTAsmuthBloomV1.add(@shares1, @shares2)
    addition_shares_two = SecretSharing::CRTAsmuthBloomV1.add(addition_shares_one, @shares3)

    selected_shares_add = addition_shares_two.sample(@crt.threshold)

    assert_equal 8 + 5 + 9, @crt.reconstruct_secret(selected_shares_add)
  end

  def test_multiplication_depth
    multiplication_shares_one = SecretSharing::CRTAsmuthBloomV1.mul(@shares1, @shares2)
    multiplication_shares_two = SecretSharing::CRTAsmuthBloomV1.mul(multiplication_shares_one, @shares3)

    selected_shares_mul = multiplication_shares_two.sample(@crt.threshold)

    assert_equal 8 * 5 * 9, @crt.reconstruct_secret(selected_shares_mul)
  end

  def test_reconstrunction_below_threshold
    secret = 13

    shares = @crt.compute_shares(secret)

    selected_shares = shares.sample(@crt.secrecy)

    assert @crt.reconstruct_secret(selected_shares) != 13
  end
end
