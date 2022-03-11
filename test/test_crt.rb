# frozen_string_literal: true

require "test_helper"

class TestCRT < Minitest::Test
  def test_initialization
    total_number_of_shares = 6
    threshold = 3
    bits = 16
    crt = SecretSharing::CRT.new total_number_of_shares, threshold, bits

    assert_equal total_number_of_shares, crt.total_number_of_shares
    assert_equal threshold, crt.threshold
    assert_equal bits, crt.bits
    assert_equal total_number_of_shares, crt.primes.size
    assert crt.send(:shares_secrecy_condition)
  end

  def test_share_generation_and_secret_reconstruction
    crt = SecretSharing::CRT.new 10, 4, 16
    secret = rand(0..255)

    shares = crt.generate_shares(secret)
    selected_shares = shares.sample(crt.threshold)
    reconstructed_secret = crt.reconstruct_secret(selected_shares)

    assert_equal secret, reconstructed_secret
  end

  def test_addition_and_multiplication
    crt = SecretSharing::CRT.new 10, 5, 16
    secret1 = 5
    secret2 = 8

    shares1 = crt.generate_shares(secret1)
    shares2 = crt.generate_shares(secret2)

    shares_addition = shares1.map.with_index{|x,i| [x[0], x[1] + shares2[i][1]]}
    shares_multiplication = shares1.map.with_index{|x,i| [x[0], x[1] * shares2[i][1]]}

    selected_shares_addition = shares_addition.sample(crt.threshold)
    selected_shares_multiplication = shares_multiplication.sample(crt.threshold)
    
    reconstructed_secret_addition = crt.reconstruct_secret(selected_shares_addition)
    reconstructed_secret_multiplication = crt.reconstruct_secret(selected_shares_multiplication)

    assert_equal secret1 + secret2, reconstructed_secret_addition
    assert_equal secret1 * secret2, reconstructed_secret_multiplication
  end
end